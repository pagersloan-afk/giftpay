import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';
import 'package:utilityhub/core/widgets/app_responsive_layout.dart';
import 'package:utilityhub/features/profile/sections/profile_next_step.dart';
import 'package:utilityhub/features/profile/sections/profile_summary_fields.dart';

import 'sections/profile_email.dart';
import 'sections/profile_header.dart';
import 'sections/profile_kyc_status.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool loading = true;
  String? loadError;
  Map<String, dynamic> data = {};

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (!mounted) return;
      setState(() {
        loading = false;
        loadError = 'Your session has ended. Please sign in again.';
      });
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      if (!mounted) return;
      setState(() {
        data = doc.data() ?? <String, dynamic>{};
        loading = false;
        loadError = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
        loadError = 'Unable to load your profile. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (loadError != null) {
      return Scaffold(
        appBar: const AppHeaderr(title: 'Profile'),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(loadError!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      loading = true;
                      loadError = null;
                    });
                    _loadProfile();
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: const AppHeaderr(title: 'Profile'),
      body: AppResponsiveLayout(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ProfileHeader(profileUrl: data['profileUrl'] as String?),
              ProfileEmail(email: user?.email ?? 'Email not available'),
              ProfileKycStatus(
                kycStatus: data['kycStatus'] as String? ?? 'unverified',
                rejectionReason: data['kycRejectionReason'] as String?,
              ),
              ProfileSummaryFields(data: data),
              ProfileNextStep(data: data),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/profile/manage'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4FC3F7),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Manage Account',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
