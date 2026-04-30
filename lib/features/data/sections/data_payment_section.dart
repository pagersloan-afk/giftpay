import 'package:flutter/material.dart';

class DataPaymentSection extends StatelessWidget {
  final TextEditingController phoneCtrl;
  final bool payWithWallet;
  final Color themeColor;
  final bool loading;
  final ValueChanged<bool> onPaymentMethodChanged;
  final VoidCallback onPay;

  const DataPaymentSection({
    super.key,
    required this.phoneCtrl,
    required this.payWithWallet,
    required this.themeColor,
    required this.loading,
    required this.onPaymentMethodChanged,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: phoneCtrl,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: "Phone Number",
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                value: true,
                groupValue: payWithWallet,
                onChanged: (v) => onPaymentMethodChanged(v!),
                title: const Text("Wallet"),
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                value: false,
                groupValue: payWithWallet,
                onChanged: (v) => onPaymentMethodChanged(v!),
                title: const Text("Card"),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor,
              foregroundColor: Colors.white,
            ),
            onPressed: loading ? null : onPay,
            child: loading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Buy Data"),
          ),
        ),
      ],
    );
  }
}
