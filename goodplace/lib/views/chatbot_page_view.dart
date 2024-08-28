import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatbotScreenView extends StatefulWidget {
  @override
  _ChatbotScreenViewState createState() => _ChatbotScreenViewState();
}

class _ChatbotScreenViewState extends State<ChatbotScreenView> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final String openAiApiKey = '9070bb36762b4ddc8552f51b98091334';

  String selectedLanguage = 'en'; // Varsayılan olarak İngilizce

  // Sistem mesajını seçilen dile göre ayarlama
  String getSystemMessage() {
    if (selectedLanguage == 'en') {
      return 'You are a helpful assistant who makes sentences to motivate people. Your answers must be at least 100 characters long. You can quote famous people\'s words or create your own sentences. You can inform users about habit tracking. However, when asked about a topic other than habit tracking or motivational sentences, just write a sentence stating that you have no knowledge on the subject';
    } else if (selectedLanguage == 'tr') {
      return 'Sen insanlari motive etmek için cümleler kuran yardimsever bir asistansin. Yanitlarin en az 100 karakter uzunluğunda olmali. Ünlü kişilerin sözlerini alintilayabilir veya kendi cümlelerini oluşturabilirsin.Alişkanlik takibi hakkinda kullanicilara bilgi verebilirsin.Ancak, alişkanlik takibi veya motivasyon cümleleri dişinda bir konu sorulduğunda,sadece bu konuda bir bilgin olmadiğini belirttiğin bir cümle yaz';
    }
    return '';
  }

  Future<void> generateResponse(String message) async {
    final url = Uri.parse(
        'https://patrons-openai.openai.azure.com/openai/deployments/GrowTogether/chat/completions?api-version=2024-02-15-preview');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'api-key': openAiApiKey,
      },
      body: jsonEncode({
        'messages': [
          {'role': 'system', 'content': getSystemMessage()},
          {'role': 'user', 'content': message}
        ],
        'max_tokens':
            150, // Cevabın uzunluğunu artırmak için token sayısını artırdık
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final purpose = data['choices'][0]['message']['content'].trim();

      // Cevabı kontrol et ve amacından farklı bir şey sorulduysa uygun mesaj göster
      if ((selectedLanguage == 'en' &&
              (purpose.toLowerCase().contains("i don't know") ||
                  purpose.toLowerCase().contains("this topic"))) ||
          (selectedLanguage == 'tr' &&
              (purpose.toLowerCase().contains("bilmiyorum") ||
                  purpose.toLowerCase().contains("bu konu")))) {
        setState(() {
          _messages.add({
            'role': 'bot',
            'content': selectedLanguage == 'en'
                ? 'Sorry, I can\'t help with this topic. However, I can assist with questions about habit tracking or motivational sentences.'
                : 'Üzgünüm, bu konuda yardimci olamiyorum. Ancak, alişkanlik takibi veya motivasyon cümleleriyle ilgili sorularinizi yanitlayabilirim.'
          });
        });
      } else {
        setState(() {
          _messages.add({'role': 'bot', 'content': purpose});
        });
      }
    } else {
      setState(() {
        _messages.add({
          'role': 'bot',
          'content': selectedLanguage == 'en'
              ? 'Failed to generate purpose'
              : 'Amaç oluşturulamadi.'
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25))),
        backgroundColor: Color(0xff8E97FD),
        title: Row(
          children: [
            CircleAvatar(
              child: Image.asset('assets/images/robot.png'),
              backgroundColor: Colors.grey,
            ),
            SizedBox(
              width: 20,
            ),
            Text(
              "GoodPlaceT",
              style: GoogleFonts.rubik(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                  fontSize: 25),
            )
          ],
        ),
        actions: [
          DropdownButton<String>(
            value: selectedLanguage,
            items: [
              DropdownMenuItem(
                value: 'en',
                child: Text('English'),
              ),
              DropdownMenuItem(
                value: 'tr',
                child: Text('Türkçe'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                selectedLanguage = value ?? 'en';
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isBot = message['role'] == 'bot';
                  return Align(
                    alignment:
                        isBot ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: isBot
                            ? const Color.fromARGB(255, 218, 214, 214)
                            : Color.fromARGB(255, 103, 108, 167),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                          bottomLeft:
                              isBot ? Radius.circular(0) : Radius.circular(20),
                          bottomRight:
                              isBot ? Radius.circular(20) : Radius.circular(0),
                        ),
                      ),
                      child: Text(
                        message['content'] ?? '',
                        style: TextStyle(
                            color: isBot ? Colors.black : Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                  labelText: selectedLanguage == 'en'
                      ? 'Your message'
                      : 'Mesajınızı yazın',
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(color: Colors.blue, width: 2)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(color: Colors.black, width: 2))),
              onSubmitted: (value) async {
                if (value.isNotEmpty) {
                  setState(() {
                    _messages
                        .add({'role': 'user', 'content': _controller.text});
                  });
                  await generateResponse(_controller.text);
                  _controller.clear();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class OvalBottomBorderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 20);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 20);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
