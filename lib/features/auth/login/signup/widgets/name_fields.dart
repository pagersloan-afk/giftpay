import 'package:flutter/material.dart';

class NameFields extends StatelessWidget {
  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;

  const NameFields({
    super.key,
    required this.firstNameCtrl,
    required this.lastNameCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: firstNameCtrl,
          decoration: const InputDecoration(
            labelText: "First Name",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: lastNameCtrl,
          decoration: const InputDecoration(
            labelText: "Last Name",
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
