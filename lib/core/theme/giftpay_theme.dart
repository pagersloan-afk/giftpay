import 'package:flutter/material.dart';

import 'package:utilityhub/core/widgets/app_header/header_logo.dart';

class GiftPayTheme {
  // ===========================================================================
  // GIFTPAY AUTHENTICATED DARK SYSTEM
  // ===========================================================================

  static const Color primaryBlue = Color(0xFF0A4D9C);
  static const Color secondaryOrange = Color(0xFFFF8F00);

  static const Color headerAccent = Color(0xFF4FC3F7);
  static const Color headerDark = Color(0xFF0F1115);

  static const Color deepBackground = Color(0xFF05070A);
  static const Color backgroundBlend = Color(0xFF0A0D12);
  static const Color surface = Color(0xFF101827);

  static ThemeData theme = ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor: Colors.transparent,

    colorScheme: const ColorScheme.dark(
      primary: primaryBlue,
      secondary: secondaryOrange,
      surface: Colors.transparent,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.white,
      centerTitle: false,
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF1A1C20),
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFE5E7EB), fontSize: 16),
      bodyMedium: TextStyle(color: Color(0xFFD1D5DB), fontSize: 14),
      bodySmall: TextStyle(color: Color(0xFFD1D5DB), fontSize: 12),
      titleLarge: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 20,
      ),
      titleMedium: TextStyle(
        color: Color(0xFFE5E7EB),
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      titleSmall: TextStyle(color: Color(0xFFE5E7EB), fontSize: 14),
      labelLarge: TextStyle(color: Color(0xFFE5E7EB), fontSize: 14),
      labelMedium: TextStyle(color: Color(0xFFE5E7EB), fontSize: 12),
      labelSmall: TextStyle(color: Color(0xFFE5E7EB), fontSize: 11),
      headlineSmall: TextStyle(color: Colors.white),
      displaySmall: TextStyle(color: Colors.white),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white10,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.55)),
      labelStyle: const TextStyle(color: Color(0xFFE5E7EB)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Colors.white24),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Colors.white38, width: 2),
      ),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Colors.white24),
      ),
    ),

    dropdownMenuTheme: DropdownMenuThemeData(
      textStyle: const TextStyle(color: Color(0xFFE5E7EB)),
      menuStyle: MenuStyle(
        backgroundColor: const WidgetStatePropertyAll(Color(0xFF1F2937)),
        elevation: const WidgetStatePropertyAll(0),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),

    cardTheme: CardThemeData(
      color: Colors.white.withOpacity(0.06),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}

// =============================================================================
// SECONDARY AUTHENTICATED HEADER
// =============================================================================
//
// Used by authenticated screens other than the main dashboard.
//
// Examples:
//   - Payments
//   - Activity
//   - Service pages
//   - Settings
//   - Transaction details
//   - Other inner authenticated screens
//
// This is intentionally darker and quieter than the public-facing header.
//
// =============================================================================

class AppHeaderr extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;

  const AppHeaderr({super.key, required this.title, this.onBack});

  static const Color headerDark = Color(0xFF0F1115);
  static const Color headerAccent = Color(0xFF4FC3F7);
  static const Color primaryBlue = Color(0xFF0A4D9C);

  @override
  Size get preferredSize => const Size.fromHeight(78);

  void _handleBack(BuildContext context) {
    if (onBack != null) {
      onBack!.call();
      return;
    }

    final navigator = Navigator.of(context);

    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final isMobile = width < 600;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Container(
            height: 76,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F1115),
                  Color(0xFF0D1219),
                  Color(0xFF0A0D12),
                ],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // =============================================================
                // SUBTLE TOP LIGHT
                // =============================================================
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: IgnorePointer(
                    child: Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            headerAccent.withOpacity(0.13),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // =============================================================
                // AMBIENT LEFT GLOW
                // =============================================================
                Positioned(
                  left: -100,
                  top: -130,
                  child: IgnorePointer(
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryBlue.withOpacity(0.055),
                      ),
                    ),
                  ),
                ),

                // =============================================================
                // HEADER CONTENT
                // =============================================================
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20),
                  child: isMobile
                      ? _MobileInnerHeader(
                          title: title,
                          onBack: () => _handleBack(context),
                        )
                      : _DesktopInnerHeader(
                          title: title,
                          onBack: () => _handleBack(context),
                        ),
                ),
              ],
            ),
          ),

          // ===============================================================
          // SUBTLE HEADER SEPARATOR
          // ===============================================================
          Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.035),
                  headerAccent.withOpacity(0.10),
                  Colors.white.withOpacity(0.035),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// MOBILE INNER HEADER
// =============================================================================
//
// The title is centered independently of the back button.
//
// This is the important UX correction:
//
//      [  ←  ]          Page Title          [  G  ]
//
// The back button has a large 48x48 hit area, while the arrow itself remains
// visually small. The title can therefore never accidentally become part of
// the back-button touch area.
//
// =============================================================================

class _MobileInnerHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _MobileInnerHeader({required this.title, required this.onBack});

  static const Color headerAccent = Color(0xFF4FC3F7);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ===============================================================
          // BACK BUTTON
          // ===============================================================
          Align(
            alignment: Alignment.centerLeft,
            child: _HeaderBackButton(onTap: onBack),
          ),

          // ===============================================================
          // CENTERED TITLE
          // ===============================================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 72),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.05,
                color: Colors.white,
              ),
            ),
          ),

          // ===============================================================
          // GIFTPAY G MARK
          // ===============================================================
          Align(
            alignment: Alignment.centerRight,
            child: _GiftPayGMark(compact: true),
          ),

          // ===============================================================
          // VERY SUBTLE TITLE ACCENT
          // ===============================================================
          Positioned(
            bottom: 5,
            child: Container(
              width: 24,
              height: 2,
              decoration: BoxDecoration(
                color: headerAccent.withOpacity(0.55),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// DESKTOP INNER HEADER
// =============================================================================

class _DesktopInnerHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _DesktopInnerHeader({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Row(
        children: [
          // ===============================================================
          // BACK
          // ===============================================================
          _HeaderBackButton(onTap: onBack),

          const SizedBox(width: 16),

          // ===============================================================
          // TITLE
          // ===============================================================
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(width: 18),

          // ===============================================================
          // GIFTPAY G MARK
          // ===============================================================
          const _GiftPayGMark(compact: false),
        ],
      ),
    );
  }
}

// =============================================================================
// BACK BUTTON
// =============================================================================

class _HeaderBackButton extends StatefulWidget {
  final VoidCallback onTap;

  const _HeaderBackButton({required this.onTap});

  @override
  State<_HeaderBackButton> createState() => _HeaderBackButtonState();
}

class _HeaderBackButtonState extends State<_HeaderBackButton> {
  bool _hovered = false;

  static const Color headerAccent = Color(0xFF4FC3F7);
  static const Color primaryBlue = Color(0xFF0A4D9C);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _hovered = true);
      },
      onExit: (_) {
        setState(() => _hovered = false);
      },
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _hovered
                ? Colors.white.withOpacity(0.085)
                : Colors.white.withOpacity(0.045),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hovered
                  ? headerAccent.withOpacity(0.24)
                  : Colors.white.withOpacity(0.085),
            ),
            boxShadow: [
              BoxShadow(
                color: primaryBlue.withOpacity(_hovered ? 0.16 : 0.045),
                blurRadius: _hovered ? 18 : 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_back_rounded,
            size: 21,
            color: Colors.white.withOpacity(0.94),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// GIFTPAY G MARK
// =============================================================================
//
// Uses the same HeaderLogo component as the primary authenticated header.
//
// This means there is now ONE source of truth for the GiftPay G branding
// instead of maintaining another independent Image.asset implementation.
//
// =============================================================================

class _GiftPayGMark extends StatelessWidget {
  final bool compact;

  const _GiftPayGMark({required this.compact});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: compact ? 48 : 56,
      width: compact ? 48 : 56,
      child: HeaderLogo(compact: true, showWordmark: false),
    );
  }
}
