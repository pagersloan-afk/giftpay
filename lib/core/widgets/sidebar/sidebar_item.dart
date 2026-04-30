import 'package:flutter/material.dart';

class SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final String route;
  final String activeRoute;
  final bool isDestructive;

  const SidebarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.route,
    required this.activeRoute,
    this.isDestructive = false,
  });

  @override
  State<SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<SidebarItem> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    final bool isActive = widget.route == widget.activeRoute;

    // GP‑1 color system
    final Color cyan = const Color(0xFF4FC3F7);
    final Color baseText = Colors.white.withOpacity(0.85);
    final Color hoverBg = Colors.white.withOpacity(0.05);
    final Color activeBg = Colors.white.withOpacity(0.10);

    return MouseRegion(
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, widget.route),
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

            // ⭐ GP‑1 border
            border: Border.all(
              color: isActive
                  ? cyan.withOpacity(0.35)
                  : Colors.white.withOpacity(0.08),
              width: 1.1,
            ),

            // ⭐ GP‑1 rounded corners
            borderRadius: BorderRadius.circular(14),

            // ⭐ Active glow
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
              // ⭐ Cyan active indicator bar
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

              // ⭐ Icon
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

              // ⭐ Label
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
