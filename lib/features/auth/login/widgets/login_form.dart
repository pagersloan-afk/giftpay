import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:utilityhub/core/security/device_trust.dart';
import 'package:utilityhub/core/security/remembered_account_service.dart';
import 'package:utilityhub/features/auth/email_otp_screen.dart';
import 'package:utilityhub/features/auth/login/login_success_screen.dart';
import 'package:utilityhub/features/auth/reset/reset_password_screen.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  bool loading = false;
  bool showPassword = false;
  bool checkingRememberedAccount = true;
  bool passwordStep = false;
  String? rememberedEmail;

  @override
  void initState() {
    super.initState();
    _loadRememberedAccount();
  }

  Future<void> _loadRememberedAccount() async {
    final email = await RememberedAccountService.getEmail();

    if (!mounted) return;

    setState(() {
      rememberedEmail = email;
      checkingRememberedAccount = false;
      passwordStep = email != null;
    });

    if (email != null) {
      emailCtrl.text = email;
    }
  }

  Future<void> _continueToPassword() async {
    final email = emailCtrl.text.trim().toLowerCase();

    if (!_isValidEmail(email)) {
      _showMessage('Please enter a valid email address.');
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      emailCtrl.text = email;
      passwordStep = true;
    });
  }

  void _changeAccount() {
    FocusScope.of(context).unfocus();
    passwordCtrl.clear();

    setState(() {
      passwordStep = false;
      showPassword = false;
    });
  }

  Future<void> _useRememberedAccount() async {
    final email = await RememberedAccountService.getEmail();
    if (!mounted) return;

    if (email == null) {
      _changeAccount();
      return;
    }

    setState(() {
      rememberedEmail = email;
      emailCtrl.text = email;
      passwordCtrl.clear();
      passwordStep = true;
      showPassword = false;
    });
  }

  Future<void> login() async {
    if (loading) return;

    final email = emailCtrl.text.trim().toLowerCase();
    final password = passwordCtrl.text;

    if (!_isValidEmail(email)) {
      _showMessage('Please enter a valid email address.');
      return;
    }

    if (password.isEmpty) {
      _showMessage('Please enter your password.');
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() => loading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Remember only the account identifier. Never store the password.
      await RememberedAccountService.saveEmail(email);

      if (!mounted) return;

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        _showMessage('Unable to complete sign in. Please try again.');
        return;
      }

      if (!user.emailVerified) {
        Navigator.pushReplacementNamed(context, '/verify-email');
        return;
      }

      final trusted = await DeviceTrust.isTrustedDevice(user.uid);

      if (!mounted) return;

      if (!trusted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => EmailOtpScreen(email: email)),
        );
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginSuccessScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showMessage(_friendlyAuthError(e));
    } catch (e) {
      if (!mounted) return;
      _showMessage('Unable to sign in right now. Please try again.');
      debugPrint('Login error: $e');
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  String _friendlyAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Incorrect email or password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many sign-in attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'operation-not-allowed':
        return 'Email and password sign-in is currently unavailable.';
      default:
        return 'Unable to sign in. Please check your details and try again.';
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (checkingRememberedAccount) {
      return const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 10),

        const Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          passwordStep
              ? 'Enter your password to continue.'
              : 'Sign in to your GiftPay account.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70),
        ),

        const SizedBox(height: 28),

        if (passwordStep) ...[
          _buildRememberedAccountHeader(),
          const SizedBox(height: 24),
          _buildPasswordField(),
          const SizedBox(height: 12),
          _buildForgotPassword(),
          const SizedBox(height: 16),
          _buildPrimaryButton(
            label: 'Sign In',
            onPressed: loading ? null : login,
          ),
        ] else ...[
          _buildEmailField(),
          const SizedBox(height: 16),
          _buildPrimaryButton(
            label: 'Continue',
            onPressed: loading ? null : _continueToPassword,
          ),
        ],

        const SizedBox(height: 24),

        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            TextButton(
              onPressed: passwordStep ? _changeAccount : _useRememberedAccount,
              child: Text(
                passwordStep
                    ? 'Use another account'
                    : 'Use a different account',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),

        const SizedBox(height: 4),

        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text(
              "Don't have an account? ",
              style: TextStyle(color: Colors.white70),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/signup'),
              child: const Text(
                'Sign Up',
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRememberedAccountHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.16),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_outline, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Signing in as',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
                const SizedBox(height: 3),
                Text(
                  emailCtrl.text,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: loading ? null : _changeAccount,
            child: const Text(
              'Change',
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: emailCtrl,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.continueAction,
      autocorrect: false,
      enableSuggestions: false,
      style: const TextStyle(color: Colors.white),
      onSubmitted: (_) => _continueToPassword(),
      decoration: _inputDecoration('Email'),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: passwordCtrl,
      obscureText: !showPassword,
      textInputAction: TextInputAction.done,
      style: const TextStyle(color: Colors.white),
      onSubmitted: (_) => login(),
      decoration: _inputDecoration('Password').copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            showPassword ? Icons.visibility : Icons.visibility_off,
            color: Colors.white70,
          ),
          onPressed: () {
            setState(() => showPassword = !showPassword);
          },
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blueAccent),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: loading
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ResetPasswordScreen(),
                  ),
                );
              },
        child: const Text(
          'Forgot Password?',
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          disabledBackgroundColor: Colors.blueAccent.withOpacity(0.45),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
