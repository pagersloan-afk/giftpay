import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SidebarUserHeader extends StatelessWidget {
  const SidebarUserHeader({super.key});

  static const Color accent = Color(0xFF4FC3F7);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return _buildHeader(
        context: context,
        firstName: "GiftPay",
        lastName: "User",
        kycStatus: "unverified",
        profileUrl: null,
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        // ----------------------------------------------------------
        // Loading state
        // ----------------------------------------------------------

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return _buildLoadingHeader();
        }

        // ----------------------------------------------------------
        // Firestore data
        // ----------------------------------------------------------

        final data = snapshot.data?.data() ?? {};

        final rawFirstName = data["firstName"]?.toString().trim() ?? "";
        final rawLastName = data["lastName"]?.toString().trim() ?? "";

        final firstName = rawFirstName.isNotEmpty ? rawFirstName : "GiftPay";

        final lastName = rawLastName.isNotEmpty ? rawLastName : "User";

        final kycStatus =
            data["kycStatus"]?.toString().trim().toLowerCase() ?? "unverified";

        final rawProfileUrl = data["profileUrl"]?.toString().trim();

        final profileUrl = rawProfileUrl != null && rawProfileUrl.isNotEmpty
            ? rawProfileUrl
            : null;

        return _buildHeader(
          context: context,
          firstName: firstName,
          lastName: lastName,
          kycStatus: kycStatus,
          profileUrl: profileUrl,
        );
      },
    );
  }

  // ================================================================
  // HEADER
  // ================================================================

  Widget _buildHeader({
    required BuildContext context,
    required String firstName,
    required String lastName,
    required String kycStatus,
    required String? profileUrl,
  }) {
    // --------------------------------------------------------------
    // KYC badge
    // --------------------------------------------------------------

    late final String badgeText;
    late final Color badgeColor;

    switch (kycStatus) {
      case "tier1":
        badgeText = "Tier 1";
        badgeColor = Colors.blueAccent;
        break;

      case "tier2":
        badgeText = "Tier 2";
        badgeColor = Colors.purpleAccent;
        break;

      case "verified":
        badgeText = "Verified";
        badgeColor = Colors.greenAccent;
        break;

      case "pending":
        badgeText = "Pending";
        badgeColor = Colors.orangeAccent;
        break;

      default:
        badgeText = "Unverified";
        badgeColor = Colors.redAccent;
    }

    // --------------------------------------------------------------
    // Profile image
    // --------------------------------------------------------------

    final hasProfileImage = profileUrl != null && profileUrl.trim().isNotEmpty;

    // --------------------------------------------------------------
    // Full name
    // --------------------------------------------------------------

    final fullName = "$firstName $lastName".trim();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        children: [
          // ==========================================================
          // AVATAR
          // ==========================================================
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, "/profile");
            },
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
                    color: accent.withOpacity(0.20),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white24,

                // ----------------------------------------------------
                // Uploaded profile picture
                // ----------------------------------------------------
                backgroundImage: hasProfileImage
                    ? NetworkImage(profileUrl!)
                    : null,

                // ----------------------------------------------------
                // Default avatar
                // ----------------------------------------------------
                child: !hasProfileImage
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // ==========================================================
          // NAME + KYC
          // ==========================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ----------------------------------------------------
                // Full name
                // ----------------------------------------------------
                Text(
                  fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    letterSpacing: 0.2,
                  ),
                ),

                const SizedBox(height: 2),

                // ----------------------------------------------------
                // GiftPay user + KYC badge
                // ----------------------------------------------------
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        "giftpay user",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.55),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // =================================================
                    // KYC BADGE
                    // =================================================
                    Flexible(
                      child: Container(
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: badgeColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // LOADING HEADER
  // ================================================================

  Widget _buildLoadingHeader() {
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
                width: 100,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              const SizedBox(height: 6),

              Container(
                width: 70,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
