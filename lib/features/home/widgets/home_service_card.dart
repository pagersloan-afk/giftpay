import 'package:flutter/material.dart';

class HomeServiceCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final String route;

  const HomeServiceCard({
    super.key,
    required this.title,
    required this.icon,
    required this.route,
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
      begin: const Offset(0.2, 0),
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
            padding: const EdgeInsets.all(14),

            // ⭐ REMOVED FIXED HEIGHT — AUTO SIZE
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
              mainAxisSize: MainAxisSize.min, // ⭐ prevents clipping
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.icon,
                  size: 26, // ⭐ slightly smaller for better fit
                  color: Colors.white.withOpacity(0.90),
                ),

                const SizedBox(height: 6),

                Flexible(
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis, // ⭐ safe on small screens
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFE5E7EB),
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
