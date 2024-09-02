import 'dart:convert';
import 'package:http/http.dart' as http;

final String openAiApiKey = '9070bb36762b4ddc8552f51b98091334';

Future<String> generatePurpose(String title) async {
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
        {
          'role': 'system',
          'content':
              'You are a helpful assistant that generates short purposes for habits.'
        },
        {
          'role': 'user',
          'content':
              'Write a short purpose for the habit titled "$title". Purpose should be concise and under 25 characters.'
        }
      ],
      'max_tokens': 25,
      'temperature': 0.7,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final purpose = data['choices'][0]['message']['content'].trim();
    return purpose;
  } else {
    throw Exception('Failed to generate purpose');
  }
}
