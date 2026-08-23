import 'package:flutter/material.dart';

class HeaderNotifications extends StatefulWidget {
  const HeaderNotifications({super.key});

  @override
  State<HeaderNotifications> createState() => _HeaderNotificationsState();
}

class _HeaderNotificationsState extends State<HeaderNotifications> {
  bool _hovered = false;

  static const Color blue = Color(0xFF4A6BB8);
  static const Color lightBlue = Color(0xFF75A1FF);
  static const Color navy = Color(0xFF273D68);

  @override
  Widget build(BuildContext context) {
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
          Navigator.pushNamed(context, '/notifications');
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _hovered
                ? Colors.white.withOpacity(0.095)
                : Colors.white.withOpacity(0.055),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: _hovered
                  ? lightBlue.withOpacity(0.20)
                  : Colors.white.withOpacity(0.10),
            ),
            boxShadow: [
              BoxShadow(
                color: blue.withOpacity(_hovered ? 0.15 : 0.055),
                blurRadius: _hovered ? 20 : 13,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Center(
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                  size: 21,
                ),
              ),

              Positioned(
                right: 8,
                top: 7,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: lightBlue,
                    border: Border.all(color: navy, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: lightBlue.withOpacity(0.55),
                        blurRadius: 7,
                      ),
                    ],
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
