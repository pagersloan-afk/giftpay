import 'package:flutter/material.dart';

class ProfileNextStep extends StatelessWidget {
  final Map<String, dynamic> data;

  const ProfileNextStep({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final kyc = data["kycStatus"] ?? "unverified";
    final hasNin = data["nin"] != null;
    final hasBvn = data["bvn"] != null;

    String nextStep;

    if (kyc == "tier1") {
      if (hasNin && !hasBvn) {
        nextStep = "Verify BVN";
      } else if (!hasNin && hasBvn) {
        nextStep = "Verify NIN";
      } else {
        nextStep = "Face Verification";
      }
    } else if (kyc == "tier2") {
      nextStep = "Address Verification";
    } else if (kyc == "verified") {
      nextStep = "KYC Completed";
    } else {
      nextStep = "Start Verification";
    }

    return Column(
      children: [
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, "/kyc"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4FC3F7),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              nextStep,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
