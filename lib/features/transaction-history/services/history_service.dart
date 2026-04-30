import 'dart:convert';
import 'package:http/http.dart' as http;

class HistoryService {
  static Future<List<dynamic>> fetchHistory(String userId) async {
    final url = Uri.parse(
      "http://localhost:4000/transaction-history?userId=$userId",
    );

    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);

      if (data["status"] == true) {
        return data["data"];
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
