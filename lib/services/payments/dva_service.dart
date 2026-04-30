import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class DVAService {
  Future<Map<String, dynamic>?> getDVA() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final url = Uri.parse("http://localhost:4000/paystack/virtual-account");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": user.uid}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["status"] == true) {
        return data["data"];
      }
    }

    return null;
  }
}
