import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:utilityhub/core/widgets/app_responsive_layout.dart';

// Premium dialog + phone dependencies
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:country_picker/country_picker.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  bool loading = false;
  bool showPassword = false;
  bool showConfirmPassword = false;

  // Password strength + rules
  String passwordStrength = "";
  bool ruleMinLength = false;
  bool ruleUppercase = false;
  bool ruleNumber = false;
  bool ruleSpecial = false;

  // Country picker
  Country? selectedCountry;

  // Audio
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    // Default to Nigeria
    selectedCountry = Country(
      phoneCode: '234',
      countryCode: 'NG',
      e164Sc: 0,
      geographic: true,
      level: 1,
      name: 'Nigeria',
      example: '8021234567',
      displayName: 'Nigeria',
      displayNameNoCountryCode: 'Nigeria',
      e164Key: '',
    );
  }

  @override
  void dispose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // ⭐ Password rules + strength (Opay-style)
  void _checkPasswordStrength(String password) {
    final hasMinLength = password.length >= 8;
    final hasUpper = password.contains(RegExp(r'[A-Z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    final hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    setState(() {
      ruleMinLength = hasMinLength;
      ruleUppercase = hasUpper;
      ruleNumber = hasNumber;
      ruleSpecial = hasSpecial;

      if (password.isEmpty) {
        passwordStrength = "";
      } else if (!hasMinLength || (!hasUpper && !hasNumber && !hasSpecial)) {
        passwordStrength = "Weak";
      } else if (hasMinLength && (hasUpper || hasNumber) && !hasSpecial) {
        passwordStrength = "Medium";
      } else {
        passwordStrength = "Strong";
      }
    });
  }

  Color _strengthColor() {
    switch (passwordStrength) {
      case "Weak":
        return Colors.red;
      case "Medium":
        return Colors.orange;
      case "Strong":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildRuleItem(String text, bool passed) {
    return Row(
      children: [
        Icon(
          passed ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: passed ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: passed ? Colors.green : Colors.grey,
            fontWeight: passed ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  void _pickCountry() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (Country country) {
        setState(() {
          selectedCountry = country;
        });
      },
    );
  }

  Future<void> signUp() async {
    if (passwordCtrl.text.trim() != confirmPasswordCtrl.text.trim()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    if (selectedCountry == null || phoneCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid phone number")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      // 1. Create Firebase Auth user
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
      );

      final uid = cred.user!.uid;

      // 2. Build full international phone number (+2348123456789)
      final fullPhone =
          '+${selectedCountry!.phoneCode}${phoneCtrl.text.trim()}';

      // 3. Save user profile to Firestore
      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "firstName": firstNameCtrl.text.trim(),
        "lastName": lastNameCtrl.text.trim(),
        "phone": fullPhone,
        "email": emailCtrl.text.trim(),
        "createdAt": DateTime.now(),
      });

      // 4. Send email verification
      await cred.user!.sendEmailVerification();

      if (!mounted) return;

      // 5. Show premium success dialog
      _showPremiumSuccessDialog();
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'Signup failed')));
    }

    setState(() => loading = false);
  }

  void _showPremiumSuccessDialog() {
    final confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    )..play();

    _audioPlayer.play(AssetSource("sounds/success_beep.mp3"));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.scale(
                  scale: 0.9 + (0.1 * value),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Confetti behind dialog
                      ConfettiWidget(
                        confettiController: confettiController,
                        blastDirectionality: BlastDirectionality.explosive,
                        emissionFrequency: 0.05,
                        numberOfParticles: 25,
                        maxBlastForce: 18,
                        minBlastForce: 5,
                        gravity: 0.3,
                      ),
                      // Premium rectangular dialog
                      Container(
                        width: 320,
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 24,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 70,
                              color: Colors.green.shade600,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Account Created",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "A verification email has been sent.\nPlease verify your email to continue.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (Navigator.of(context).canPop()) {
        Navigator.pop(context); // close dialog
      }
      Navigator.pushReplacementNamed(context, "/login");
      confettiController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppResponsiveLayout(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const Text(
                  "Create Account",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),

                // ⭐ FIRST NAME FIELD
                TextField(
                  controller: firstNameCtrl,
                  decoration: const InputDecoration(
                    labelText: "First Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // ⭐ LAST NAME FIELD
                TextField(
                  controller: lastNameCtrl,
                  decoration: const InputDecoration(
                    labelText: "Last Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // ⭐ PHONE WITH COUNTRY PICKER
                Row(
                  children: [
                    InkWell(
                      onTap: _pickCountry,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: Row(
                          children: [
                            Text(
                              selectedCountry != null
                                  ? '+${selectedCountry!.phoneCode}'
                                  : '+',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: "Phone Number",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Email
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Password with eye icon + strength + rules
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: passwordCtrl,
                      obscureText: !showPassword,
                      onChanged: _checkPasswordStrength,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            showPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() => showPassword = !showPassword);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (passwordStrength.isNotEmpty)
                      Text(
                        "Strength: $passwordStrength",
                        style: TextStyle(
                          color: _strengthColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const SizedBox(height: 8),
                    _buildRuleItem("At least 8 characters", ruleMinLength),
                    _buildRuleItem(
                      "At least one uppercase letter",
                      ruleUppercase,
                    ),
                    _buildRuleItem("At least one number", ruleNumber),
                    _buildRuleItem(
                      "At least one special character",
                      ruleSpecial,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Confirm Password
                TextField(
                  controller: confirmPasswordCtrl,
                  obscureText: !showConfirmPassword,
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        showConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(
                          () => showConfirmPassword = !showConfirmPassword,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : signUp,
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Sign Up"),
                  ),
                ),
                const SizedBox(height: 20),

                // ⭐ LOGIN ROUTE
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, "/login");
                      },
                      child: const Text("Login"),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
