import 'package:flutter/material.dart';

class PasswordSection extends StatelessWidget {
  final TextEditingController passwordCtrl;
  final TextEditingController confirmPasswordCtrl;

  final bool showPassword;
  final bool showConfirmPassword;

  final VoidCallback togglePassword;
  final VoidCallback toggleConfirmPassword;

  final Function(String) onStrengthChange;

  final String strength;
  final bool ruleMin;
  final bool ruleUpper;
  final bool ruleNum;
  final bool ruleSpecial;

  const PasswordSection({
    super.key,
    required this.passwordCtrl,
    required this.confirmPasswordCtrl,
    required this.showPassword,
    required this.showConfirmPassword,
    required this.togglePassword,
    required this.toggleConfirmPassword,
    required this.onStrengthChange,
    required this.strength,
    required this.ruleMin,
    required this.ruleUpper,
    required this.ruleNum,
    required this.ruleSpecial,
  });

  Color _strengthColor() {
    switch (strength) {
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

  Widget _rule(String text, bool ok) {
    return Row(
      children: [
        Icon(
          ok ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: ok ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: ok ? Colors.green : Colors.grey,
            fontWeight: ok ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: passwordCtrl,
          obscureText: !showPassword,
          onChanged: onStrengthChange,
          decoration: InputDecoration(
            labelText: "Password",
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(
                showPassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: togglePassword,
            ),
          ),
        ),
        const SizedBox(height: 6),

        if (strength.isNotEmpty)
          Text(
            "Strength: $strength",
            style: TextStyle(
              color: _strengthColor(),
              fontWeight: FontWeight.w600,
            ),
          ),

        const SizedBox(height: 8),

        _rule("At least 8 characters", ruleMin),
        _rule("At least one uppercase letter", ruleUpper),
        _rule("At least one number", ruleNum),
        _rule("At least one special character", ruleSpecial),

        const SizedBox(height: 16),

        TextField(
          controller: confirmPasswordCtrl,
          obscureText: !showConfirmPassword,
          decoration: InputDecoration(
            labelText: "Confirm Password",
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(
                showConfirmPassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: toggleConfirmPassword,
            ),
          ),
        ),
      ],
    );
  }
}
