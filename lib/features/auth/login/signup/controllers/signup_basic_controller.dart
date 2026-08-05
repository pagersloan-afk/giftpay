import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';

class SignupBasicController {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String password;
  final Country country;

  SignupBasicController({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
    required this.country,
  });

  Future<String?> createBasicAccount(BuildContext context) async {
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = cred.user!.uid;
      final fullPhone = "+${country.phoneCode}$phone";

      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "phone": fullPhone,
        "country": country.countryCode, // or country.name if you prefer
        "createdAt": DateTime.now(),
        "kycStatus": "pending",
        "onboardingStatus": "basic_created",
      }, SetOptions(merge: true)); // ⭐ important: never overwrite

      await cred.user!.sendEmailVerification();

      return uid;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
      return null;
    }
  }
}
