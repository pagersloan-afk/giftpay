import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SidebarUserHeader extends StatelessWidget {
  const SidebarUserHeader({super.key});

  Future<Map<String, dynamic>> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return {"firstName": "GiftPay User", "kycStatus": "pending"};
    }

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    final data = doc.data() ?? {};
    return {
      "firstName": data["firstName"] ?? "GiftPay User",
      "kycStatus": data["kycStatus"] ?? "pending",
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchUserData(),
      builder: (context, snapshot) {
        final firstName = snapshot.data?["firstName"] ?? "GiftPay User";
        final kycStatus = snapshot.data?["kycStatus"] ?? "pending";

        // ⭐ Badge styling
        final bool isVerified = kycStatus.toLowerCase() == "verified";
        final Color badgeColor = isVerified
            ? Colors.greenAccent
            : Colors.orangeAccent;
        final String badgeText = isVerified ? "Verified" : "Pending";

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Row(
            children: [
              // ⭐ Avatar ring with soft border + glow
              Container(
                padding: const EdgeInsets.all(2.2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.20),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4FC3F7).withOpacity(0.20),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white),
                ),
              ),

              const SizedBox(width: 12),

              // ⭐ Premium typography + KYC badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    firstName,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      letterSpacing: 0.2,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Row(
                    children: [
                      Text(
                        "giftpay user",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.55),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      const SizedBox(width: 8),

                      // ⭐ KYC Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor.withOpacity(0.20),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: badgeColor.withOpacity(0.40),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            color: badgeColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
