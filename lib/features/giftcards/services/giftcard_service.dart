import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:utilityhub/config/api.dart';

class GiftCardService {
  Future<String> buyGiftCard({
    required String brand,
    required String cardType,
    required String usdAmount, // ⭐ USD value (e.g. "500")
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user!.getIdToken();

    final url = ApiConfig.api("/api/giftcard/buy");

    final res = await http.post(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "userId": user.uid,
        "brand": brand,
        "cardType": cardType,
        "usdAmount": usdAmount, // ⭐ send USD to backend
      }),
    );

    final data = jsonDecode(res.body);

    if (data["status"] != true) {
      throw Exception(data["message"]);
    }

    return data["code"]; // ⭐ real gift card code from backend
  }

  Future<Map<String, dynamic>> getQuote({
    required String brand,
    required String cardType,
    required String usdAmount,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user!.getIdToken();

    final url = ApiConfig.api("/api/giftcard/quote");

    final res = await http.post(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "brand": brand,
        "cardType": cardType,
        "usdAmount": usdAmount,
      }),
    );

    final data = jsonDecode(res.body);

    if (data["status"] != true) {
      throw Exception(data["message"]);
    }

    return {"fxRate": data["fxRate"], "nairaToCharge": data["nairaToCharge"]};
  }
}
