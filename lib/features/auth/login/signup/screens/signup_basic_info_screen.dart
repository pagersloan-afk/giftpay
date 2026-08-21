import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';

import 'package:utilityhub/core/widgets/app_responsive_layout.dart';
import 'package:utilityhub/features/auth/login/signup/controllers/signup_basic_controller.dart';
import 'package:utilityhub/features/auth/login/signup/widgets/name_fields.dart';
import 'package:utilityhub/features/auth/login/signup/widgets/password_section.dart';
import 'package:utilityhub/features/auth/login/signup/widgets/phone_country_field.dart';

import 'package:utilityhub/features/landing/widgets/landing_header.dart';

class SignupBasicInfoScreen extends StatefulWidget {
  const SignupBasicInfoScreen({super.key});

  @override
  State<SignupBasicInfoScreen> createState() => _SignupBasicInfoScreenState();
}

class _SignupBasicInfoScreenState extends State<SignupBasicInfoScreen> {
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  bool showPassword = false;
  bool showConfirmPassword = false;

  String strength = "";
  bool ruleMin = false;
  bool ruleUpper = false;
  bool ruleNum = false;
  bool ruleSpecial = false;

  Country? selectedCountry;

  @override
  void initState() {
    super.initState();

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

  void _checkStrength(String password) {
    final min = password.length >= 8;
    final upper = password.contains(RegExp(r'[A-Z]'));
    final num = password.contains(RegExp(r'[0-9]'));
    final special = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    setState(() {
      ruleMin = min;
      ruleUpper = upper;
      ruleNum = num;
      ruleSpecial = special;

      if (password.isEmpty) {
        strength = "";
      } else if (!min || (!upper && !num && !special)) {
        strength = "Weak";
      } else if (min && (upper || num) && !special) {
        strength = "Medium";
      } else {
        strength = "Strong";
      }
    });
  }

  Future<void> _goToIdentityScreen() async {
    try {
      final controller = SignupBasicController(
        firstName: firstNameCtrl.text.trim(),
        lastName: lastNameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
        country: selectedCountry!,
      );

      final uid = await controller.createBasicAccount(context);

      if (uid == null) return;

      // DO NOT show success dialog here.
      // DO NOT wait for email verification here.

      // Immediately route to VerifyEmailScreen.
      Navigator.pushReplacementNamed(
        context,
        "/verify-email",
        arguments: {
          "userId": uid,
          "firstName": firstNameCtrl.text.trim(),
          "lastName": lastNameCtrl.text.trim(),
          "email": emailCtrl.text.trim(),
          "phone": phoneCtrl.text.trim(),
          "country": selectedCountry!,
          "password": passwordCtrl.text.trim(),
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  void dispose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    confirmPasswordCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // =========================================================================
      // WEB
      //
      // Match LoginScreen:
      // /signup uses LandingHeader.
      // =========================================================================
      appBar: kIsWeb ? const LandingHeader() : null,

      body: AppResponsiveLayout(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),

                const Text(
                  "Create Account",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 32),

                NameFields(
                  firstNameCtrl: firstNameCtrl,
                  lastNameCtrl: lastNameCtrl,
                ),

                const SizedBox(height: 16),

                PhoneCountryField(
                  selectedCountry: selectedCountry,
                  phoneCtrl: phoneCtrl,
                  onSelect: (c) {
                    setState(() {
                      selectedCountry = c;
                    });
                  },
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                PasswordSection(
                  passwordCtrl: passwordCtrl,
                  confirmPasswordCtrl: confirmPasswordCtrl,
                  showPassword: showPassword,
                  showConfirmPassword: showConfirmPassword,
                  togglePassword: () {
                    setState(() {
                      showPassword = !showPassword;
                    });
                  },
                  toggleConfirmPassword: () {
                    setState(() {
                      showConfirmPassword = !showConfirmPassword;
                    });
                  },
                  onStrengthChange: _checkStrength,
                  strength: strength,
                  ruleMin: ruleMin,
                  ruleUpper: ruleUpper,
                  ruleNum: ruleNum,
                  ruleSpecial: ruleSpecial,
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _goToIdentityScreen,
                    child: const Text("Continue"),
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
