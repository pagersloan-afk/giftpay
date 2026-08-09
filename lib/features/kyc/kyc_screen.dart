import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:utilityhub/features/kyc/controllers/sections/kyc_step_id_upload.dart';
import 'package:utilityhub/features/kyc/controllers/sections/kyc_step_personal.dart';
import 'package:utilityhub/features/kyc/controllers/sections/kyc_step_selfie.dart';
import 'controllers/kyc_controller.dart';

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  final controller = KycController();

  int step = 1;
  bool submitting = false;

  Map<String, dynamic> userData = {};

  final ninCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final dobCtrl = TextEditingController();

  XFile? idFront;
  XFile? idBack;
  XFile? selfie;

  List<String> rejectedDocs = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    userData = await controller.loadUser();
    rejectedDocs = List<String>.from(userData["kycRejectedDocs"] ?? []);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("KYC Verification")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (step == 1)
              KycStepPersonal(
                userData: userData,
                ninCtrl: ninCtrl,
                addressCtrl: addressCtrl,
                dobCtrl: dobCtrl,
                onContinue: () => setState(() => step = 2),
              ),

            if (step == 2)
              KycStepIdUpload(
                idFront: idFront,
                idBack: idBack,
                rejectedDocs: rejectedDocs,
                pickImage: controller.pickImage,
                onContinue: () => setState(() => step = 3),

                // ⭐ REQUIRED CALLBACKS
                onFrontSelected: (file) => setState(() => idFront = file),
                onBackSelected: (file) => setState(() => idBack = file),
              ),

            if (step == 3)
              KycStepSelfie(
                selfie: selfie,
                rejectedDocs: rejectedDocs,
                submitting: submitting,
                pickImage: controller.pickImage,
                onSubmit: _submit,

                // ⭐ REQUIRED CALLBACK
                onSelfieSelected: (file) => setState(() => selfie = file),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (selfie == null || idFront == null || idBack == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload all documents")),
      );
      return;
    }

    setState(() => submitting = true);

    await controller.submitKyc(
      nin: ninCtrl.text,
      address: addressCtrl.text,
      dob: dobCtrl.text,
      idFront: idFront!,
      idBack: idBack!,
      selfie: selfie!,
    );

    setState(() => submitting = false);

    Navigator.pushNamedAndRemoveUntil(context, "/kyc-success", (_) => false);
  }
}
