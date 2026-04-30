import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'keypad_button.dart';

class PinEntryDialog extends StatefulWidget {
  final VoidCallback onCompleted;
  final VoidCallback onChangeMethod;

  const PinEntryDialog({
    super.key,
    required this.onCompleted,
    required this.onChangeMethod,
  });

  @override
  State<PinEntryDialog> createState() => _PinEntryDialogState();
}

class _PinEntryDialogState extends State<PinEntryDialog> {
  final List<String> pin = ["", "", "", ""];
  int index = 0;

  void _addDigit(String value) {
    HapticFeedback.lightImpact();

    if (index < 4) {
      pin[index] = value;
      index++;
      setState(() {});
    }

    if (index == 4) {
      Navigator.pop(context);
      widget.onCompleted();
    }
  }

  void _deleteDigit() {
    HapticFeedback.lightImpact();

    if (index > 0) {
      index--;
      pin[index] = "";
      setState(() {});
    }
  }

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
              color: const Color(0xFF4FC3F7).withOpacity(0.12), // ⭐ cyan glow
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
            const Text(
              "PIN",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              "Please enter your PIN",
              style: TextStyle(color: Colors.white.withOpacity(0.55)),
            ),

            const SizedBox(height: 20),

            // ⭐ GP‑1 PIN DOTS (cyan glow + scale animation)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final filled = pin[i].isNotEmpty;

                return AnimatedScale(
                  scale: filled ? 1.25 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOutBack,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: filled
                          ? const Color(0xFF4FC3F7) // ⭐ cyan dot
                          : Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                      boxShadow: filled
                          ? [
                              BoxShadow(
                                color: const Color(
                                  0xFF4FC3F7,
                                ).withOpacity(0.45),
                                blurRadius: 12,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 24),

            // ⭐ GP‑1 KEYPAD
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 12,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.4,
              ),
              itemBuilder: (_, i) {
                if (i == 9) return const SizedBox();

                if (i == 10) {
                  return KeypadButton(label: "0", onTap: () => _addDigit("0"));
                }

                if (i == 11) {
                  return KeypadButton(label: "⌫", onTap: _deleteDigit);
                }

                return KeypadButton(
                  label: "${i + 1}",
                  onTap: () => _addDigit("${i + 1}"),
                );
              },
            ),

            const SizedBox(height: 14),

            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                widget.onChangeMethod();
              },
              child: Text(
                "Change Authentication Method",
                style: const TextStyle(
                  color: Color(0xFF4FC3F7),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
