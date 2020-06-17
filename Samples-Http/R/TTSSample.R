# Copyright (c) Microsoft Corporation
# All rights reserved. 
# MIT License
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ""Software""), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

library(XML)
ssml <- newXMLDoc()
ns <- c(xml = "http://www.w3.org/2000/xmlns")
speak <- newXMLNode("speak", namespace = ns)
addAttributes(speak, "version" = "1.0", "xml:lang" = "en-us")
voice <- newXMLNode("voice", namespace = ns)
addAttributes(voice, "xml:lang" = "en-us", "xml:gender" = "Male", "name" = "Microsoft Server Speech Text to Speech Voice (en-US, Guy24KRUS)")
text <- newXMLTextNode("This is a demo to call Microsoft speech service.")
addChildren(voice, text)
addChildren(speak, voice)
addChildren(ssml, speak)

# Note: new unified SpeechService API key and issue token uri is per region
# New unified SpeechService key
# Free: https://azure.microsoft.com/en-us/try/cognitive-services/?api=speech-services
# Paid: https://go.microsoft.com/fwlink/?LinkId=872236
library(httr)
key <- Sys.getenv(c("MYREGION", "MYKEY"))
issueTokenUri <- paste0("https://", key[[1]], ".api.cognitive.microsoft.com/sts/v1.0/issueToken");
tokenResult <- POST(issueTokenUri,
                    add_headers("Ocp-Apim-Subscription-Key" = key[[2]]),
                    body = "")
token <- content(tokenResult, as = "text")
serviceUri <- paste0("https://", key[[1]], ".tts.speech.microsoft.com/cognitiveservices/v1");
synthesisResult <- POST(serviceUri,
                        content_type("application/ssml+xml"),
                        add_headers(
                          "X-Microsoft-OutputFormat" = "riff-24khz-16bit-mono-pcm",
                          "Authorization" = paste("Bearer ", token),
                          "X-Search-AppId" = "07D3234E49CE426DAA29772419F436CA",
                          "X-Search-ClientID" = "1ECFAE91408841A480F00935DC390960"
                        ),
                        body = toString.XMLNode(ssml))
synthesis <- content(synthesisResult, as = "raw")
print(length(synthesis))
# pcmfile <- file("temp.wav", "wb")
# writeBin(con = pcmfile, object = synthesis)
# close(pcmfile)
# library(tuneR)
# wave <- readWave("temp.wav")
# play(wave, player = "play")
