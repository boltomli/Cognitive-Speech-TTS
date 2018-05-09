//  Copyright (c) Microsoft Corporation
//  All rights reserved. 
//  MIT License
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ""Software""), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//  THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

using Soup;
using GXml;

void main (string[] args) {
	try {
		var issueTokenUri = "https://westus.api.cognitive.microsoft.com/sts/v1.0/issueToken";
		var serviceUri = "https://westus.tts.speech.microsoft.com/cognitiveservices/v1";

		// Note: new unified SpeechService API key and issue token uri is per region
		// New unified SpeechService key
		// Free: https://azure.microsoft.com/en-us/try/cognitive-services/?api=speech-services
		// Paid: https://go.microsoft.com/fwlink/?LinkId=872236
		var apiKey = "myKey";

		// Get token
		var session = new Session ();
		var issueTokenMsg = new Soup.Message ("POST",  @"$issueTokenUri");
		issueTokenMsg.request_headers.append ("Ocp-Apim-Subscription-Key", @"$apiKey");
		issueTokenMsg.request_headers.append ("Content-Length", "0");
		session.send_message (issueTokenMsg);
		var token = (string)issueTokenMsg.response_body.data;

		// Build SSML to speak
		var ssml = create_ssml ();

		// Get audio stream
		var speakMsg = new Soup.Message ("POST", @"$serviceUri");
		speakMsg.request_body.append_take (ssml.data);
		speakMsg.request_headers.set_content_type ("application/ssml+xml", null);
		speakMsg.request_headers.set_content_length (data.length);
		speakMsg.request_headers.append ("X-Microsoft-OutputFormat", "riff-24khz-16bit-mono-pcm");
		speakMsg.request_headers.append ("Authorization", @"Bearer $token");
		speakMsg.request_headers.append ("X-Search-AppId", "07D3234E49CE426DAA29772419F436CA");
		speakMsg.request_headers.append ("X-Search-ClientID", "1ECFAE91408841A480F00935DC390960");
		speakMsg.request_headers.append ("User-Agent", "Vala");
		session.send_message (speakMsg);
		stdout.printf ("Status code: %u\n", speakMsg.status_code);
		stdout.printf ("Message length: %lld\n", speakMsg.response_body.length);
		stdout.printf ("Reason: %s\n", speakMsg.reason_phrase);
	} catch (GLib.Error e) {
		stderr.printf ("%s\n", e.message);
	}
}

string create_ssml () throws GLib.Error {
	var doc = new GomDocument ();
	var root = doc.create_element ("speak");
	root.set_attribute ("version", "1.0");
	root.set_attribute_ns ("http://www.w3.org/2000/xmlns", "xml:lang", "en-us");
	var voice = doc.create_element ("voice");
	voice.set_attribute_ns ("http://www.w3.org/2000/xmlns", "xml:lang", "en-us");
	voice.set_attribute_ns ("http://www.w3.org/2000/xmlns", "xml:gender", "Male");
	voice.set_attribute ("name", "Microsoft Server Speech Text to Speech Voice (en-US, Guy24KRUS)");
	var text = doc.create_text_node ("This is a demo to call Microsoft speech service.");
	voice.append_child (text);
	root.append_child (voice);
	doc.append_child (root);
	return (doc as GomDocument).write_string ();
}
