use std::io::Write;
use xml::writer::XmlEvent;
use tokio_compat_02::FutureExt;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let key = std::env::var("MYKEY")?;
    let region = std::env::var("MYREGION")?;

    let token_uri = format!("https://{}.api.cognitive.microsoft.com/sts/v1.0/issueToken", region);
    let mut headers = reqwest::header::HeaderMap::new();
    headers.insert("Ocp-Apim-Subscription-Key", key.parse().unwrap());
    headers.insert("Content-Length", "0".parse().unwrap());
    let client = reqwest::Client::new();
    let token = client.post(&token_uri)
        .headers(headers)
        .send()
        .compat()
        .await?
        .text()
        .await?;

    let synth_uri = format!("https://{}.tts.speech.microsoft.com/cognitiveservices/v1", region);
    headers = reqwest::header::HeaderMap::new();
    headers.insert("Authorization", format!("Bearer {}", token).parse().unwrap());
    headers.insert("Content-Type", "application/ssml+xml".parse().unwrap());
    headers.insert("X-Microsoft-OutputFormat", "riff-24khz-16bit-mono-pcm".parse().unwrap());
    headers.insert("User-Agent", "YOUR_RESOURCE_NAME".parse().unwrap());

    let lang = "en-US";
    let text = "123, 456. 789? 0!";
    let mut ssml = Vec::new();
    let mut w = xml::EmitterConfig::new().write_document_declaration(false).create_writer(&mut ssml);
    w.write(XmlEvent::start_element("speak")
        .attr("version", "1.0")
        .attr("xmlns", "http://www.w3.org/2001/10/synthesis")
        .ns("mstts", "https://www.w3.org/2001/mstts")
        .attr("xml:lang", lang))?;
    w.write(XmlEvent::start_element("voice")
        .attr("xml:lang", lang)
        .attr("xml:gender", "Female")
        .attr("name", "en-US-AriaRUS"))?;
    w.write(text).unwrap();
    w.write(XmlEvent::end_element()).unwrap();
    w.write(XmlEvent::end_element()).unwrap();

    // <speak version='1.0' xmlns='http://www.w3.org/2001/10/synthesis' xmlns:mstts='https://www.w3.org/2001/mstts' xml:lang='en-US'><voice xml:lang='en-US' xml:gender='Female' name='en-US-AriaRUS'>123, 456. 789? 0!</voice></speak>
    let result = client.post(&synth_uri)
        .headers(headers)
        .body(ssml)
        .send()
        .compat()
        .await?
        .bytes()
        .await?;

    let mut buffer = std::fs::File::create("synthesized.wav")?;
    buffer.write_all(&result)?;
    println!("Synthesis length: {}", result.len().to_owned());
    Ok(())
}
