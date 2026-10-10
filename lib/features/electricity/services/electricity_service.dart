import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:utilityhub/config/api.dart';

class ElectricityService {
  final String baseUrl = ApiConfig.baseUrl;

  Future<List<Map<String, dynamic>>> fetchDiscos() async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/electricity/discos"),
    );
    final data = jsonDecode(response.body);

    if (data["status"] == true) {
      return List<Map<String, dynamic>>.from(data["data"] ?? const []);
    }

    throw Exception(data["message"] ?? "Failed to fetch electricity providers");
  }

  Future<List<Map<String, dynamic>>> fetchProducts({
    required String billerCode,
  }) async {
    final response = await http.get(
      Uri.parse(
        "$baseUrl/api/electricity/products/${Uri.encodeComponent(billerCode)}",
      ),
    );
    final data = jsonDecode(response.body);

    if (data["status"] == true) {
      return List<Map<String, dynamic>>.from(data["products"] ?? const []);
    }

    throw Exception(data["message"] ?? "Failed to fetch electricity products");
  }

  Future<Map<String, dynamic>> verifyMeter({
    required String meterNumber,
    required String billerCode,
    required String productCode,
    String meterType = "",
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/electricity/verify-meter"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "meterNumber": meterNumber,
        "billerCode": billerCode,
        "productCode": productCode,
        "meterType": meterType,
      }),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> payElectricity({
    required String userId,
    required String meterNumber,
    required String billerCode,
    required String productCode,
    required String amount,
    required String phone,
    String meterType = "",
    String validationReference = "",
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/electricity/wallet/pay-electricity"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "meterNumber": meterNumber,
        "billerCode": billerCode,
        "productCode": productCode,
        "amount": amount,
        "phone": phone,
        "meterType": meterType,
        if (validationReference.isNotEmpty)
          "validationReference": validationReference,
      }),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> requery({
    required String userId,
    required String reference,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/electricity/requery"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "requestId": reference,
      }),
    );

    return jsonDecode(response.body);
  }
}
