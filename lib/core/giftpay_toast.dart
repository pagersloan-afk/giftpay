import 'package:flutter/material.dart';

class GiftPayToast {
  // SUCCESS TOAST (cyan glow)
  static void success(BuildContext context, String msg) {
    _showToast(
      context,
      msg,
      background: const Color(0xFF1A1C20),
      glow: const Color(0xFF4CAF50), // green glow
    );
  }

  // ERROR TOAST (red glow)
  static void error(BuildContext context, String msg) {
    _showToast(
      context,
      msg,
      background: const Color(0xFF1A1C20),
      glow: Colors.redAccent,
    );
  }

  // CORE TOAST ENGINE
  static void _showToast(
    BuildContext context,
    String message, {
    required Color background,
    required Color glow,
    Duration duration = const Duration(seconds: 2),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        return _GiftPayToastWidget(
          message: message,
          background: background,
          glow: glow,
          duration: duration,
          onClose: () => entry.remove(),
        );
      },
    );

    overlay.insert(entry);
  }
}

class _GiftPayToastWidget extends StatefulWidget {
  final String message;
  final Color background;
  final Color glow;
  final Duration duration;
  final VoidCallback onClose;

  const _GiftPayToastWidget({
    required this.message,
    required this.background,
    required this.glow,
    required this.duration,
    required this.onClose,
  });

  @override
  State<_GiftPayToastWidget> createState() => _GiftPayToastWidgetState();
}

class _GiftPayToastWidgetState extends State<_GiftPayToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    _opacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _offset = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    Future.delayed(widget.duration, () async {
      await _controller.reverse();
      widget.onClose();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _offset,
        child: FadeTransition(
          opacity: _opacity,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: widget.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
                boxShadow: [
                  BoxShadow(
                    color: widget.glow.withOpacity(0.35),
                    blurRadius: 22,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Text(
                widget.message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
