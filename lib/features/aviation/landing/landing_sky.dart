import 'package:flutter/material.dart';

class LandingSky extends StatelessWidget {
  final Animation<Offset> planeSlide;

  const LandingSky({super.key, required this.planeSlide});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4FC3F7), Color(0xFF0F1115)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 40,
            left: 20,
            child: Opacity(
              opacity: 0.35,
              child: Icon(Icons.cloud, size: 60, color: Colors.white),
            ),
          ),
          Positioned(
            top: 70,
            right: 40,
            child: Opacity(
              opacity: 0.30,
              child: Icon(Icons.cloud, size: 50, color: Colors.white),
            ),
          ),
          SlideTransition(
            position: planeSlide,
            child: Align(
              alignment: Alignment.center,
              child: Icon(
                Icons.flight_takeoff,
                size: 90,
                color: Colors.white.withOpacity(0.95),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
