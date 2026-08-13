import 'package:flutter/material.dart';

class GiftTechHeader extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback onAboutTap;
  final VoidCallback onProductsTap;
  final VoidCallback onCommunityTap;
  final VoidCallback onContactTap;

  const GiftTechHeader({
    super.key,
    required this.onAboutTap,
    required this.onProductsTap,
    required this.onCommunityTap,
    required this.onContactTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  State<GiftTechHeader> createState() => _GiftTechHeaderState();
}

class _GiftTechHeaderState extends State<GiftTechHeader> {
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
              "Gift Technology Ltd",
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
            _navLink("About", widget.onAboutTap),
            _navLink("Products", widget.onProductsTap),
            _navLink("Community", widget.onCommunityTap),
            _navLink("Contact", widget.onContactTap),
            const Icon(Icons.search, color: Colors.white, size: 20),
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
          "Gift Technology Ltd",
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
            _navLink("About", widget.onAboutTap),
            _navLink("Products", widget.onProductsTap),
            _navLink("Community", widget.onCommunityTap),
            _navLink("Contact", widget.onContactTap),
            const Icon(Icons.search, color: Colors.white, size: 22),
          ],
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // NAV LINK
  // ------------------------------------------------------------
  Widget _navLink(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextButton(
        onPressed: onTap,
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
}
