import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileHeader extends StatefulWidget {
  final String? profileUrl;

  const ProfileHeader({super.key, required this.profileUrl});

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  final picker = ImagePicker();
  final userId = FirebaseAuth.instance.currentUser!.uid;

  Future<void> _upload() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final file = File(picked.path);
    final ref = FirebaseStorage.instance.ref("profile_pictures/$userId.jpg");

    await ref.putFile(file);
    final url = await ref.getDownloadURL();

    await FirebaseFirestore.instance.collection("users").doc(userId).update({
      "profileUrl": url,
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _upload,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.15), width: 2),
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
          backgroundImage: widget.profileUrl != null
              ? NetworkImage(widget.profileUrl!)
              : null,
          child: widget.profileUrl == null
              ? const Icon(Icons.person, size: 50, color: Colors.white70)
              : null,
        ),
      ),
    );
  }
}
