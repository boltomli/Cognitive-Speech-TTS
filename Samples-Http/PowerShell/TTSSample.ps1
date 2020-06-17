# Copyright (c) Microsoft Corporation
# All rights reserved. 
# MIT License
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ""Software""), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Note: new unified SpeechService API key and issue token uri is per region
# New unified SpeechService key
# Free: https://azure.microsoft.com/en-us/try/cognitive-services/?api=speech-services
# Paid: https://go.microsoft.com/fwlink/?LinkId=872236
$apiKey = $env:MYKEY
$region = $env:MYREGION
$tokenHeader = @{"Ocp-Apim-Subscription-Key"=$apiKey}
$tokenUri = "https://" + $region + ".api.cognitive.microsoft.com/sts/v1.0/issueToken"
$tokenReq = Invoke-WebRequest -Uri $tokenUri -Headers $tokenHeader -Body "" -Method POST
$token = New-Object System.String($tokenReq.Content, 0, $tokenReq.Content.Length)

$ssml = "<speak version='1.0' xml:lang='en-us'><voice name='Microsoft Server Speech Text to Speech Voice (en-US, Guy24KRUS)' xml:gender='Male' xml:lang='en-US'>This is a demo to call microsoft text to speech service.</voice></speak>"
$synthHeaders = New-Object 'System.Collections.Generic.Dictionary[String, String]'
$synthHeaders.Add("Content-type", "application/ssml+xml")
$synthHeaders.Add("X-Microsoft-OutputFormat", "riff-24khz-16bit-mono-pcm")
$synthHeaders.Add("Authorization", "Bearer " + $token)
$synthHeaders.Add("X-Search-AppId", "07D3234E49CE426DAA29772419F436CA")
$synthHeaders.Add("X-Search-ClientID", "1ECFAE91408841A480F00935DC390960")
$synthUri = "https://" + $region + ".tts.speech.microsoft.com/cognitiveservices/v1"
$synthReq = Invoke-WebRequest -Uri $synthUri -Headers $synthHeaders -Body $ssml -Method POST
$synthesis = $synthReq.Content

$synthesis.Length
