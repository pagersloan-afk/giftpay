import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:utilityhub/core/security/device_trust.dart';

class ManagementButtons extends StatefulWidget {
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController addressCtrl;
  final TextEditingController ninCtrl;
  final TextEditingController bvnCtrl;
  final String userId;

  const ManagementButtons({
    super.key,
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.addressCtrl,
    required this.ninCtrl,
    required this.bvnCtrl,
    required this.userId,
  });

  @override
  State<ManagementButtons> createState() => _ManagementButtonsState();
}

class _ManagementButtonsState extends State<ManagementButtons> {
  bool _saving = false;
  bool _loggingOut = false;

  Future<void> _save(BuildContext context) async {
    if (_saving) return;

    final name = widget.nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({
        'name': name,
        'phone': widget.phoneCtrl.text.trim(),
        'address': widget.addressCtrl.text.trim(),
        'nin': widget.ninCtrl.text.trim(),
        'bvn': widget.bvnCtrl.text.trim(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/profile',
        (route) => false,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to update your profile. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _logout(BuildContext context) async {
    if (_loggingOut) return;
    setState(() => _loggingOut = true);
    try {
      await DeviceTrust.clearDeviceTrust();
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to sign out. Please try again.')),
      );
      setState(() => _loggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saving || _loggingOut ? null : () => _save(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4FC3F7),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              _saving ? 'Saving...' : 'Save Changes',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saving || _loggingOut ? null : () => _logout(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              _loggingOut ? 'Signing out...' : 'Logout',
              style: const TextStyle(
                color: Colors.white,
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
