import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';

class SignupSuccessDialog {
  static void show(BuildContext context, AudioPlayer audioPlayer) {
    final confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    )..play();

    audioPlayer.play(AssetSource("sounds/success_beep.mp3"));

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
                      ConfettiWidget(
                        confettiController: confettiController,
                        blastDirectionality: BlastDirectionality.explosive,
                        emissionFrequency: 0.05,
                        numberOfParticles: 25,
                        maxBlastForce: 18,
                        minBlastForce: 5,
                        gravity: 0.3,
                      ),
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
        Navigator.pop(context);
      }
      Navigator.pushReplacementNamed(context, "/login");
      confettiController.dispose();
    });
  }
}
