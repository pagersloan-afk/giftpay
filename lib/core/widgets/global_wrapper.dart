import 'package:flutter/material.dart';
import 'package:utilityhub/core/widgets/giftpay_background.dart';

class GlobalWrapper extends StatelessWidget {
  final Widget child;

  const GlobalWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GiftPayBackground(child: child);
  }
}
