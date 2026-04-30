import 'package:flutter/material.dart';

class PSGamesScreen extends StatelessWidget {
  const PSGamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PS5 Games")),
      body: const Center(
        child: Text(
          "PS5 Games module coming soon...",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
