// lib/features/home/widgets/home_service_card.dart
import 'package:flutter/material.dart';

class HomeServiceCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final String route;
  final Color? iconColor; // ⭐ supports red logout

  const HomeServiceCard({
    super.key,
    required this.title,
    required this.icon,
    required this.route,
    this.iconColor,
  });

  @override
  State<HomeServiceCard> createState() => _HomeServiceCardState();
}

class _HomeServiceCardState extends State<HomeServiceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;

  double scale = 1.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0.15, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 150),
        child: InkWell(
          onTap: () {
            setState(() => scale = 0.92);
            Future.delayed(const Duration(milliseconds: 120), () {
              setState(() => scale = 1.0);
              Navigator.pushNamed(context, widget.route);
            });
          },
          borderRadius: BorderRadius.circular(16),

          child: Container(
            height: 68,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4FC3F7).withOpacity(0.10),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.icon,
                  size: 19,
                  color: widget.iconColor ?? Colors.white.withOpacity(0.90),
                ),

                const SizedBox(height: 6),

                SizedBox(
                  height: 18,
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.0,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                      color: widget.iconColor ?? const Color(0xFFE5E7EB),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
