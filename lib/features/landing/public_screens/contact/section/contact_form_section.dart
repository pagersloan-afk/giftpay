import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui'; // ⭐ Needed for glass blur

class ContactFormSection extends StatefulWidget {
  const ContactFormSection({super.key});

  @override
  State<ContactFormSection> createState() => _ContactFormSectionState();
}

class _ContactFormSectionState extends State<ContactFormSection> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.post(
          Uri.parse("https://giftpayhq.com/api/contact"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "name": _nameController.text,
            "email": _emailController.text,
            "phone": _phoneController.text,
            "message": _messageController.text,
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Message sent successfully")),
          );
          _formKey.currentState!.reset();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Submission failed: ${response.statusCode}"),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      // ⭐ Fully transparent so animation shows through
      color: Colors.transparent,

      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 24 : 60,
      ),
      alignment: Alignment.center,

      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),

        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),

          child: BackdropFilter(
            // ⭐ Glass blur effect
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),

            child: Container(
              // ⭐ Glass background
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12), // transparent glass
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withOpacity(0.25), // subtle glass border
                  width: 1.2,
                ),
              ),

              padding: EdgeInsets.all(isMobile ? 20 : 32),

              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ⭐ Premium heading
                      Text(
                        "Contact GiftPay",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: isMobile ? 24 : 30,
                          fontWeight: FontWeight.w700,
                          color: Colors.white, // ⭐ White text on glass
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 24),

                      _buildLabel("Full Name"),
                      _buildInput(_nameController),

                      _buildLabel("Email Address"),
                      _buildInput(_emailController, email: true),

                      _buildLabel("Phone Number"),
                      _buildInput(_phoneController, phone: true),

                      _buildLabel("Message"),
                      _buildInput(
                        _messageController,
                        maxLines: isMobile ? 4 : 6,
                      ),

                      const SizedBox(height: 28),

                      // ⭐ Luxury CTA button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.18),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: isMobile ? 14 : 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            "Send Message",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: isMobile ? 16 : 18,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ⭐ Glass label
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: Colors.white, // ⭐ White on glass
        ),
      ),
    );
  }

  // ⭐ Glass input field
  Widget _buildInput(
    TextEditingController controller, {
    bool email = false,
    bool phone = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: phone
          ? TextInputType.phone
          : email
          ? TextInputType.emailAddress
          : TextInputType.text,

      style: const TextStyle(color: Colors.white),

      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.08), // ⭐ glass fill

        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.25)),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white, width: 1.6),
        ),
      ),

      validator: (value) => value == null || value.isEmpty ? "Required" : null,
    );
  }
}
