import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:utilityhub/features/auth/login/signup/controllers/signup_identity_controller.dart';
import 'package:utilityhub/features/auth/login/signup/screens/signup_pin_screen.dart';
import 'package:utilityhub/features/auth/login/signup/widgets/nin_bvn_section.dart';

class SignupIdentityScreen extends StatefulWidget {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final Country country;
  final String password;

  final TextEditingController ninCtrl;
  final TextEditingController bvnCtrl;

  const SignupIdentityScreen({
    super.key,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.country,
    required this.password,
    required this.ninCtrl,
    required this.bvnCtrl,
  });

  @override
  State<SignupIdentityScreen> createState() => _SignupIdentityScreenState();
}

class _SignupIdentityScreenState extends State<SignupIdentityScreen> {
  bool verifying = false;

  Future<void> _verifyAndContinue() async {
    setState(() => verifying = true);

    final controller = SignupIdentityController(
      userId: widget.userId,
      nin: widget.ninCtrl.text.trim(),
      bvn: widget.bvnCtrl.text.trim(),
    );

    final success = await controller.verifyIdentity(context);

    setState(() => verifying = false);

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          settings: const RouteSettings(name: "/signup-pin"),
          builder: (_) => const SignupPinScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify Identity")),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hi ${widget.firstName}, verify your identity",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),

                NinBvnSection(ninCtrl: widget.ninCtrl, bvnCtrl: widget.bvnCtrl),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: verifying ? null : _verifyAndContinue,
                    child: verifying
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Verify & Continue"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
