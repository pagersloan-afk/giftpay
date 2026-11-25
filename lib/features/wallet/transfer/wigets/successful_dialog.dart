import 'package:flutter/material.dart';

import '../transfer_success_screen.dart';

/// Kept under its existing name so current call sites remain compatible.
/// This now opens a dedicated success page instead of a modal dialog.
Future<void> showTransferSuccessDialog({
  required BuildContext context,
  required String amount,
  required String name,
  required String bank,
  required String account,
  String? reference,
}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => TransferSuccessScreen(
        amount: amount,
        name: name,
        bank: bank,
        account: account,
        reference: reference,
      ),
    ),
  );
}
