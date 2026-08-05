import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      final encryptedPin = _encryptPin(pin);

      await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
        "transactionPin": encryptedPin,
        "onboardingStatus": "pin_set",
      }, SetOptions(merge: true)); // ⭐ merge, keep all previous fields

      return true;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
      return false;
    }
  }

  String _encryptPin(String pin) {
    // TODO: Replace with real encryption
    return "enc_$pin";
  }
}
