package ttsclient

import io.ktor.client.*
import io.ktor.client.engine.apache.*
import io.ktor.client.request.*
import io.ktor.client.statement.*
import io.ktor.utils.io.*
import kotlinx.coroutines.*
import org.dom4j.DocumentHelper

fun main(args: Array<String>) = runBlocking {
    val apiKey = System.getenv("MYKEY")
    val region = System.getenv("MYREGION")

    if (apiKey.isNullOrEmpty() || region.isNullOrEmpty()) {
        println("Set MYKEY and MYREGION environment variables first")
    } else {
        val tokenIssuer = "https://$region.api.cognitive.microsoft.com/sts/v1.0/issueToken"
        val synthesizer = "https://$region.tts.speech.microsoft.com/cognitiveservices/v1"
        val client = HttpClient(Apache)
        val requestBuilder = HttpRequestBuilder {}
        requestBuilder.url(tokenIssuer)
        requestBuilder.header("Ocp-Apim-Subscription-Key", apiKey)
        requestBuilder.body = ""
        val tokenResp = client.post<HttpStatement>(requestBuilder)
        val token = tokenResp.execute().content.readUTF8Line()

        requestBuilder.url(synthesizer)
        requestBuilder.headers.clear()
        //    requestBuilder.headers.append("Content-type", "application/ssml+xml")
        requestBuilder.headers.append("X-Microsoft-OutputFormat", "riff-24khz-16bit-mono-pcm")
        requestBuilder.headers.append("Authorization", "Bearer $token")
        requestBuilder.headers.append("X-Search-AppId", "07D3234E49CE426DAA29772419F436CA")
        requestBuilder.headers.append("X-Search-ClientID", "1ECFAE91408841A480F00935DC390960")
        requestBuilder.headers.append("User-Agent", "Kotlin")
        requestBuilder.body = ssml()
        val synthResp = client.post<HttpStatement>(requestBuilder)

        println(synthResp.execute().status)
    }
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
