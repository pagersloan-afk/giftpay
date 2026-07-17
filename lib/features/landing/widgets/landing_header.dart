import 'package:flutter/material.dart';

class LandingHeader extends StatefulWidget implements PreferredSizeWidget {
  const LandingHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  State<LandingHeader> createState() => _LandingHeaderState();
}

class _LandingHeaderState extends State<LandingHeader> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _hovering = false;

  void _showDropdown(BuildContext context, Widget menu) {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          child: CompositedTransformFollower(
            link: _layerLink,
            offset: const Offset(0, 38), // ⭐ EXACTLY under the button (no gap)
            child: MouseRegion(
              onEnter: (_) => _setHover(true),
              onExit: (_) => _setHover(false),
              child: Material(
                elevation: 8,
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: menu,
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _setHover(bool value) {
    setState(() => _hovering = value);

    if (!value) {
      Future.delayed(const Duration(milliseconds: 80), () {
        if (!_hovering) _hideDropdown();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 39, 61, 104),
        border: Border(bottom: BorderSide(color: Colors.grey, width: 3)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 32,
          vertical: isMobile ? 12 : 15,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: isMobile ? _mobileHeader(context) : _desktopHeader(context),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // MOBILE HEADER
  // ------------------------------------------------------------
  Widget _mobileHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
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
                fontFamily: 'SegoeUI',
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

  // ------------------------------------------------------------
  // DESKTOP HEADER
  // ------------------------------------------------------------
  Widget _desktopHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "GiftPay",
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        Row(
          children: [
            _navLink(context, "Business", "/business"),
            _navLink(context, "Personal", "/personal"),

            // ⭐ STRIPE STYLE DROPDOWN
            MouseRegion(
              onEnter: (_) {
                _setHover(true);
                _showDropdown(context, _productsDropdown(context));
              },
              onExit: (_) => _setHover(false),
              child: CompositedTransformTarget(
                link: _layerLink,
                child: _navLink(context, "Products", "/products"),
              ),
            ),

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

  // ------------------------------------------------------------
  // NAV LINK
  // ------------------------------------------------------------
  Widget _navLink(BuildContext context, String label, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextButton(
        onPressed: () => Navigator.pushNamed(context, route),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'SegoeUI',
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // SIGN IN BUTTON
  // ------------------------------------------------------------
  Widget _signInButton(BuildContext context, {required bool isMobile}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color.fromARGB(255, 2, 14, 39),
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
        style: TextStyle(fontFamily: 'SegoeUI', fontWeight: FontWeight.bold),
      ),
    );
  }

  // ------------------------------------------------------------
  // PRODUCTS DROPDOWN MENU
  // ------------------------------------------------------------
  Widget _productsDropdown(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _dropdownItem(context, "Bulk Electricity Tokens", "/bulk-electricity"),
        _dropdownItem(context, "Airtime Distribution", "/airtime-distribution"),
        _dropdownItem(context, "Corporate Data Plans", "/corporate-data"),
        _dropdownItem(context, "GiftPay Wallet", "/p-wallet"),
        _dropdownItem(
          context,
          "GiftPay Business Dashboard",
          "/business-dashboard",
        ),
        _dropdownItem(context, "GiftPay Personal", "/personal-home"),
        _dropdownItem(context, "GiftPay API", "/api"),
      ],
    );
  }

  Widget _dropdownItem(BuildContext context, String label, String route) {
    return InkWell(
      onTap: () {
        _hideDropdown();
        Navigator.pushNamed(context, route);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ), // reduced
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 14, // slightly smaller
            color: Color.fromARGB(255, 39, 61, 104),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
