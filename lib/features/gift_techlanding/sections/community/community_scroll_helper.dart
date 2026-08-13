import 'package:flutter/material.dart';

Future<void> startAutoScroll(
  ScrollController controller,
  bool Function() isHovering,
) async {
  if (!controller.hasClients) return;

  while (true) {
    if (isHovering()) {
      await Future.delayed(const Duration(milliseconds: 500));
      continue;
    }

    final maxScroll = controller.position.maxScrollExtent;
    if (maxScroll <= 0) return;

    await controller.animateTo(
      maxScroll,
      duration: const Duration(seconds: 18),
      curve: Curves.linear,
    );

    await Future.delayed(const Duration(milliseconds: 800));

    await controller.animateTo(
      0,
      duration: const Duration(seconds: 18),
      curve: Curves.linear,
    );

    await Future.delayed(const Duration(milliseconds: 800));
  }
}
