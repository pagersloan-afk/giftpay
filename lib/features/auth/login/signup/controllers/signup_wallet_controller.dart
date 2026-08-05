import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:utilityhub/features/wallet/services/virtual_account_service.dart';

class SignupWalletController {
  Future<Map<String, dynamic>?> createWallet(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      // ⭐ Fetch real user profile from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      final data = userDoc.data() ?? {};

      final fullName = "${data["firstName"]} ${data["lastName"]}".trim();
      final email = data["email"];
      final phone = data["phone"];

      // ⭐ Call backend with REAL data
      final va = await VirtualAccountService().fetchOrCreateFromBackend(
        userId: user.uid,
        name: fullName,
        email: email,
        phone: phone,
      );

      if (va == null) return null;

      return {
        "accountNumber": va.accountNumber,
        "bankName": va.bankName,
        "accountName": va.accountName,
      };
    } catch (e) {
      if (!context.mounted) return null;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
      return null;
    }
  }
}
