import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class GiftTechBackground extends StatefulWidget {
  final Widget child;

  const GiftTechBackground({super.key, required this.child});

  @override
  State<GiftTechBackground> createState() => _GiftTechBackgroundState();
}

class _GiftTechBackgroundState extends State<GiftTechBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // ⭐ Smooth animated gradient + glow pulses + particles
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;

        return SizedBox.expand(
          child: Stack(
            children: [
              // ⭐ Deep luxury gradient base
              _buildGradientLayer(t),

              // ⭐ Glow pulses (Meta-style)
              _buildGlowLayer(t),

              // ⭐ Floating particles (premium)
              _buildParticlesLayer(t),

              // ⭐ Faded Gift Technology watermark
              _buildWatermark(),

              // ⭐ Foreground content
              widget.child,
            ],
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // ⭐ Animated Gradient Layer
  // ------------------------------------------------------------
  Widget _buildGradientLayer(double t) {
    final shift = (t * 0.6);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-1 + shift, -1),
          end: Alignment(1, 1 - shift),
          colors: [
            const Color(0xFF0A0F1F), // deep navy
            const Color(0xFF111827), // blue-gray
            const Color(0xFF1E293B), // slate
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // ⭐ Glow Layer (soft blobs)
  // ------------------------------------------------------------
  Widget _buildGlowLayer(double t) {
    final glowShift = (0.5 + 0.5 * math.sin(2 * math.pi * t));

    return IgnorePointer(
      child: CustomPaint(
        painter: _GlowPainter(glowShift),
        child: const SizedBox.expand(),
      ),
    );
  }

  // ------------------------------------------------------------
  // ⭐ Particles Layer (floating dots)
  // ------------------------------------------------------------
  Widget _buildParticlesLayer(double t) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _ParticlesPainter(t),
        child: const SizedBox.expand(),
      ),
    );
  }

  // ------------------------------------------------------------
  // ⭐ Watermark Layer
  // ------------------------------------------------------------
  Widget _buildWatermark() {
    return Positioned.fill(
      child: Center(
        child: Opacity(
          opacity: 0.035,
          child: Image.asset(
            "assets/logo/gift_tech_logo.png", // parent brand watermark
            width: 520,
            height: 520,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// ⭐ Glow Painter (soft luxury blobs)
// ------------------------------------------------------------
class _GlowPainter extends CustomPainter {
  final double shift;
  _GlowPainter(this.shift);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 70);

    // Top-left glow
    paint.color = const Color(0xFF4A6BB8).withOpacity(0.25);
    canvas.drawCircle(
      Offset(size.width * (0.2 + 0.1 * shift), size.height * 0.2),
      160,
      paint,
    );

    // Bottom-right glow
    paint.color = const Color(0xFF273D68).withOpacity(0.22);
    canvas.drawCircle(
      Offset(size.width * (0.8 - 0.1 * shift), size.height * 0.85),
      200,
      paint,
    );

    // Center glow
    paint.color = Colors.white.withOpacity(0.05);
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * (0.45 + 0.05 * shift)),
      240,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _GlowPainter oldDelegate) =>
      oldDelegate.shift != shift;
}

// ------------------------------------------------------------
// ⭐ Particles Painter (floating dots)
// ------------------------------------------------------------
class _ParticlesPainter extends CustomPainter {
  final double t;
  _ParticlesPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.30);

    for (int i = 0; i < 22; i++) {
      final double progress = (t + i * 0.04) % 1.0;
      final double x = size.width * (0.1 + 0.8 * (i / 22));
      final double y = size.height * (0.1 + 0.8 * progress);

      canvas.drawCircle(Offset(x, y), 2.4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) =>
      oldDelegate.t != t;
}
