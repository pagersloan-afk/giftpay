import 'package:flutter/material.dart';

class SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;

  // Route is optional for custom actions such as Logout.
  final String? route;

  // Custom action is optional.
  final VoidCallback? onTap;

  final String activeRoute;
  final bool isDestructive;

  // ⭐ MOBILE WEB
  // When true, the drawer is closed before navigating.
  final bool closeDrawerOnNavigate;

  const SidebarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.activeRoute,
    this.route,
    this.onTap,
    this.isDestructive = false,
    this.closeDrawerOnNavigate = false,
  });

  @override
  State<SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<SidebarItem> {
  bool hovering = false;

  void _handleTap() {
    // ------------------------------------------------------------
    // CUSTOM ACTION
    // ------------------------------------------------------------

    if (widget.onTap != null) {
      widget.onTap!();
      return;
    }

    // ------------------------------------------------------------
    // NORMAL ROUTE
    // ------------------------------------------------------------

    if (widget.route == null) {
      return;
    }

    final navigator = Navigator.of(context);

    // ⭐ MOBILE WEB DRAWER
    //
    // The SidebarItem is inside the Drawer.
    // Close the drawer first, then push the route.
    //
    // On desktop/tablet this remains false, so the existing
    // sidebar navigation behavior is preserved.
    if (widget.closeDrawerOnNavigate) {
      navigator.pop();

      // Schedule navigation after the drawer has closed.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        Navigator.of(context).pushNamed(widget.route!);
      });

      return;
    }

    // ------------------------------------------------------------
    // EXISTING DESKTOP / TABLET NAVIGATION
    // ------------------------------------------------------------

    navigator.pushNamed(widget.route!);
  }

  @override
  Widget build(BuildContext context) {
    final bool isActive =
        widget.route != null && widget.route == widget.activeRoute;

    // GP-1 color system
    const Color cyan = Color(0xFF4FC3F7);

    final Color baseText = Colors.white.withOpacity(0.85);
    final Color hoverBg = Colors.white.withOpacity(0.05);
    final Color activeBg = Colors.white.withOpacity(0.10);

    return MouseRegion(
      onEnter: (_) {
        if (!mounted) return;
        setState(() => hovering = true);
      },
      onExit: (_) {
        if (!mounted) return;
        setState(() => hovering = false);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          decoration: BoxDecoration(
            color: isActive
                ? activeBg
                : hovering
                ? hoverBg
                : Colors.transparent,

            border: Border.all(
              color: isActive
                  ? cyan.withOpacity(0.35)
                  : Colors.white.withOpacity(0.08),
              width: 1.1,
            ),

            borderRadius: BorderRadius.circular(14),

            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: cyan.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              // Active indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 3,
                height: 26,
                decoration: BoxDecoration(
                  color: isActive ? cyan : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              const SizedBox(width: 14),

              // Icon
              Icon(
                widget.icon,
                size: 20,
                color: widget.isDestructive
                    ? Colors.redAccent
                    : isActive
                    ? cyan
                    : Colors.white54,
              ),

              const SizedBox(width: 14),

              // Label
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.isDestructive
                        ? Colors.redAccent
                        : isActive
                        ? cyan
                        : baseText,
                    fontSize: 15,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
