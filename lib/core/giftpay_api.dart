import 'dart:convert';
import 'package:http/http.dart' as http;

class GiftPayAPI {
  static const String baseUrl = "http://localhost:4000";

  static Future<dynamic> get(String path) async {
    final uri = Uri.parse("$baseUrl$path");
    final res = await http.get(uri);

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body);
    }

    throw Exception("GET request failed: ${res.statusCode}");
  }

  static Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse("$baseUrl$path");
    final res = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body);
    }

    throw Exception("POST request failed: ${res.statusCode}");
  }
}
