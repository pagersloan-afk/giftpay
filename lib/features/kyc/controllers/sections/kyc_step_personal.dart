import 'package:flutter/material.dart';

class KycStepPersonal extends StatelessWidget {
  final Map<String, dynamic> userData;
  final TextEditingController ninCtrl;
  final TextEditingController addressCtrl;
  final TextEditingController dobCtrl;
  final VoidCallback onContinue;

  const KycStepPersonal({
    super.key,
    required this.userData,
    required this.ninCtrl,
    required this.addressCtrl,
    required this.dobCtrl,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final hasNin =
        userData["nin"] != null && userData["nin"].toString().isNotEmpty;
    final hasBvn =
        userData["bvn"] != null && userData["bvn"].toString().isNotEmpty;

    String requiredLabel;

    if (hasNin && !hasBvn) {
      requiredLabel = "BVN (Required)";
    } else if (!hasNin && hasBvn) {
      requiredLabel = "NIN (Required)";
    } else {
      requiredLabel = "NIN / BVN";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _input(requiredLabel, ninCtrl),
        _input("Address", addressCtrl),
        _input("Date of Birth (YYYY-MM-DD)", dobCtrl),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (ninCtrl.text.isEmpty ||
                  addressCtrl.text.isEmpty ||
                  dobCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill all fields")),
                );
                return;
              }
              onContinue();
            },
            child: const Text("Continue"),
          ),
        ),
      ],
    );
  }

  Widget _input(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
