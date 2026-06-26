import 'package:flutter/material.dart';

class GiftPayTheme {
  static const Color primaryBlue = Color(0xFF0A4D9C);
  static const Color secondaryOrange = Color(0xFFFF8F00);

  // Accent line color (soft cyan)
  static const Color headerAccent = Color(0xFF4FC3F7);

  // Darkened premium header base
  static const Color headerDark = Color(0xFF0F1115);

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

    // ⭐ FIXED SNACKBAR (GiftPay Dark)
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Color(0xFF1A1C20),
      contentTextStyle: TextStyle(
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
      labelStyle: TextStyle(color: Color(0xFFE5E7EB)),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Colors.white38, width: 2),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Colors.white24),
      ),
    ),

    dropdownMenuTheme: DropdownMenuThemeData(
      textStyle: TextStyle(color: Color(0xFFE5E7EB)),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(Color(0xFF1F2937)),
        elevation: WidgetStatePropertyAll(0),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),

    cardTheme: CardThemeData(
      color: Colors.white.withOpacity(0.06),
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}

class AppHeaderr extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack; // ⭐ optional custom back handler

  const AppHeaderr({super.key, required this.title, this.onBack});

  @override
  Size get preferredSize => const Size.fromHeight(78);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Container(
            height: 76,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(color: Color(0xFF0F1115)),
            child: Row(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (onBack != null) {
                          onBack!(); // ⭐ use custom behavior when provided
                        } else {
                          final nav = Navigator.of(context);
                          if (nav.canPop()) {
                            nav.pop();
                          }
                        }
                      },
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Expanded(child: Container()),
                isMobile ? _MobileLogo() : _DesktopBrandBlock(),
              ],
            ),
          ),
          Container(height: 2, color: Colors.white12),
        ],
      ),
    );
  }
}

class _MobileLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [Colors.blue.withOpacity(0.35), Colors.transparent],
              radius: 0.85,
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(0, 2),
          child: Image.asset(
            "assets/logo/giftpay_1.png",
            height: 48,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}

class _DesktopBrandBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                Colors.white.withOpacity(0.95),
                Colors.white.withOpacity(0.55),
                Colors.white.withOpacity(0.95),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: Text(
            "GiftPay",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: Colors.white.withOpacity(0.9),
              shadows: [
                Shadow(
                  blurRadius: 14,
                  color: Colors.black.withOpacity(0.45),
                  offset: const Offset(0, 2),
                ),
                Shadow(
                  blurRadius: 22,
                  color: Colors.blue.withOpacity(0.28),
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.blue.withOpacity(0.35), Colors.transparent],
                  radius: 0.85,
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, 4),
              child: Image.asset(
                "assets/logo/giftpay_1.png",
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
