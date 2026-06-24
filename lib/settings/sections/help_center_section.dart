import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help Center"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF0F1115),
      body: const Center(
        child: Text(
          "Help Center Articles Coming Soon",
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}
