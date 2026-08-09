import 'package:flutter/material.dart';

class ProfileKycStatus extends StatelessWidget {
  final String kycStatus;
  final String? rejectionReason;

  const ProfileKycStatus({
    super.key,
    required this.kycStatus,
    required this.rejectionReason,
  });

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    Color textColor;
    String label;

    if (kycStatus == "tier1") {
      badgeColor = Colors.blue.withOpacity(0.15);
      textColor = Colors.blueAccent;
      label = "TIER 1";
    } else if (kycStatus == "tier2") {
      badgeColor = Colors.purple.withOpacity(0.15);
      textColor = Colors.purpleAccent;
      label = "TIER 2";
    } else if (kycStatus == "verified") {
      badgeColor = Colors.green.withOpacity(0.15);
      textColor = Colors.greenAccent;
      label = "VERIFIED";
    } else {
      badgeColor = Colors.red.withOpacity(0.15);
      textColor = Colors.redAccent;
      label = kycStatus.toUpperCase();
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: badgeColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: textColor.withOpacity(0.4)),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 14),

        if (kycStatus == "rejected" && rejectionReason != null)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.red.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Reason for rejection:\n$rejectionReason",
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),

        if (kycStatus != "verified")
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, "/kyc"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4FC3F7),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              kycStatus == "rejected"
                  ? "Resubmit Verification"
                  : "Continue Verification",
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
      ],
    );
  }
}
