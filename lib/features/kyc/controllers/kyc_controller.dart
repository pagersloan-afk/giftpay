import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KycController {
  final user = FirebaseAuth.instance.currentUser;
  final picker = ImagePicker();

  Future<Map<String, dynamic>> loadUser() async {
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get();
    return doc.data() ?? {};
  }

  Future<XFile?> pickImage() async {
    return await picker.pickImage(source: ImageSource.gallery);
  }

  Future<String> uploadFile(XFile file, String name) async {
    final supabase = Supabase.instance.client;
    final filePath = "kyc/${user!.uid}/$name.jpg";

    if (kIsWeb) {
      Uint8List bytes = await file.readAsBytes();
      await supabase.storage
          .from("kyc-documents")
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );
    } else {
      await supabase.storage
          .from("kyc-documents")
          .upload(
            filePath,
            File(file.path),
            fileOptions: const FileOptions(upsert: true),
          );
    }

    return supabase.storage.from("kyc-documents").getPublicUrl(filePath);
  }

  Future<void> submitKyc({
    required String nin,
    required String address,
    required String dob,
    required XFile idFront,
    required XFile idBack,
    required XFile selfie,
  }) async {
    final frontUrl = await uploadFile(idFront, "id_front");
    final backUrl = await uploadFile(idBack, "id_back");
    final selfieUrl = await uploadFile(selfie, "selfie");

    await FirebaseFirestore.instance.collection("users").doc(user!.uid).set({
      "nin": nin,
      "address": address,
      "dob": dob,
      "kycStatus": "pending",
      "kycRejectionReason": null,
      "kycRejectedDocs": [],
      "kycDocuments": {
        "idFront": frontUrl,
        "idBack": backUrl,
        "selfie": selfieUrl,
      },
    }, SetOptions(merge: true));
  }
}
