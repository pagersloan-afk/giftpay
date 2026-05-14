import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:utilityhub/config/api.dart';

class DvaSection extends StatefulWidget {
  const DvaSection({super.key});

  @override
  State<DvaSection> createState() => _DvaSectionState();
}

class _DvaSectionState extends State<DvaSection> {
  bool loading = true;
  Map<String, dynamic>? dva;
  String? error;

  @override
  void initState() {
    super.initState();
    loadDVA();
  }

  Future<void> loadDVA() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          loading = false;
          error = "No user";
        });
        return;
      }

      // ⚠️ IMPORTANT: localhost only works on web running on same machine.
      // If you're on emulator/device, change this to your machine IP or 10.0.2.2.
      final url = Uri.parse(ApiConfig.api("/paystack/virtual-account"));

      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": user.uid}),
      );

      if (!mounted) return;

      if (res.statusCode != 200) {
        setState(() {
          loading = false;
          error = "HTTP ${res.statusCode}";
        });
        return;
      }

      final data = jsonDecode(res.body);
      debugPrint("[DVA] response: $data");

      if (data["status"] == true && data["data"] != null) {
        setState(() {
          dva = data["data"] as Map<String, dynamic>;
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
          error = "No DVA data";
        });
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint("[DVA] error: $e");
      setState(() {
        loading = false;
        error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: LinearProgressIndicator(),
      );
    }

    if (dva == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade200,
        ),
        child: Text(
          error ?? "No virtual account yet",
          style: const TextStyle(fontSize: 14),
        ),
      );
    }

    final accountNumber = dva!["account_number"]?.toString() ?? "----";
    final bankName = dva!["bank_name"]?.toString() ?? "";
    final accountName = dva!["account_name"]?.toString() ?? "";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color.fromARGB(255, 28, 29, 29), Color(0xFF1E88E5)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your Virtual Account",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            accountNumber,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            bankName,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            accountName,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
