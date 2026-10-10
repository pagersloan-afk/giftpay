import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:utilityhub/core/widgets/app_responsive_layout.dart';

import 'sections/management_buttons.dart';
import 'sections/management_form.dart';

class ManagementScreen extends StatefulWidget {
  const ManagementScreen({super.key});

  @override
  State<ManagementScreen> createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen> {
  bool loading = true;
  String? loadError;
  Map<String, dynamic> data = {};

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final ninCtrl = TextEditingController();
  final bvnCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
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
          .doc(user.uid)
          .get();
      final loadedData = doc.data() ?? <String, dynamic>{};
      final savedName = loadedData['name'];
      final firstName = loadedData['firstName'];
      final lastName = loadedData['lastName'];
      final registeredName = [
        if (firstName is String && firstName.trim().isNotEmpty)
          firstName.trim(),
        if (lastName is String && lastName.trim().isNotEmpty)
          lastName.trim(),
      ].join(' ');

      if (!mounted) return;
      setState(() {
        data = loadedData;
        nameCtrl.text = savedName is String && savedName.trim().isNotEmpty
            ? savedName.trim()
            : registeredName;
        phoneCtrl.text = loadedData['phone'] is String
            ? loadedData['phone'] as String
            : '';
        addressCtrl.text = loadedData['address'] is String
            ? loadedData['address'] as String
            : '';
        ninCtrl.text = loadedData['nin'] is String
            ? loadedData['nin'] as String
            : '';
        bvnCtrl.text = loadedData['bvn'] is String
            ? loadedData['bvn'] as String
            : '';
        loading = false;
        loadError = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
        loadError = 'Unable to load your account details. Please try again.';
      });
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
    ninCtrl.dispose();
    bvnCtrl.dispose();
    super.dispose();
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
        appBar: AppBar(
          title: const Text('Manage Account'),
          backgroundColor: const Color(0xFF0F1115),
        ),
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

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in again.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Account'),
        backgroundColor: const Color(0xFF0F1115),
      ),
      body: AppResponsiveLayout(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              ManagementForm(
                nameCtrl: nameCtrl,
                phoneCtrl: phoneCtrl,
                addressCtrl: addressCtrl,
                ninCtrl: ninCtrl,
                bvnCtrl: bvnCtrl,
              ),
              ManagementButtons(
                nameCtrl: nameCtrl,
                phoneCtrl: phoneCtrl,
                addressCtrl: addressCtrl,
                ninCtrl: ninCtrl,
                bvnCtrl: bvnCtrl,
                userId: user.uid,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
