import 'package:flutter/material.dart';
import 'package:utilityhub/features/food/food_merchant_access.dart';
import 'package:utilityhub/features/food/food_merchant_screen.dart';

Future<void> openFoodMerchantDashboard(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);

  try {
    final allowed = await FoodMerchantAccess.check();

    if (!context.mounted) return;

    if (!allowed) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            icon: const Icon(Icons.lock_outline_rounded, size: 34),
            title: const Text('Merchant access required'),
            content: const Text(
              'This account is not authorized to manage GiftPay Food.',
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      return;
    }

    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const FoodMerchantScreen()));
  } catch (e) {
    if (!context.mounted) return;

    messenger.showSnackBar(
      SnackBar(
        content: Text(e.toString().replaceFirst('Exception: ', '')),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
