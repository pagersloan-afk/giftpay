import 'dart:math' as math;

import 'package:flutter/material.dart';

class GiftPayBackground extends StatefulWidget {
  final Widget child;

  const GiftPayBackground({super.key, required this.child});

  @override
  State<GiftPayBackground> createState() => _GiftPayBackgroundState();
}

class _GiftPayBackgroundState extends State<GiftPayBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 28),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          const _GiftPayNightBase(),

          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _GiftPayEcosystemPainter(
                      progress: _controller.value,
                    ),
                  );
                },
              ),
            ),
          ),

          // Extremely subtle central GiftPay watermark.
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Opacity(
                  opacity: 0.018,
                  child: Image.asset(
                    'assets/logo/giftpay_1.png',
                    width: 520,
                    height: 520,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          widget.child,
        ],
      ),
    );
  }
}

/* ================================================================
   NIGHT BASE
================================================================ */

class _GiftPayNightBase extends StatelessWidget {
  const _GiftPayNightBase();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF030507),
            Color(0xFF070A0F),
            Color(0xFF090D13),
            Color(0xFF05070A),
          ],
          stops: [0.0, 0.34, 0.68, 1.0],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Deep blue atmospheric haze.
          Positioned(
            top: -180,
            right: -160,
            child: _AtmosphereGlow(
              size: 440,
              color: const Color(0xFF1478C8),
              opacity: 0.055,
              blur: 80,
            ),
          ),

          // Muted violet atmospheric haze.
          Positioned(
            bottom: -220,
            left: -180,
            child: _AtmosphereGlow(
              size: 500,
              color: const Color(0xFF6846B8),
              opacity: 0.045,
              blur: 100,
            ),
          ),

          // Very faint cyan atmosphere.
          Positioned(
            top: 280,
            left: -160,
            child: _AtmosphereGlow(
              size: 360,
              color: const Color(0xFF27B6D6),
              opacity: 0.025,
              blur: 95,
            ),
          ),

          // Almost invisible white atmospheric depth.
          Positioned(
            top: 80,
            left: 100,
            child: _AtmosphereGlow(
              size: 260,
              color: Colors.white,
              opacity: 0.012,
              blur: 80,
            ),
          ),
        ],
      ),
    );
  }
}

class _AtmosphereGlow extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;
  final double blur;

  const _AtmosphereGlow({
    required this.size,
    required this.color,
    required this.opacity,
    required this.blur,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(opacity),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(opacity),
            blurRadius: blur,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }
}

/* ================================================================
   LIVING ECOSYSTEM PAINTER
================================================================ */

class _GiftPayEcosystemPainter extends CustomPainter {
  final double progress;

  late final List<_EcosystemParticle> _particles;

  _GiftPayEcosystemPainter({required this.progress}) {
    _particles = _buildParticles();
  }

  List<_EcosystemParticle> _buildParticles() {
    final random = math.Random(73421);

    return List.generate(105, (index) {
      final radius = 0.10 + random.nextDouble() * 0.78;
      final angle = random.nextDouble() * math.pi * 2;

      return _EcosystemParticle(
        radius: radius,
        angle: angle,
        size: 0.45 + random.nextDouble() * 1.55,
        speed: 0.025 + random.nextDouble() * 0.075,
        opacity: 0.10 + random.nextDouble() * 0.38,
        phase: random.nextDouble() * math.pi * 2,
        orbitTilt: 0.55 + random.nextDouble() * 0.55,
        bright: random.nextDouble() > 0.91,
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final center = Offset(size.width * 0.50, size.height * 0.46);

    final scale = math.min(size.width, size.height);

    final positions = <Offset>[];

    for (final particle in _particles) {
      final currentAngle =
          particle.angle + progress * math.pi * 2 * particle.speed;

      final orbitalRadius = scale * particle.radius;

      final x =
          center.dx +
          math.cos(currentAngle) * orbitalRadius * particle.orbitTilt;

      final y = center.dy + math.sin(currentAngle) * orbitalRadius * 0.62;

      positions.add(Offset(x, y));
    }

    _drawEcosystemConnections(canvas, positions, size);

    _drawParticles(canvas, positions, size);

    _drawAtmosphericDust(canvas, size);

    _drawOccasionalLight(canvas, center, scale);
  }

  void _drawEcosystemConnections(
    Canvas canvas,
    List<Offset> positions,
    Size size,
  ) {
    final connectionPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.55;

    // Connect only a limited number of nearby nodes.
    // This creates an organic ecosystem/network effect
    // without turning the screen into a tech wireframe.
    for (int i = 0; i < positions.length; i++) {
      final a = positions[i];

      int connections = 0;

      for (int j = i + 1; j < positions.length; j++) {
        if (connections >= 2) break;

        final b = positions[j];

        final dx = a.dx - b.dx;
        final dy = a.dy - b.dy;
        final distance = math.sqrt(dx * dx + dy * dy);

        if (distance < size.width * 0.075) {
          final strength = (1 - distance / (size.width * 0.075)) * 0.07;

          connectionPaint.color = const Color(0xFF4FC3F7).withOpacity(strength);

          canvas.drawLine(a, b, connectionPaint);

          connections++;
        }
      }
    }
  }

  void _drawParticles(Canvas canvas, List<Offset> positions, Size size) {
    for (int i = 0; i < _particles.length; i++) {
      final particle = _particles[i];
      final position = positions[i];

      final pulse =
          0.72 + math.sin(progress * math.pi * 2 * 2 + particle.phase) * 0.28;

      final opacity = particle.opacity * pulse;

      final color = particle.bright
          ? const Color(0xFFB9E9FF)
          : const Color(0xFF75A1FF);

      if (particle.bright) {
        final glowPaint = Paint()
          ..color = color.withOpacity(opacity * 0.13)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9);

        canvas.drawCircle(position, particle.size * 4.2, glowPaint);
      }

      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(position, particle.size, paint);
    }
  }

  void _drawAtmosphericDust(Canvas canvas, Size size) {
    final dustPaint = Paint()..color = Colors.white.withOpacity(0.025);

    final random = math.Random(9137);

    for (int i = 0; i < 70; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;

      final drift = math.sin(progress * math.pi * 2 + i) * 3;

      canvas.drawCircle(
        Offset(x + drift, y),
        0.35 + random.nextDouble() * 0.55,
        dustPaint,
      );
    }
  }

  void _drawOccasionalLight(Canvas canvas, Offset center, double scale) {
    final wave = (math.sin(progress * math.pi * 2) + 1) / 2;

    final orbitRadius = scale * 0.40;

    final position = Offset(
      center.dx + math.cos(progress * math.pi * 2) * orbitRadius,
      center.dy + math.sin(progress * math.pi * 2) * orbitRadius * 0.60,
    );

    final glowPaint = Paint()
      ..color = const Color(0xFF4FC3F7).withOpacity(0.025 + wave * 0.025)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);

    canvas.drawCircle(position, 10 + wave * 5, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _GiftPayEcosystemPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/* ================================================================
   PARTICLE MODEL
================================================================ */

class _EcosystemParticle {
  final double radius;
  final double angle;
  final double size;
  final double speed;
  final double opacity;
  final double phase;
  final double orbitTilt;
  final bool bright;

  const _EcosystemParticle({
    required this.radius,
    required this.angle,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.phase,
    required this.orbitTilt,
    required this.bright,
  });
}
