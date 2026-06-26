// lib/features/home/widgets/home_service_card.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:utilityhub/core/services/user_services_api.dart';

class HomeServiceCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final String route;
  final Color? iconColor;
  final String userId;

  const HomeServiceCard({
    super.key,
    required this.title,
    required this.icon,
    required this.route,
    required this.userId,
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

  Future<void> _handleTap() async {
    setState(() => scale = 0.92);
    await Future.delayed(const Duration(milliseconds: 120));
    setState(() => scale = 1.0);

    await UserServicesApi.logUsage(
      userId: widget.userId,
      serviceName: widget.title,
      device: Platform.operatingSystem,
    );

    if (mounted) {
      Navigator.pushNamed(context, widget.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 150),
        child: InkWell(
          onTap: _handleTap,
          borderRadius: BorderRadius.circular(16),

          child: Container(
            width: double.infinity, // ⭐ FORCE EQUAL WIDTH
            height: 78, // ⭐ UNIFORM HEIGHT (same as All Services)
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
                  size: 22, // ⭐ Slightly bigger for balance
                  color: widget.iconColor ?? Colors.white.withOpacity(0.90),
                ),

                const SizedBox(height: 6),

                SizedBox(
                  height: 20, // ⭐ FIXED HEIGHT (prevents shrinking)
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    maxLines: 1, // ⭐ One line like All Services
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
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
