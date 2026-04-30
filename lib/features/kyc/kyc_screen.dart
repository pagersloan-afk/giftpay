import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:utilityhub/core/widgets/kyc_progress_steps.dart';

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  final picker = ImagePicker();
  final user = FirebaseAuth.instance.currentUser;

  int currentStep = 1;

  final ninCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final dobCtrl = TextEditingController();

  // ⭐ Use XFile instead of File (works on Web + Mobile)
  XFile? idFront;
  XFile? idBack;
  XFile? selfie;

  List<String> rejectedDocs = [];
  bool submitting = false;

  @override
  void initState() {
    super.initState();
    _loadRejectedDocs();
  }

  Future<void> _loadRejectedDocs() async {
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get();

    final data = doc.data() ?? {};

    setState(() {
      rejectedDocs = List<String>.from(data["kycRejectedDocs"] ?? []);
    });
  }

  Future<XFile?> pickImage() async {
    return await picker.pickImage(source: ImageSource.gallery);
  }

  // ⭐ Cross-platform Supabase upload
  Future<String> uploadFile(XFile file, String name) async {
    final supabase = Supabase.instance.client;
    final filePath = "kyc/${user!.uid}/$name.jpg";

    if (kIsWeb) {
      // ⭐ WEB: upload bytes
      Uint8List bytes = await file.readAsBytes();

      final response = await supabase.storage
          .from("kyc-documents")
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      if (response.isEmpty) throw Exception("Upload failed (web)");
    } else {
      // ⭐ MOBILE: upload file normally
      final response = await supabase.storage
          .from("kyc-documents")
          .upload(
            filePath,
            File(file.path),
            fileOptions: const FileOptions(upsert: true),
          );

      if (response.isEmpty) throw Exception("Upload failed (mobile)");
    }

    return supabase.storage.from("kyc-documents").getPublicUrl(filePath);
  }

  Future<void> submitKYC() async {
    if (idFront == null || idBack == null || selfie == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload all required documents")),
      );
      return;
    }

    try {
      setState(() => submitting = true);

      final frontUrl = await uploadFile(idFront!, "id_front");
      final backUrl = await uploadFile(idBack!, "id_back");
      final selfieUrl = await uploadFile(selfie!, "selfie");

      await FirebaseFirestore.instance.collection("users").doc(user!.uid).set({
        "nin": ninCtrl.text,
        "address": addressCtrl.text,
        "dob": dobCtrl.text,
        "kycStatus": "pending",

        "kycRejectionReason": null,
        "kycRejectedDocs": [],

        "kycDocuments": {
          "idFront": frontUrl,
          "idBack": backUrl,
          "selfie": selfieUrl,
        },
      }, SetOptions(merge: true));

      setState(() => submitting = false);

      Navigator.pushNamedAndRemoveUntil(context, "/kyc-success", (_) => false);
    } catch (e) {
      setState(() => submitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("KYC failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("KYC Verification")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "KYC Verification",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            KycProgressSteps(step: currentStep),

            const SizedBox(height: 30),

            // ⭐ STEP 1 — PERSONAL INFO
            if (currentStep == 1) ...[
              _input("NIN / BVN", ninCtrl),
              _input("Address", addressCtrl),
              _input("Date of Birth (YYYY-MM-DD)", dobCtrl),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (ninCtrl.text.isEmpty ||
                        addressCtrl.text.isEmpty ||
                        dobCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please fill all fields")),
                      );
                      return;
                    }
                    setState(() => currentStep = 2);
                  },
                  child: const Text("Continue"),
                ),
              ),
            ],

            // ⭐ STEP 2 — ID CARD UPLOAD
            if (currentStep == 2) ...[
              _uploadTile(
                label: "Upload ID Card (Front)",
                file: idFront,
                rejected: rejectedDocs.contains("idFront"),
                onTap: () async {
                  final f = await pickImage();
                  if (f != null) setState(() => idFront = f);
                },
              ),

              _uploadTile(
                label: "Upload ID Card (Back)",
                file: idBack,
                rejected: rejectedDocs.contains("idBack"),
                onTap: () async {
                  final f = await pickImage();
                  if (f != null) setState(() => idBack = f);
                },
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: idFront != null && idBack != null
                      ? () => setState(() => currentStep = 3)
                      : null,
                  child: const Text("Continue"),
                ),
              ),
            ],

            // ⭐ STEP 3 — SELFIE + SUBMIT
            if (currentStep == 3) ...[
              _uploadTile(
                label: "Upload Selfie",
                file: selfie,
                rejected: rejectedDocs.contains("selfie"),
                onTap: () async {
                  final f = await pickImage();
                  if (f != null) setState(() => selfie = f);
                },
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: submitting ? null : submitKYC,
                  child: submitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Submit Verification"),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _uploadTile({
    required String label,
    required XFile? file,
    required VoidCallback onTap,
    bool rejected = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: rejected ? Colors.red : Colors.black26,
            width: rejected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: rejected ? Colors.red.shade50 : null,
        ),
        child: Row(
          children: [
            Icon(
              file == null ? Icons.upload_file : Icons.check_circle,
              color: rejected
                  ? Colors.red
                  : file == null
                  ? Colors.grey
                  : Colors.green,
            ),
            const SizedBox(width: 12),
            Text(
              rejected
                  ? "$label (Rejected)"
                  : file == null
                  ? label
                  : "$label (Uploaded)",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: rejected
                    ? Colors.red
                    : file == null
                    ? Colors.black54
                    : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
