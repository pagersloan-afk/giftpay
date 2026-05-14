import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:utilityhub/config/api.dart';

class VirtualAccountService {
  Future<Map<String, dynamic>?> fetchOrCreateVA() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final res = await http.post(
      Uri.parse(ApiConfig.api("/paystack/virtual-account")),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": user.uid,
        "email": user.email,
        "name": user.displayName ?? "GiftPay User",
      }),
    );

    final data = jsonDecode(res.body);
    if (data["status"] == true) {
      return data["data"];
    }

    return null;
  }
}
