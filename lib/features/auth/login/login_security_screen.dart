import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginSecurityScreen extends StatelessWidget {
  const LoginSecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Login & Security")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Account Email",
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? "Unknown",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            ListTile(
              title: const Text("Change Password"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, "/change-password"),
            ),

            ListTile(
              title: const Text("Two‑Factor Authentication"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, "/2fa"),
            ),

            ListTile(
              title: const Text("Trusted Devices"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, "/linked-devices"),
            ),
          ],
        ),
      ),
    );
  }
}
