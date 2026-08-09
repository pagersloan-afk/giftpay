import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SidebarUserHeader extends StatelessWidget {
  const SidebarUserHeader({super.key});

  Future<Map<String, dynamic>> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return {"firstName": "GiftPay User", "kycStatus": "unverified"};
    }

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    final data = doc.data() ?? {};

    return {
      "firstName": data["firstName"] ?? "GiftPay User",
      "kycStatus": data["kycStatus"] ?? "unverified",
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchUserData(),
      builder: (context, snapshot) {
        // ⭐ Prevent overflow flash
        if (!snapshot.hasData) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              children: [
                // Avatar shimmer
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),

                // Text shimmer
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 80,
                      height: 14,
                      color: Colors.white.withOpacity(0.15),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 60,
                      height: 12,
                      color: Colors.white.withOpacity(0.10),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        final firstName = snapshot.data!["firstName"];
        final kycStatus = snapshot.data!["kycStatus"];

        // ⭐ KYC Tier Logic
        late final String badgeText;
        late final Color badgeColor;

        if (kycStatus == "tier1") {
          badgeText = "Tier 1";
          badgeColor = Colors.blueAccent;
        } else if (kycStatus == "tier2") {
          badgeText = "Tier 2";
          badgeColor = Colors.purpleAccent;
        } else if (kycStatus == "verified") {
          badgeText = "Verified";
          badgeColor = Colors.greenAccent;
        } else if (kycStatus == "pending") {
          badgeText = "Pending";
          badgeColor = Colors.orangeAccent;
        } else {
          badgeText = "Unverified";
          badgeColor = Colors.redAccent;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Row(
            children: [
              // ⭐ Avatar (click → profile)
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, "/profile"),
                child: Container(
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
              ),

              const SizedBox(width: 12),

              // ⭐ Name + KYC Badge
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
