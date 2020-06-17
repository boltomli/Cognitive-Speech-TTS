// Copyright (c) Microsoft Corporation
// All rights reserved. 
// MIT License
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ""Software""), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import scalaj.http._
import scala.xml._

object Main extends App {
  // Note: new unified SpeechService API key and issue token uri is per region
  // New unified SpeechService key
  // Free: https://azure.microsoft.com/en-us/try/cognitive-services/?api=speech-services
  // Paid: https://go.microsoft.com/fwlink/?LinkId=872236
  sys.env.get("MYREGION") match {
    case Some(region) => {
      val tokenUri = "https://" + region + ".api.cognitive.microsoft.com/sts/v1.0/issueToken"
      val serviceUri = "https://" + region + ".tts.speech.microsoft.com/cognitiveservices/v1"
      sys.env.get("MYKEY") match {
        case Some(key) => {
          val tokenRequest: HttpRequest = Http(tokenUri).headers(("Ocp-Apim-Subscription-Key", key)).postData("")
          val response: HttpResponse[String] = tokenRequest.asString
          val token: String = response.body

          val body: xml.Elem = <speak version='1.0' xml:lang='en-us'><voice xml:lang='en-us' xml:gender='Male' name='Microsoft Server Speech Text to Speech Voice (en-US, Guy24KRUS)'>This is a demo to call Microsoft speech service.</voice></speak>
          val synthRequest: HttpRequest = Http(serviceUri).headers(
            ("Content-type", "application/ssml+xml"),
            ("X-Microsoft-OutputFormat", "riff-24khz-16bit-mono-pcm"),
            ("Authorization", "Bearer " + token),
            ("X-Search-AppId", "07D3234E49CE426DAA29772419F436CA"),
            ("X-Search-ClientID", "1ECFAE91408841A480F00935DC390960")
          ).postData(body.toString())
          val synthesis: String = synthRequest.asString.body
          println(synthesis.length)
        }
        case None => println("Set key first")
      }
    }
    case None => println("Set region first")
  }
}