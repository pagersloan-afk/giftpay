import 'package:flutter/material.dart';

class AuthMethodDialog extends StatelessWidget {
  final VoidCallback onPinSelected;
  final VoidCallback onSecurePassSelected;
  final ValueChanged<bool> onSaveOptionChanged;

  const AuthMethodDialog({
    super.key,
    required this.onPinSelected,
    required this.onSecurePassSelected,
    required this.onSaveOptionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 330,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06), // ⭐ GP‑1 transparent
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.12), // ⭐ soft border
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4FC3F7).withOpacity(0.12), // ⭐ glow
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ⭐ Modern lock icon
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: const Icon(
                Icons.lock_outline,
                color: Colors.white,
                size: 28,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              "Authentication Method",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white.withOpacity(0.95),
              ),
            ),

            const SizedBox(height: 6),
            Text(
              "Select preferred method",
              style: TextStyle(color: Colors.white.withOpacity(0.55)),
            ),

            const SizedBox(height: 20),

            // ⭐ PIN BUTTON
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onPinSelected();
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: Colors.white.withOpacity(0.35)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "PIN",
                  style: TextStyle(
                    color: Color(0xFF4FC3F7),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ⭐ SECURE PASS BUTTON
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onSecurePassSelected();
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: Colors.white.withOpacity(0.35)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Secure Pass",
                  style: TextStyle(
                    color: Color(0xFF4FC3F7),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ⭐ SAVE OPTION SWITCH
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Save this option for future transactions",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.75),
                    ),
                  ),
                ),
                StatefulBuilder(
                  builder: (context, setState) {
                    bool value = false;
                    return Switch(
                      value: value,
                      onChanged: (v) {
                        value = v;
                        setState(() {});
                        onSaveOptionChanged(v);
                      },
                      activeThumbColor: const Color(0xFF4FC3F7),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
