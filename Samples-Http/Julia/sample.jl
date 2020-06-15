using HTTP
using LightXML

headers = ["Ocp-Apim-Subscription-Key" => ENV["MYKEY"]]
r = HTTP.request("POST", string("https://", ENV["MYREGION"], ".api.cognitive.microsoft.com/sts/v1.0/issueToken"), headers)
token = String(r.body)
headers = ["Authorization" => string("Bearer ", token),
           "Content-Type" => "application/ssml+xml",
           "X-Microsoft-OutputFormat" => "riff-24khz-16bit-mono-pcm",
           "User-Agent" => "YOUR_RESOURCE_NAME"]

lang = "en-US"
xdoc = XMLDocument()
xroot = create_root(xdoc, "speak")
set_attributes(xroot, Dict("version" => "1.0",
                            "xmlns" => "http://www.w3.org/2001/10/synthesis",
                            "xmlns:mstts" => "https://www.w3.org/2001/mstts",
                            "xml:lang" => lang))
xs = new_child(xroot, "voice")
set_attributes(xs, Dict("xml:lang" => lang,
                        "xml:gender" => "Female",
                        "name" => "en-US-AriaRUS"))
add_text(xs, "123, 456. 789? 0!")

io = open("synthesized.wav", "w")
r = HTTP.request("POST", string("https://", ENV["MYREGION"], ".tts.speech.microsoft.com/cognitiveservices/v1"), headers, string(xdoc), response_stream=io)
close(io)
println("saved result to synthesized.wav")
