import 'package:flutter/material.dart';

class LandingResponsiveLayout extends StatefulWidget {
  final Widget child;

  const LandingResponsiveLayout({super.key, required this.child});

  @override
  State<LandingResponsiveLayout> createState() =>
      _LandingResponsiveLayoutState();
}

class _LandingResponsiveLayoutState extends State<LandingResponsiveLayout> {
  static const Color _navy = Color(0xFF273D68);
  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _lightBlue = Color(0xFF75A1FF);

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ============================================================
  // SCROLLBAR
  // ============================================================

  Widget _buildScrollbar({required Widget child, required bool desktop}) {
    if (!desktop) {
      return child;
    }

    return ScrollbarTheme(
      data: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.dragged)) {
            return _navy.withOpacity(0.92);
          }

          if (states.contains(WidgetState.hovered)) {
            return _blue.withOpacity(0.82);
          }

          return _blue.withOpacity(0.62);
        }),

        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.hovered)) {
            return _navy.withOpacity(0.10);
          }

          return _navy.withOpacity(0.055);
        }),

        trackBorderColor: WidgetStateProperty.all(_navy.withOpacity(0.08)),

        thickness: WidgetStateProperty.resolveWith<double>((states) {
          if (states.contains(WidgetState.dragged)) {
            return 11;
          }

          if (states.contains(WidgetState.hovered)) {
            return 10;
          }

          return 8;
        }),

        radius: const Radius.circular(999),

        thumbVisibility: WidgetStateProperty.all(true),

        trackVisibility: WidgetStateProperty.all(true),

        interactive: true,
      ),

      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        trackVisibility: true,
        interactive: true,
        thickness: 8,
        radius: const Radius.circular(999),

        child: child,
      ),
    );
  }

  // ============================================================
  // SCROLL VIEW
  // ============================================================

  Widget _buildScrollView({
    required Widget content,
    required EdgeInsets padding,
    required bool desktop,
  }) {
    final scrollView = SingleChildScrollView(
      controller: _scrollController,
      primary: false,
      padding: padding,
      child: content,
    );

    return _buildScrollbar(desktop: desktop, child: scrollView);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    // ============================================================
    // MOBILE
    // ============================================================

    if (width < 900) {
      return _buildScrollView(
        desktop: false,
        padding: EdgeInsets.only(
          left: width * 0.01,
          right: width * 0.01,
          top: 16,
          bottom: 16,
        ),
        content: widget.child,
      );
    }

    // ============================================================
    // TABLET
    // ============================================================

    if (width < 1200) {
      return _buildScrollView(
        desktop: false,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        content: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: widget.child,
          ),
        ),
      );
    }

    // ============================================================
    // DESKTOP
    // ============================================================

    return _buildScrollView(
      desktop: true,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      content: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: widget.child,
        ),
      ),
    );
  }
}
