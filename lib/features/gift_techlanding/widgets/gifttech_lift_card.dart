import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Reusable luxury hover / lift interaction used throughout
/// the Gift Technology landing experience.
///
/// On desktop:
/// - subtly scales the card
/// - follows the pointer with a very small 3D tilt
///
/// On touch devices:
/// - remains completely stable
/// - no hover-specific behavior is required
class GiftTechLiftCard extends StatefulWidget {
  final Widget child;
  final double hoverScale;
  final double tiltStrength;

  const GiftTechLiftCard({
    super.key,
    required this.child,
    this.hoverScale = 1.025,
    this.tiltStrength = 0.0018,
  });

  @override
  State<GiftTechLiftCard> createState() => _GiftTechLiftCardState();
}

class _GiftTechLiftCardState extends State<GiftTechLiftCard> {
  bool _hovering = false;

  double _rotateX = 0;
  double _rotateY = 0;

  void _reset() {
    if (!mounted) return;

    setState(() {
      _hovering = false;
      _rotateX = 0;
      _rotateY = 0;
    });
  }

  void _handleHover(PointerHoverEvent event) {
    final renderObject = context.findRenderObject();

    if (renderObject is! RenderBox) {
      return;
    }

    final size = renderObject.size;

    final dx = event.localPosition.dx - size.width / 2;
    final dy = event.localPosition.dy - size.height / 2;

    setState(() {
      _hovering = true;

      _rotateX = -dy * widget.tiltStrength;
      _rotateY = dx * widget.tiltStrength;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _hovering = true;
        });
      },
      onExit: (_) => _reset(),
      onHover: _handleHover,
      child: AnimatedScale(
        scale: _hovering ? widget.hoverScale : 1,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(_rotateX)
              ..rotateY(_rotateY),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
