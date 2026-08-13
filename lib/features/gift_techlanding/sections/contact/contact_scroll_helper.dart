import 'package:flutter/material.dart';

void autoScroll(ScrollController controller) async {
  while (true) {
    try {
      if (!controller.hasClients) {
        await Future.delayed(const Duration(milliseconds: 500));
        continue;
      }

      await controller.animateTo(
        controller.position.maxScrollExtent,
        duration: const Duration(seconds: 12),
        curve: Curves.linear,
      );

      await controller.animateTo(
        controller.position.minScrollExtent,
        duration: const Duration(seconds: 12),
        curve: Curves.linear,
      );
    } catch (_) {
      break;
    }
  }
}
