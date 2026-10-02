import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum PinVerificationStatus {
  success,
  invalid,
  locked,
  pinNotSet,
  authRequired,
  error,
}

class PinVerificationResult {
  final PinVerificationStatus status;
  final String? message;
  final DateTime? lockedUntil;

  const PinVerificationResult({
    required this.status,
    this.message,
    this.lockedUntil,
  });

  bool get isSuccess => status == PinVerificationStatus.success;

  bool get isLocked => status == PinVerificationStatus.locked;
}

class PinEntryDialog extends StatefulWidget {
  final Future<PinVerificationResult> Function(String pin) onCompleted;
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

  bool verifying = false;

  String? errorText;

  DateTime? lockedUntil;

  Timer? lockTimer;

  @override
  void dispose() {
    lockTimer?.cancel();
    super.dispose();
  }

  bool get isLocked {
    if (lockedUntil == null) {
      return false;
    }

    return DateTime.now().isBefore(lockedUntil!);
  }

  String _formatRemaining() {
    if (lockedUntil == null) {
      return "00:00";
    }

    final remaining = lockedUntil!.difference(DateTime.now());

    if (remaining.isNegative) {
      return "00:00";
    }

    final totalSeconds = remaining.inSeconds;

    final minutes = totalSeconds ~/ 60;

    final seconds = totalSeconds % 60;

    return "${minutes.toString().padLeft(2, '0')}:"
        "${seconds.toString().padLeft(2, '0')}";
  }

  void _startLockTimer(DateTime until) {
    lockTimer?.cancel();

    setState(() {
      lockedUntil = until;
      verifying = false;

      pin.fillRange(0, 4, "");
      index = 0;

      errorText = "Too many incorrect attempts.";
    });

    lockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        lockTimer?.cancel();
        return;
      }

      if (!DateTime.now().isBefore(until)) {
        lockTimer?.cancel();

        setState(() {
          lockedUntil = null;
          errorText = null;
        });

        return;
      }

      setState(() {});
    });
  }

  Future<void> _completePin() async {
    if (index != 4 || verifying || isLocked) {
      return;
    }

    final enteredPin = pin.join();

    setState(() {
      verifying = true;
      errorText = null;
    });

    try {
      final result = await widget.onCompleted(enteredPin);

      if (!mounted) {
        return;
      }

      if (result.status == PinVerificationStatus.success) {
        Navigator.pop(context, result);

        return;
      }

      if (result.status == PinVerificationStatus.locked) {
        final lockUntil = result.lockedUntil;

        if (lockUntil != null) {
          _startLockTimer(lockUntil);
        } else {
          setState(() {
            verifying = false;
            errorText =
                result.message ?? "Transaction PIN is temporarily locked.";
          });
        }

        return;
      }

      setState(() {
        verifying = false;

        pin.fillRange(0, 4, "");
        index = 0;

        switch (result.status) {
          case PinVerificationStatus.invalid:
            errorText = result.message ?? "Incorrect PIN. Please try again.";
            break;

          case PinVerificationStatus.pinNotSet:
            errorText = result.message ?? "Transaction PIN has not been set.";
            break;

          case PinVerificationStatus.authRequired:
            errorText = result.message ?? "Authentication is required.";
            break;

          case PinVerificationStatus.error:
            errorText =
                result.message ?? "Unable to verify PIN. Please try again.";
            break;

          case PinVerificationStatus.success:
          case PinVerificationStatus.locked:
            break;
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        verifying = false;

        pin.fillRange(0, 4, "");
        index = 0;

        errorText = "Unable to verify PIN. Please try again.";
      });
    }
  }

  void _addDigit(String value) {
    if (verifying || isLocked || index >= 4) {
      return;
    }

    HapticFeedback.lightImpact();

    pin[index] = value;
    index++;

    setState(() {});

    if (index == 4) {
      _completePin();
    }
  }

  void _deleteDigit() {
    if (verifying || isLocked || index <= 0) {
      return;
    }

    HapticFeedback.lightImpact();

    index--;

    pin[index] = "";

    setState(() {});
  }

  Widget _buildKeypadButton({
    required String label,
    required VoidCallback onTap,
    bool isBackspace = false,
  }) {
    final disabled = verifying || isLocked;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: disabled ? null : onTap,
        child: Container(
          decoration: BoxDecoration(
            color: disabled ? const Color(0xFF242424) : const Color(0xFF3A3A3A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(disabled ? 0.12 : 0.38),
              width: 1.2,
            ),
            boxShadow: disabled
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.22),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: disabled ? Colors.white.withOpacity(0.25) : Colors.white,
              fontSize: isBackspace ? 25 : 22,
              fontWeight: FontWeight.w700,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusMessage() {
    if (isLocked) {
      return Column(
        children: [
          const SizedBox(height: 6),

          const Icon(
            Icons.lock_clock_outlined,
            color: Colors.orangeAccent,
            size: 25,
          ),

          const SizedBox(height: 5),

          const Text(
            "PIN temporarily locked",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.orangeAccent,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            "Try again in ${_formatRemaining()}",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: 12,
            ),
          ),
        ],
      );
    }

    if (errorText == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const SizedBox(height: 6),

        Text(
          errorText!,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.redAccent.withOpacity(0.95),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    final screenWidth = MediaQuery.of(context).size.width;

    final maxDialogHeight = (screenHeight - 32).clamp(360.0, 760.0);

    final dialogWidth = screenWidth < 380 ? screenWidth - 28 : 330.0;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      backgroundColor: Colors.black.withOpacity(0.45),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 330, maxHeight: maxDialogHeight),
        child: SizedBox(
          width: dialogWidth,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.20),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A).withOpacity(0.85),
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.12),
                        ),
                      ),
                      child: Icon(
                        isLocked
                            ? Icons.lock_clock_outlined
                            : Icons.lock_outline,
                        color: isLocked ? Colors.orangeAccent : Colors.white,
                        size: 25,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      isLocked
                          ? "PIN Temporarily Locked"
                          : "Authentication Method",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withOpacity(0.95),
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      "PIN",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      isLocked
                          ? "For your security, PIN entry is temporarily disabled."
                          : verifying
                          ? "Verifying your GiftPay PIN..."
                          : "Enter the 4-digit PIN you created during signup",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.60),
                        fontSize: 13,
                      ),
                    ),

                    _buildStatusMessage(),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (i) {
                        final filled = pin[i].isNotEmpty;

                        return AnimatedScale(
                          scale: filled ? 1.2 : 1.0,
                          duration: const Duration(milliseconds: 150),
                          curve: Curves.easeOutBack,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.symmetric(horizontal: 7),
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: filled
                                  ? const Color(0xFF4FC3F7)
                                  : Colors.white.withOpacity(0.25),
                              shape: BoxShape.circle,
                              boxShadow: filled
                                  ? [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF4FC3F7,
                                        ).withOpacity(0.45),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 14),

                    Container(
                      color: Colors.black.withOpacity(0.20),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 2,
                      ),
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        childAspectRatio: 1.65,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                        children: [
                          for (int i = 1; i <= 9; i++)
                            _buildKeypadButton(
                              label: '$i',
                              onTap: () => _addDigit('$i'),
                            ),

                          const SizedBox.shrink(),

                          _buildKeypadButton(
                            label: '0',
                            onTap: () => _addDigit('0'),
                          ),

                          _buildKeypadButton(
                            label: '⌫',
                            isBackspace: true,
                            onTap: _deleteDigit,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    GestureDetector(
                      onTap: verifying || isLocked
                          ? null
                          : () {
                              Navigator.pop(context);

                              widget.onChangeMethod();
                            },
                      child: Text(
                        "Change Authentication Method",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: verifying || isLocked
                              ? Colors.white.withOpacity(0.20)
                              : const Color(0xFF4FC3F7),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
