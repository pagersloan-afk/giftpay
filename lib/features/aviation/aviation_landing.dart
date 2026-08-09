import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';
import 'package:utilityhub/core/widgets/giftpay_background.dart';

import 'landing/landing_header.dart';
import 'landing/landing_sky.dart';
import 'landing/landing_trip_selector.dart';
import 'landing/landing_cta_button.dart';

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

  @override
  Widget build(BuildContext context) {
    return GiftPayBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        // ⭐ Your premium header with “rr”
        appBar: AppHeaderr(
          title: "Flights",
          onBack: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              "/home",
              (route) => false,
            );
          },
        ),

        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ⭐ Sky + animated plane
                  LandingSky(planeSlide: _planeSlide),

                  const SizedBox(height: 26),

                  // ⭐ Title + subtitle
                  const LandingHeader(),

                  const SizedBox(height: 26),

                  // ⭐ Trip selector
                  const LandingTripSelector(),

                  const SizedBox(height: 26),

                  // ⭐ CTA
                  const LandingCtaButton(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
