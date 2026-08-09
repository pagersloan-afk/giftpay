import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:utilityhub/core/widgets/app_responsive_layout.dart';
import 'sections/management_form.dart';
import 'sections/management_buttons.dart';

class ManagementScreen extends StatefulWidget {
  const ManagementScreen({super.key});

  @override
  State<ManagementScreen> createState() => _ManagementScreenState();
}

class _ManagementScreenState extends State<ManagementScreen> {
  final user = FirebaseAuth.instance.currentUser;

  bool loading = true;
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
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get();

    data = doc.data() ?? {};

    nameCtrl.text = data["name"] ?? "";
    phoneCtrl.text = data["phone"] ?? "";
    addressCtrl.text = data["address"] ?? "";
    ninCtrl.text = data["nin"] ?? "";
    bvnCtrl.text = data["bvn"] ?? "";

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Account"),
        backgroundColor: const Color(0xFF0F1115),
      ),

      body: AppResponsiveLayout(
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
              userId: user!.uid,
            ),
          ],
        ),
      ),
    );
  }
}
