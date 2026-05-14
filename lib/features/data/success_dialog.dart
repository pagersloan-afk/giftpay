import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:utilityhub/core/widgets/giftpay_background.dart';
import 'package:intl/intl.dart';

void showDataSuccessDialog({
  required BuildContext context,
  required String phone,
  required String planName,
  required String amount,
  required String message,
}) {
  final player = AudioPlayer();

  // Format amount
  final formatter = NumberFormat.currency(
    locale: "en_NG",
    symbol: "₦",
    decimalDigits: 2,
  );

  final parsedAmount = double.tryParse(amount) ?? 0;
  final formattedAmount = formatter.format(parsedAmount);

  // Play success sound
  player.play(AssetSource("sounds/success_beep.mp3"), volume: 1.0);

  // Use rootNavigator to avoid null context crash
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: GiftPayBackground(
          child: Center(
            child: Container(
              width: 350,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.18),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ICON
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      size: 70,
                      color: Colors.green.shade400,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Data Purchase Successful!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // DETAILS CARD
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                    ),
                    child: Column(
                      children: [
                        _detailRow("Phone Number", phone),
                        const SizedBox(height: 12),
                        _detailRow("Plan", planName),
                        const SizedBox(height: 12),
                        _detailRow("Amount", formattedAmount),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(
                          dialogContext,
                          rootNavigator: true,
                        ).pushNamedAndRemoveUntil('/home', (route) => false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Done",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget _detailRow(String title, String value) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: const TextStyle(fontSize: 15, color: Colors.white70)),
      Text(
        value,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    ],
  );
}
