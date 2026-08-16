import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

/// Premium animated background used throughout Gift Technology's
/// landing and dedicated corporate experiences.
///
/// Design direction:
/// - Deep navy / midnight base
/// - Restrained blue atmospheric lighting
/// - Slow cinematic movement
/// - Very subtle particles
/// - Soft radial depth
/// - Low-opacity Gift Technology watermark
///
/// The background is intentionally atmospheric rather than decorative.
/// Foreground content should remain the visual priority.
class GiftTechBackground extends StatefulWidget {
  final Widget child;

  const GiftTechBackground({super.key, required this.child});

  @override
  State<GiftTechBackground> createState() => _GiftTechBackgroundState();
}

class _GiftTechBackgroundState extends State<GiftTechBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 32),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value;

          return Stack(
            fit: StackFit.expand,
            children: [
              _buildBaseLayer(),
              _buildAtmosphereLayer(t),
              _buildGridLayer(t),
              _buildParticlesLayer(t),
              _buildWatermark(),
              _buildVignette(),

              // Foreground application content.
              widget.child,
            ],
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BASE
  // ---------------------------------------------------------------------------

  Widget _buildBaseLayer() {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF030712),
            Color(0xFF07101F),
            Color(0xFF0A1427),
            Color(0xFF050B18),
          ],
          stops: [0.0, 0.34, 0.68, 1.0],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ATMOSPHERIC LIGHT
  // ---------------------------------------------------------------------------

  Widget _buildAtmosphereLayer(double t) {
    final slowWave = 0.5 + 0.5 * math.sin(t * math.pi * 2);

    return IgnorePointer(
      child: CustomPaint(
        painter: _AtmospherePainter(progress: t, wave: slowWave),
        child: const SizedBox.expand(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SUBTLE GRID
  // ---------------------------------------------------------------------------

  Widget _buildGridLayer(double t) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _InfrastructureGridPainter(progress: t),
        child: const SizedBox.expand(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PARTICLES
  // ---------------------------------------------------------------------------

  Widget _buildParticlesLayer(double t) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _ParticlesPainter(t),
        child: const SizedBox.expand(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BRAND WATERMARK
  // ---------------------------------------------------------------------------

  Widget _buildWatermark() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: Opacity(
            opacity: 0.022,
            child: Image.asset(
              'assets/logo/gift_tech_logo.png',
              width: 560,
              height: 560,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // VIGNETTE
  // ---------------------------------------------------------------------------

  Widget _buildVignette() {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.15,
            colors: [
              Colors.transparent,
              Colors.transparent,
              Colors.black.withOpacity(0.16),
              Colors.black.withOpacity(0.34),
            ],
            stops: const [0.0, 0.52, 0.82, 1.0],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// ATMOSPHERE PAINTER
// =============================================================================

class _AtmospherePainter extends CustomPainter {
  final double progress;
  final double wave;

  _AtmospherePainter({required this.progress, required this.wave});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    final pulse = 0.5 + 0.5 * math.sin(progress * math.pi * 2);

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 90);

    // -------------------------------------------------------------------------
    // PRIMARY BLUE ATMOSPHERE
    // -------------------------------------------------------------------------

    paint.color = const Color(0xFF4A6BB8).withOpacity(0.075 + (pulse * 0.018));

    canvas.drawCircle(
      Offset(width * (0.08 + (progress * 0.10)), height * 0.12),
      math.min(width, height) * 0.24,
      paint,
    );

    // -------------------------------------------------------------------------
    // SECONDARY BLUE ATMOSPHERE
    // -------------------------------------------------------------------------

    paint.color = const Color(0xFF273D68).withOpacity(0.12 + (wave * 0.018));

    canvas.drawCircle(
      Offset(width * (0.88 - progress * 0.08), height * 0.78),
      math.min(width, height) * 0.30,
      paint,
    );

    // -------------------------------------------------------------------------
    // CENTRAL LIGHT
    // -------------------------------------------------------------------------

    paint.color = const Color(0xFF7EA4FF).withOpacity(0.025);

    canvas.drawCircle(
      Offset(width * 0.52, height * (0.38 + pulse * 0.05)),
      math.min(width, height) * 0.34,
      paint,
    );

    // -------------------------------------------------------------------------
    // SMALL HORIZON LIGHT
    // -------------------------------------------------------------------------

    paint.color = const Color(0xFF4A6BB8).withOpacity(0.035);

    canvas.drawCircle(
      Offset(width * 0.50, height * 0.92),
      math.min(width, height) * 0.18,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _AtmospherePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.wave != wave;
  }
}

// =============================================================================
// INFRASTRUCTURE GRID
// =============================================================================

class _InfrastructureGridPainter extends CustomPainter {
  final double progress;

  _InfrastructureGridPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.65
      ..color = Colors.white.withOpacity(0.018);

    const spacing = 72.0;

    final horizontalOffset = (progress * spacing) % spacing;
    final verticalOffset = (progress * spacing * 0.55) % spacing;

    // Horizontal infrastructure lines.
    for (
      double y = -spacing + horizontalOffset;
      y < size.height + spacing;
      y += spacing
    ) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Vertical infrastructure lines.
    for (
      double x = -spacing + verticalOffset;
      x < size.width + spacing;
      x += spacing
    ) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Soft central horizontal axis.
    final axisPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF4A6BB8).withOpacity(0.025);

    canvas.drawLine(
      Offset(0, size.height * 0.52),
      Offset(size.width, size.height * 0.52),
      axisPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _InfrastructureGridPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// =============================================================================
// PARTICLES
// =============================================================================

class _ParticlesPainter extends CustomPainter {
  final double progress;

  _ParticlesPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final shortestSide = math.min(size.width, size.height);

    // Fewer, smaller particles create a more premium appearance.
    const particleCount = 16;

    for (int i = 0; i < particleCount; i++) {
      final seed = i * 17.731;

      final baseX = 0.08 + ((math.sin(seed) + 1) * 0.5) * 0.84;
      final baseY = 0.04 + ((math.cos(seed * 1.7) + 1) * 0.5) * 0.92;

      final speed = 0.12 + (i % 4) * 0.035;

      final yProgress = (baseY + progress * speed) % 1.0;

      final xDrift = math.sin((progress * math.pi * 2) + seed) * 0.012;

      final x = (baseX + xDrift) * size.width;
      final y = yProgress * size.height;

      final opacity = 0.055 + ((math.sin(seed * 2.3) + 1) * 0.5) * 0.065;

      final radius = i % 5 == 0 ? shortestSide * 0.0032 : shortestSide * 0.0020;

      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(0xFF8AAEFF).withOpacity(opacity);

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
