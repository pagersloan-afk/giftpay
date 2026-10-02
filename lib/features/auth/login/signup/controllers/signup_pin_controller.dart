import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:utilityhub/config/api.dart';

class SignupPinController {
  final String pin;
  final String confirmPin;

  SignupPinController({required this.pin, required this.confirmPin});

  bool pinsMatch() => pin == confirmPin && pin.length == 4;

  Future<bool> savePin(BuildContext context) async {
    if (!pinsMatch()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("PINs do not match")));
      return false;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      // The PIN is never stored directly in Firestore by the Flutter client.
      // The authenticated backend generates a unique salt and stores a
      // scrypt-derived hash. The Firebase ID token binds this request to
      // the currently signed-in user.
      final idToken = await user.getIdToken(true);

      if (idToken == null || idToken.isEmpty) {
        throw Exception("Unable to authenticate PIN setup");
      }

      final response = await http.post(
        Uri.parse(ApiConfig.api("/api/transaction-pin/set")),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $idToken",
        },
        body: jsonEncode({"pin": pin, "confirmPin": confirmPin}),
      );

      Map<String, dynamic> data = {};
      try {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {}

      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          data["status"] != true) {
        throw Exception(data["message"] ?? "Unable to secure transaction PIN");
      }

      // Keep onboarding state in the same user document as before.
      await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
        "onboardingStatus": "pin_set",
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
      return false;
    }
  }
}
