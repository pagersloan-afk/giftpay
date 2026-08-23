import 'package:flutter/material.dart';

class HeaderNavLinks extends StatelessWidget {
  final bool showLinks;

  const HeaderNavLinks({super.key, this.showLinks = true});

  static const Color blue = Color(0xFF4A6BB8);
  static const Color lightBlue = Color(0xFF75A1FF);

  @override
  Widget build(BuildContext context) {
    if (!showLinks) {
      return const SizedBox.shrink();
    }

    final items = <_HeaderNavItem>[
      const _HeaderNavItem(
        label: 'Dashboard',
        icon: Icons.dashboard_outlined,
        route: '/dashboard',
      ),
      const _HeaderNavItem(
        label: 'Services',
        icon: Icons.apps_rounded,
        route: '/services',
      ),
      const _HeaderNavItem(
        label: 'Payments',
        icon: Icons.payments_outlined,
        route: '/payments',
      ),
      const _HeaderNavItem(
        label: 'Activity',
        icon: Icons.receipt_long_outlined,
        route: '/transactions',
      ),
    ];

    final currentRoute = ModalRoute.of(context)?.settings.name;

    return Row(
      children: items.map((item) {
        final active = currentRoute == item.route;

        return Padding(
          padding: const EdgeInsets.only(right: 5),
          child: _NavItemButton(item: item, active: active),
        );
      }).toList(),
    );
  }
}

class _HeaderNavItem {
  final String label;
  final IconData icon;
  final String route;

  const _HeaderNavItem({
    required this.label,
    required this.icon,
    required this.route,
  });
}

class _NavItemButton extends StatefulWidget {
  final _HeaderNavItem item;
  final bool active;

  const _NavItemButton({required this.item, required this.active});

  @override
  State<_NavItemButton> createState() => _NavItemButtonState();
}

class _NavItemButtonState extends State<_NavItemButton> {
  bool _hovered = false;

  static const Color blue = Color(0xFF4A6BB8);
  static const Color lightBlue = Color(0xFF75A1FF);

  @override
  Widget build(BuildContext context) {
    final highlighted = widget.active || _hovered;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => _hovered = true);
      },
      onExit: (_) {
        setState(() => _hovered = false);
      },
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, widget.item.route);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: highlighted
                ? Colors.white.withOpacity(0.075)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.active
                  ? lightBlue.withOpacity(0.20)
                  : Colors.transparent,
            ),
            boxShadow: widget.active
                ? [
                    BoxShadow(
                      color: blue.withOpacity(0.13),
                      blurRadius: 18,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.item.icon,
                size: 17,
                color: highlighted ? lightBlue : Colors.white.withOpacity(0.66),
              ),

              const SizedBox(width: 7),

              Text(
                widget.item.label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: widget.active ? FontWeight.w800 : FontWeight.w700,
                  color: highlighted
                      ? Colors.white
                      : Colors.white.withOpacity(0.74),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
