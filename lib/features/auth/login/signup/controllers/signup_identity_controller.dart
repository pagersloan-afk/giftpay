import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:utilityhub/config/api.dart';

class SignupIdentityController {
  final String userId;
  final String nin;
  final String bvn;

  SignupIdentityController({
    required this.userId,
    required this.nin,
    required this.bvn,
  });

  Future<bool> verifyIdentity(BuildContext context) async {
    try {
      final backendResult = await _verifyWithBackend();

      if (!backendResult["success"]) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Identity verification failed")),
        );
        return false;
      }

      // ⭐ Tier1 after NIN or BVN verification
      final Map<String, dynamic> updateData = {
        "kycStatus": "tier1",
        "onboardingStatus": "identity_verified",
      };

      if (nin.isNotEmpty) updateData["nin"] = nin;
      if (bvn.isNotEmpty) updateData["bvn"] = bvn;

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .set(updateData, SetOptions(merge: true)); // merge safely

      return true;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
      return false;
    }
  }

  Future<Map<String, dynamic>> _verifyWithBackend() async {
    final url = Uri.parse(ApiConfig.api("/api/verify-identity"));

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nin": nin.isNotEmpty ? nin : null,
        "bvn": bvn.isNotEmpty ? bvn : null,
        "uid": userId,
      }),
    );

    if (response.statusCode != 200) {
      return {"success": false};
    }

    final data = jsonDecode(response.body);

    return {
      "success": data["status"] == "success",
      "tier": data["kycStatus"] ?? "tier1",
    };
  }
}
