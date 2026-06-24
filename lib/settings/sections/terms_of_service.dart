import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Terms of Service")),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Text("Your GiftPay Terms of Service go here."),
      ),
    );
  }
}
