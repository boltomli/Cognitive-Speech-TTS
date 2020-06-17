# Copyright (c) Microsoft Corporation
# All rights reserved. 
# MIT License
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ""Software""), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import httpclient
import xmldom
import os

# Note: new unified SpeechService API key and issue token uri is per region
# New unified SpeechService key
# Free: https://azure.microsoft.com/en-us/try/cognitive-services/?api=speech-services
# Paid: https://go.microsoft.com/fwlink/?LinkId=872236
let
  key = getEnv("MYKEY")
  region = getEnv("MYREGION")
  issueTokenUri = "https://" & region & ".api.cognitive.microsoft.com/sts/v1.0/issueToken"
  serviceUri = "https://" & region & ".tts.speech.microsoft.com/cognitiveservices/v1"
  client = newHttpClient()

# Get token
client.headers = newHttpHeaders({ "Ocp-Apim-Subscription-Key": key })
var token = client.postContent(issueTokenUri)

# Create SSML
var
  dom = getDOM()
  document = dom.createDocument("", "speak")
  speak = document.documentElement
  voice = document.createElement "voice"
  text = document.createTextNode "This is a demo to call Microsoft speech service."
speak.setAttribute("version", "1.0")
speak.setAttribute("xml:lang", "en-us")
voice.setAttribute("xml:lang", "en-us")
voice.setAttribute("xml:gender", "Male")
voice.setAttribute("name", "Microsoft Server Speech Text to Speech Voice (en-US, Guy24KRUS)")
voice.appendChild(text)
speak.appendChild(voice)
var body = `$`(document)

# Synthesize
client.headers = newHttpHeaders({
  "Content-type": "application/ssml+xml",
  "Content-Length": newString(len(token)),
  "X-Microsoft-OutputFormat": "riff-24khz-16bit-mono-pcm",
  "Authorization": "Bearer " & token,
  "X-Search-AppId": "07D3234E49CE426DAA29772419F436CA",
  "X-Search-ClientID": "1ECFAE91408841A480F00935DC390960",
  "User-Agent": "nim"
  })
var synthesis = client.postContent(serviceUri, body=body)
echo len(synthesis)
