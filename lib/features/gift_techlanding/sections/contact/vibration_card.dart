import 'dart:math' as math;
import 'package:flutter/material.dart';

class VibrationCard extends StatefulWidget {
  final Widget child;

  const VibrationCard({super.key, required this.child});

  @override
  State<VibrationCard> createState() => _VibrationCardState();
}

class _VibrationCardState extends State<VibrationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double vibration = 0.5 * math.sin(_controller.value * 2 * math.pi);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(vibration, vibration),
          child: Container(
            foregroundDecoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.05),
                  Colors.white.withOpacity(0.02),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}
