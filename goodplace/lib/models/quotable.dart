import 'dart:convert';
import 'package:http/http.dart' as http;

class QuotableService {
  final String baseUrl = "https://api.quotable.io";

  Future<List<dynamic>> fetchQuotes() async {
    final response = await http.get(Uri.parse("$baseUrl/quotes"));

    if (response.statusCode == 200) {
      return json.decode(response.body)['results'];
    } else {
      throw Exception('Failed to load quotes');
    }
  }
}
