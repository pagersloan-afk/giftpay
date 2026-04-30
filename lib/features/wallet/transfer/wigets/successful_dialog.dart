import 'package:flutter/material.dart';

Future<void> showTransferSuccessDialog({
  required BuildContext context,
  required String amount,
  required String name,
  required String bank,
  required String account,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return Dialog(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(22),
          width: 340,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06), // ⭐ transparent
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
              const Icon(
                Icons.check_circle,
                color: Color(0xFF4FC3F7),
                size: 70,
              ),

              const SizedBox(height: 16),

              const Text(
                "Success",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "You have successfully transferred NGN$amount to $name",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Bank Name: $bank\nAccount Number: $account",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.55)),
              ),

              const SizedBox(height: 20),

              // ⭐ GP‑1 WARNING BOX
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                ),
                child: Text(
                  "⚠️ Multifactor Authentication is required for transactions above ₦200,000.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.85)),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.picture_as_pdf, color: Color(0xFF4FC3F7)),
                  SizedBox(width: 10),
                  Icon(Icons.image, color: Color(0xFF4FC3F7)),
                ],
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4FC3F7),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "OK",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
