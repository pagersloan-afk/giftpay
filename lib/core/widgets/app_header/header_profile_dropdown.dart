import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:utilityhub/core/security/device_trust.dart';

class HeaderProfileDropdown extends StatefulWidget {
  final String? photoUrl;

  /// When true, the dropdown opens aligned to the right edge
  /// of the profile avatar.
  ///
  /// This is used by mobile web where the profile avatar lives
  /// on the right side of the header.
  final bool alignRight;

  const HeaderProfileDropdown({
    super.key,
    required this.photoUrl,
    this.alignRight = false,
  });

  @override
  State<HeaderProfileDropdown> createState() => _HeaderProfileDropdownState();
}

class _HeaderProfileDropdownState extends State<HeaderProfileDropdown> {
  OverlayEntry? _entry;

  void _toggle() {
    if (_entry == null) {
      _entry = _createOverlay();
      Overlay.of(context, rootOverlay: true).insert(_entry!);
    } else {
      _entry?.remove();
      _entry = null;
    }
  }

  OverlayEntry _createOverlay() {
    final renderBox = context.findRenderObject() as RenderBox;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;

        const menuWidth = 190.0;

        // ------------------------------------------------------------
        // DEFAULT POSITION
        // ------------------------------------------------------------
        double left = offset.dx;

        // ------------------------------------------------------------
        // RIGHT-ALIGNED POSITION
        //
        // Avatar:
        //       [avatar]
        //
        // Dropdown:
        //                  [--------------]
        //
        // The right edge of the menu lines up with the right edge
        // of the avatar.
        // ------------------------------------------------------------
        if (widget.alignRight) {
          left = offset.dx + size.width - menuWidth;

          // Keep the menu inside the viewport.
          if (left < 8) {
            left = 8;
          }

          if (left + menuWidth > screenWidth - 8) {
            left = screenWidth - menuWidth - 8;
          }
        }

        return Positioned(
          left: left,
          top: offset.dy + size.height + 8,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: menuWidth,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1C20),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4FC3F7).withOpacity(0.15),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _item(Icons.person, "Profile", "/profile"),
                  _item(Icons.settings, "Settings", "/settings"),
                  _item(Icons.logout, "Logout", "/login", logout: true),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _item(
    IconData icon,
    String label,
    String route, {
    bool logout = false,
  }) {
    return InkWell(
      onTap: () async {
        _toggle();

        if (logout) {
          await DeviceTrust.clearDeviceTrust();
          await FirebaseAuth.instance.signOut();

          if (!mounted) return;

          Navigator.of(
            context,
            rootNavigator: true,
          ).pushNamedAndRemoveUntil(route, (r) => false);
        } else {
          Navigator.of(context, rootNavigator: true).pushNamed(route);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.white.withOpacity(0.85)),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _entry?.remove();
    _entry = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      behavior: HitTestBehavior.opaque,
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.white.withOpacity(0.25),
        backgroundImage: widget.photoUrl != null
            ? NetworkImage(widget.photoUrl!)
            : null,
        child: widget.photoUrl == null
            ? const Icon(Icons.person, color: Colors.white)
            : null,
      ),
    );
  }
}
