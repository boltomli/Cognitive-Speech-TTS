package ttsclient

import io.ktor.client.*
import io.ktor.client.engine.apache.*
import io.ktor.client.request.*
import io.ktor.client.response.*
import kotlinx.coroutines.experimental.*
import kotlinx.coroutines.experimental.io.*
import org.dom4j.DocumentHelper

fun main(args: Array<String>) = runBlocking {
    val tokenIssuer = "https://westus.api.cognitive.microsoft.com/sts/v1.0/issueToken"
    val synthesizer = "https://westus.tts.speech.microsoft.com/cognitiveservices/v1"
    val apiKey = "myAPIKey"

    val client = HttpClient(Apache)
    val requestBuilder = HttpRequestBuilder {}
    requestBuilder.url(tokenIssuer)
    requestBuilder.header("Ocp-Apim-Subscription-Key", apiKey)
    requestBuilder.body = ""
    val tokenResp = client.post<HttpResponse>(requestBuilder)
    val token = tokenResp.content.readUTF8Line()

    requestBuilder.url(synthesizer)
    requestBuilder.headers.clear()
    requestBuilder.headers.append("Content-type", "application/ssml+xml")
    requestBuilder.headers.append("X-Microsoft-OutputFormat", "riff-24khz-16bit-mono-pcm")
    requestBuilder.headers.append("Authorization", "Bearer $token")
    requestBuilder.headers.append("X-Search-AppId", "07D3234E49CE426DAA29772419F436CA")
    requestBuilder.headers.append("X-Search-ClientID", "1ECFAE91408841A480F00935DC390960")
    requestBuilder.headers.append("User-Agent", "Kotlin")
    requestBuilder.body = ssml()
    val synthResp = client.post<HttpResponse>(requestBuilder)

    println(synthResp.status)
}

fun ssml() :String {
    val document = DocumentHelper.createDocument()
    val speak = document.addElement("speak")
    speak.addAttribute("version", "1.0")
    speak.addAttribute("xml:lang", "en-us")
    val voice = speak.addElement("voice")
    voice.addAttribute("xml:lang", "en-us")
    voice.addAttribute("xml:gender", "Male")
    voice.addAttribute("name", "Microsoft Server Speech Text to Speech Voice (en-US, Guy24KRUS)")
    voice.addText("speak something with kotlin")
    return document.asXML()
}
