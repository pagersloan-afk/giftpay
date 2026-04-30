import 'package:flutter/material.dart';

class GiftPaySuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final Map<String, String> details;
  final String? linkLabel;
  final VoidCallback? onLinkTap;
  final String? warning;
  final VoidCallback onOk;

  const GiftPaySuccessDialog({
    super.key,
    required this.title,
    required this.message,
    required this.details,
    required this.onOk,
    this.linkLabel,
    this.onLinkTap,
    this.warning,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Illustration
            Image.asset("assets/images/success.png", height: 80),

            const SizedBox(height: 12),

            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 8),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 16),

            // Details
            Column(
              children: details.entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        e.key,
                        style: const TextStyle(color: Colors.black54),
                      ),
                      Text(
                        e.value,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            if (linkLabel != null) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: onLinkTap,
                child: Text(
                  linkLabel!,
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],

            if (warning != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  warning!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // OK button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onOk,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("OK"),
              ),
            ),

            const SizedBox(height: 12),

            // Share options
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text("Share As: "),
                SizedBox(width: 8),
                Chip(label: Text("PDF")),
                SizedBox(width: 8),
                Chip(label: Text("Image")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
