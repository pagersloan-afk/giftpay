// lib/features/electricity/services/clubkonnect_service.dart
//
// ElectricityService
// - Talks to your backend only (never CK directly from Flutter)
// - Handles:
//   1) Fetch discos
//   2) Verify meter
//   3) Vend electricity (wallet / CK via backend)
//   4) Requery
//   5) Airtime & Data (unchanged)

import 'dart:convert';
import 'package:http/http.dart' as http;

class ElectricityService {
  // ⭐ Backend base URL
  final String baseUrl = "http://localhost:4000";

  // -------------------------------------------------------------
  // 1. FETCH DISCO LIST (Dynamic from ClubKonnect)
  // -------------------------------------------------------------
  Future<List<Map<String, dynamic>>> fetchDiscos() async {
    final uri = Uri.parse("$baseUrl/api/electricity/discos");
    final response = await http.get(uri);
    final data = jsonDecode(response.body);

    if (data["status"] == true) {
      return List<Map<String, dynamic>>.from(data["data"]);
    } else {
      return [];
    }
  }

  // -------------------------------------------------------------
  // 2. VERIFY METER (CK V1 via backend)
  // -------------------------------------------------------------
  Future<Map<String, dynamic>> verifyMeter({
    required String meterNumber,
    required String discoCode,
    required String meterType,
  }) async {
    final uri = Uri.parse("$baseUrl/api/electricity/verify-meter");

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "discoCode": discoCode,
        "meterNumber": meterNumber,
        "meterType": meterType,
      }),
    );

    return jsonDecode(response.body);
  }

  // -------------------------------------------------------------
  // 3. VEND ELECTRICITY (CK V1 via backend)
  //    Used for card flow (after Paystack success)
  // -------------------------------------------------------------
  Future<Map<String, dynamic>> buyElectricity({
    required String meterNumber,
    required String discoCode,
    required String amount,
    required String phone,
    required String meterType,
    required String userId,
  }) async {
    final uri = Uri.parse("$baseUrl/api/electricity/vend-electricity");

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "meterNumber": meterNumber,
        "discoCode": discoCode,
        "amount": amount,
        "phone": phone,
        "meterType": meterType,
        "userId": userId,
      }),
    );

    return jsonDecode(response.body);
  }

  // -------------------------------------------------------------
  // 4. REQUERY (CK V1 via backend)
  //    Used by ElectricityProcessingScreen (wallet flow)
  // -------------------------------------------------------------
  Future<Map<String, dynamic>> pollRequery({
    required String requestId,
    required String userId,
  }) async {
    final uri = Uri.parse("$baseUrl/api/electricity/requery");

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"requestId": requestId, "userId": userId}),
    );

    return jsonDecode(response.body);
  }

  // -------------------------------------------------------------
  // 5. Airtime (unchanged)
  // -------------------------------------------------------------
  Future<Map<String, dynamic>> buyAirtime({
    required String phone,
    required String amount,
    required String networkId,
    required String userId,
  }) async {
    final uri = Uri.parse("$baseUrl/vend-airtime");
    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "phone": phone,
        "amount": amount,
        "networkId": networkId,
        "userId": userId,
        "reference": "AIR-${DateTime.now().millisecondsSinceEpoch}",
      }),
    );
    return jsonDecode(response.body);
  }

  // -------------------------------------------------------------
  // 6. Data (unchanged)
  // -------------------------------------------------------------
  Future<Map<String, dynamic>> buyData({
    required String phone,
    required String networkId,
    required String variationCode,
    required String userId,
  }) async {
    final uri = Uri.parse("$baseUrl/vend-data");
    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "phone": phone,
        "networkId": networkId,
        "variationCode": variationCode,
        "userId": userId,
        "reference": "DATA-${DateTime.now().millisecondsSinceEpoch}",
      }),
    );
    return jsonDecode(response.body);
  }
}
