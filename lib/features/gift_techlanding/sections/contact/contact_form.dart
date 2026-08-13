import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:utilityhub/config/api.dart';
import 'dart:convert';

import 'vibration_card.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class ContactForm extends StatefulWidget {
  final bool isMobile;

  const ContactForm({super.key, required this.isMobile});

  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  bool _sending = false;

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();

    if (name.isEmpty || email.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    setState(() => _sending = true);

    try {
      // ⭐ 1. WRITE TO FIRESTORE
      await FirebaseFirestore.instance.collection("contactMessages").add({
        "name": name,
        "email": email,
        "subject": subject,
        "message": message,
        "timestamp": FieldValue.serverTimestamp(),
      });

      // ⭐ 2. SEND EMAIL TO YOUR BACKEND ENGINE
      final response = await http.post(
        Uri.parse(ApiConfig.api("/api/contact")), // YOUR BACKEND
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "subject": subject,
          "message": message,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Message sent successfully")),
        );

        _nameController.clear();
        _emailController.clear();
        _subjectController.clear();
        _messageController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Email failed: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    return VibrationCard(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(widget.isMobile ? 20 : 32),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.65),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.30), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Send Us a Message",
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: widget.isMobile ? 22 : 26,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 24),

            _inputField("Full Name", controller: _nameController),
            const SizedBox(height: 16),

            _inputField("Email Address", controller: _emailController),
            const SizedBox(height: 16),

            _inputField("Subject", controller: _subjectController),
            const SizedBox(height: 16),

            _inputField("Message", controller: _messageController, maxLines: 5),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _sending ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: GiftPayTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: widget.isMobile ? 30 : 40,
                  vertical: widget.isMobile ? 16 : 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                _sending ? "Sending..." : "Send Message",
                style: const TextStyle(
                  fontFamily: 'SegoeUI',
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(
    String label, {
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black87),
        border: const OutlineInputBorder(),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black38),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
      style: const TextStyle(color: Colors.black),
    );
  }
}
