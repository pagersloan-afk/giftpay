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
  String? statusMessage;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _createWallet();
  }

  Future<void> _createWallet() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() { loading = false; errorMessage = 'Please sign in again.'; });
      return;
    }

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

    if (!mounted) return;
    if (va == null) {
      try {
        final status = await VirtualAccountService().getVirtualAccountStatus();
        setState(() {
          statusMessage = status['message']?.toString() ?? 'Your dedicated account is still being assigned. It will appear here once Paystack confirms it.';
          loading = false;
        });
      } catch (error) {
        setState(() { errorMessage = error.toString().replaceFirst('Exception: ', ''); loading = false; });
      }
      return;
    }
    setState(() {
      accountNumber = va.accountNumber;
      bankName = va.bankName;
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
                  if (accountNumber != null) ...[
                    const Text("Dedicated Account Ready!", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Text("Bank: ${bankName ?? 'Unknown'}"),
                    Text("Account Number: $accountNumber"),
                  ] else ...[
                    const Icon(Icons.hourglass_top, size: 42),
                    const SizedBox(height: 16),
                    const Text("Your wallet is being prepared", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(errorMessage ?? statusMessage ?? 'Your dedicated account is not ready yet.'),
                    const SizedBox(height: 16),
                    OutlinedButton(onPressed: () { setState(() { loading = true; errorMessage = null; }); _createWallet(); }, child: const Text('Check account status')),
                  ],
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
