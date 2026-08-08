import 'package:flutter/material.dart';

class AviationLanding extends StatefulWidget {
  const AviationLanding({super.key});

  @override
  State<AviationLanding> createState() => _AviationLandingState();
}

class _AviationLandingState extends State<AviationLanding>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _planeSlide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _planeSlide = Tween<Offset>(
      begin: const Offset(-0.6, 0.4),
      end: const Offset(0.4, -0.4),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _tripSelector(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: active
            ? Colors.white.withOpacity(0.15)
            : Colors.white.withOpacity(0.06),
        border: Border.all(
          color: active
              ? Colors.white.withOpacity(0.35)
              : Colors.white.withOpacity(0.12),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withOpacity(active ? 0.95 : 0.70),
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 550),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ⭐ Luxury Sky Gradient
                Container(
                  height: 220,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(26),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF4FC3F7), Color(0xFF0F1115)],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // ⭐ Parallax Clouds
                      Positioned(
                        top: 40,
                        left: 20,
                        child: Opacity(
                          opacity: 0.35,
                          child: Icon(
                            Icons.cloud,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 70,
                        right: 40,
                        child: Opacity(
                          opacity: 0.30,
                          child: Icon(
                            Icons.cloud,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      // ⭐ Animated Plane Takeoff
                      SlideTransition(
                        position: _planeSlide,
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
                ),

                const SizedBox(height: 26),

                // ⭐ Title
                Text(
                  "Book Flights",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Search and book flights across Nigeria and international routes.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 13.5,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 26),

                // ⭐ Trip Type Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _tripSelector("One‑way", true),
                    _tripSelector("Round‑trip", false),
                    _tripSelector("Multi‑city", false),
                  ],
                ),

                const SizedBox(height: 26),

                // ⭐ CTA Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4FC3F7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 6,
                      shadowColor: const Color(0xFF4FC3F7).withOpacity(0.45),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, "/aviation/search");
                    },
                    child: const Text(
                      "Search Flights",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
