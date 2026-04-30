import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';
import 'package:utilityhub/core/widgets/app_responsive_layout.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final picker = ImagePicker();

  String? profileUrl;
  bool loading = true;

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final ninCtrl = TextEditingController();

  String kycStatus = "unverified";
  String? kycRejectionReason;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get();

    final data = doc.data() ?? {};

    setState(() {
      profileUrl = data["profileUrl"];
      nameCtrl.text = data["name"] ?? "";
      phoneCtrl.text = data["phone"] ?? "";
      addressCtrl.text = data["address"] ?? "";
      ninCtrl.text = data["nin"] ?? "";
      kycStatus = data["kycStatus"] ?? "unverified";
      kycRejectionReason = data["kycRejectionReason"];
      loading = false;
    });
  }

  Future<void> _uploadProfileImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final file = File(picked.path);
    final ref = FirebaseStorage.instance.ref(
      "profile_pictures/${user!.uid}.jpg",
    );

    await ref.putFile(file);
    final url = await ref.getDownloadURL();

    await FirebaseFirestore.instance.collection("users").doc(user!.uid).update({
      "profileUrl": url,
    });

    setState(() => profileUrl = url);
  }

  Future<void> _saveProfile() async {
    await FirebaseFirestore.instance.collection("users").doc(user!.uid).update({
      "name": nameCtrl.text,
      "phone": phoneCtrl.text,
      "address": addressCtrl.text,
      "nin": ninCtrl.text,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully")),
    );
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: const AppHeaderr(title: "Profile"),

      body: AppResponsiveLayout(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              // ⭐ Premium Profile Picture
              GestureDetector(
                onTap: _uploadProfileImage,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4FC3F7).withOpacity(0.20),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white12,
                    backgroundImage: profileUrl != null
                        ? NetworkImage(profileUrl!)
                        : null,
                    child: profileUrl == null
                        ? const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white70,
                          )
                        : null,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ⭐ Email
              Text(
                user!.email!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFE5E7EB),
                ),
              ),

              const SizedBox(height: 26),

              // ⭐ KYC Status Section
              _buildKycStatus(),

              const SizedBox(height: 30),

              // ⭐ Editable Fields
              _input("Full Name", nameCtrl),
              _input("Phone Number", phoneCtrl),
              _input("Address", addressCtrl),
              _input("NIN / BVN", ninCtrl),

              const SizedBox(height: 20),

              // ⭐ Save Profile Button
              _primaryButton("Save Profile", _saveProfile),

              const SizedBox(height: 40),

              // ⭐ Logout Button
              _dangerButton("Logout", () => logout(context)),
            ],
          ),
        ),
      ),
    );
  }

  // ⭐ KYC Status UI
  Widget _buildKycStatus() {
    Color badgeColor;
    Color textColor;

    if (kycStatus == "verified") {
      badgeColor = Colors.green.withOpacity(0.15);
      textColor = Colors.greenAccent;
    } else if (kycStatus == "pending") {
      badgeColor = Colors.orange.withOpacity(0.15);
      textColor = Colors.orangeAccent;
    } else {
      badgeColor = Colors.red.withOpacity(0.15);
      textColor = Colors.redAccent;
    }

    return Column(
      children: [
        // ⭐ Premium KYC Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: badgeColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: textColor.withOpacity(0.4)),
          ),
          child: Text(
            kycStatus.toUpperCase(),
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),

        const SizedBox(height: 14),

        // ⭐ Rejection Reason
        if (kycStatus == "rejected" && kycRejectionReason != null)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.red.withOpacity(0.25)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Reason for rejection:\n$kycRejectionReason",
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

        // ⭐ Continue / Resubmit Button
        if (kycStatus != "verified")
          _primaryButton(
            kycStatus == "rejected"
                ? "Resubmit Verification"
                : "Continue Verification",
            () => Navigator.pushNamed(context, "/kyc"),
          ),
      ],
    );
  }

  // ⭐ Premium Input Field
  Widget _input(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: ctrl,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.06),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF4FC3F7)),
          ),
        ),
      ),
    );
  }

  // ⭐ Primary Button (Cyan)
  Widget _primaryButton(String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4FC3F7),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  // ⭐ Danger Button (Red)
  Widget _dangerButton(String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
