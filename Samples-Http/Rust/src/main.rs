use anyhow::Result;
use std::env;
use std::collections::HashMap;
use smol::run;
use isahc::{HttpClient, ResponseExt};
use xml::writer::XmlEvent;
use xml::EmitterConfig;

fn main() -> Result<()> {
    run(async {
        let key = env::var("MYKEY")?;
        let region = env::var("MYREGION")?;

        let token_uri = format!("https://{}.api.cognitive.microsoft.com/sts/v1.0/issueToken", region);
        let mut headers = HashMap::new();
        headers.insert("Ocp-Apim-Subscription-Key", key);
        let mut client = HttpClient::builder()
            .default_headers(headers)
            .build()?;
        let token = client.post_async(token_uri, "").await?.text_async().await?;

        let synth_uri = format!("https://{}.tts.speech.microsoft.com/cognitiveservices/v1", region);
        headers = HashMap::new();
        headers.insert("Authorization", format!("Bearer {}", token));
        headers.insert("Content-Type", "application/ssml+xml".to_string());
        headers.insert("X-Microsoft-OutputFormat", "riff-24khz-16bit-mono-pcm".to_string());
        headers.insert("User-Agent", "YOUR_RESOURCE_NAME".to_string());
        client = HttpClient::builder()
            .default_headers(headers)
            .build()?;

        let lang = "en-US";
        let text = "123, 456. 789? 0!";
        let mut ssml = Vec::new();
        let mut w = EmitterConfig::new().write_document_declaration(false).create_writer(&mut ssml);
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
        let result = client.post_async(synth_uri, ssml).await?.copy_to_file("synthesized.wav")?;
        println!("Synthesis length: {}", result.to_owned());
        Ok(())
    })
}
