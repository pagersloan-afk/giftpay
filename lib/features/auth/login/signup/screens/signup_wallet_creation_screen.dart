import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:utilityhub/features/wallet/services/virtual_account_service.dart';

class SignupWalletCreationScreen extends StatefulWidget {
  const SignupWalletCreationScreen({super.key});

  @override
  State<SignupWalletCreationScreen> createState() =>
      _SignupWalletCreationScreenState();
}

class _SignupWalletCreationScreenState
    extends State<SignupWalletCreationScreen> {
  bool loading = true;
  String? accountNumber;
  String? bankName;

  @override
  void initState() {
    super.initState();
    _createWallet();
  }

  Future<void> _createWallet() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // ⭐ Fetch real user profile from Firestore
    final userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    final data = userDoc.data() ?? {};

    final fullName = "${data["firstName"]} ${data["lastName"]}".trim();
    final email = data["email"];
    final phone = data["phone"];

    // ⭐ Now call backend with REAL data
    final va = await VirtualAccountService().fetchOrCreateFromBackend(
      userId: user.uid,
      name: fullName,
      email: email,
      phone: phone,
    );

    setState(() {
      accountNumber = va?.accountNumber;
      bankName = va?.bankName;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Creating Wallet")),
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Wallet Created!",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  Text("Bank: ${bankName ?? 'Unknown'}"),
                  Text("Account Number: ${accountNumber ?? 'Unavailable'}"),

                  const SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, "/login-success");
                    },
                    child: const Text("Continue"),
                  ),
                ],
              ),
      ),
    );
  }
}
