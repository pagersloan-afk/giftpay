import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:utilityhub/config/api.dart';

class UserServicesApi {
  // Save user layout to backend
  static Future<void> saveLayout({
    required String userId,
    required List<String> services,
  }) async {
    final base = await ApiConfig.baseUrl;
    final url = Uri.parse("$base/user/services/save");

    await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": userId, "services": services}),
    );
  }

  // Load user layout from backend
  static Future<List<String>?> loadLayout(String userId) async {
    final base = await ApiConfig.baseUrl;
    final url = Uri.parse("$base/user/services/$userId");

    final res = await http.get(url);

    if (res.statusCode != 200) return null;

    final data = jsonDecode(res.body);

    if (data["status"] != true) return null;

    if (data["services"] == null) return null;

    return List<String>.from(data["services"]);
  }

  // Log service usage analytics
  static Future<void> logUsage({
    required String userId,
    required String serviceName,
    required String device,
  }) async {
    final base = await ApiConfig.baseUrl;
    final url = Uri.parse("$base/analytics/service-usage");

    await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "serviceName": serviceName,
        "device": device,
      }),
    );
  }
}
