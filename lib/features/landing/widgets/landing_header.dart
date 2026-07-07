import 'package:flutter/material.dart';

class LandingHeader extends StatelessWidget implements PreferredSizeWidget {
  const LandingHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFFB31B1B), // 🔴 Luxury red brand color
        border: Border(
          bottom: BorderSide(
            color: Colors.yellow,
            width: 3,
          ), // ⭐ Yellow underline
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 32,
          vertical: isMobile ? 12 : 15,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400), // ⭐ Luxury width
          child: isMobile ? _mobileHeader(context) : _desktopHeader(context),
        ),
      ),
    );
  }

  // ⭐ MOBILE HEADER
  Widget _mobileHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Top row: menu + brand + spacer
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
            const Text(
              "GiftPay",
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),

        const SizedBox(height: 12),

        // Navigation row
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 20,
          runSpacing: 10,
          children: [
            _navLink(context, "Business", "/business"),
            _navLink(context, "Personal", "/personal"),
            _navLink(context, "Products", "/products"),
            _navLink(context, "About", "/about"),
            _navLink(context, "Contact", "/contact"),
            const Icon(Icons.search, color: Colors.white, size: 20),
            _signInButton(context, isMobile: true),
          ],
        ),
      ],
    );
  }

  // ⭐ DESKTOP HEADER
  Widget _desktopHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Brand
        const Text(
          "GiftPay",
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),

        // Navigation
        Row(
          children: [
            _navLink(context, "Business", "/business"),
            _navLink(context, "Personal", "/personal"),
            _navLink(context, "Products", "/products"),
            _navLink(context, "About", "/about"),
            _navLink(context, "Contact", "/contact"),
            const Icon(Icons.search, color: Colors.white, size: 22),
            const SizedBox(width: 20),
            _signInButton(context, isMobile: false),
          ],
        ),
      ],
    );
  }

  // ⭐ NAV LINK
  Widget _navLink(BuildContext context, String label, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextButton(
        onPressed: () => Navigator.pushNamed(context, route),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // ⭐ SIGN IN BUTTON
  Widget _signInButton(BuildContext context, {required bool isMobile}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFFB31B1B),
        shape: const StadiumBorder(),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 20,
          vertical: isMobile ? 8 : 10,
        ),
        elevation: 2,
      ),
      onPressed: () => Navigator.pushNamed(context, '/login'),
      child: const Text(
        "Sign In",
        style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
      ),
    );
  }
}
