import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // Smooth animated gradient (Meta-style)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 900;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final alignmentShift = _controller.value * 0.6;

        return Container(
          width: double.infinity,
          height: isMobile ? 600 : 800, // ⭐ MUCH TALLER HERO SECTION
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1 + alignmentShift, -1),
              end: Alignment(1, 1 - alignmentShift),
              colors: [
                GiftPayTheme.primaryBlue.withOpacity(0.25),
                const Color.fromARGB(255, 243, 241, 241),
                GiftPayTheme.primaryBlue.withOpacity(0.15),
              ],
            ),
          ),
          child: child,
        );
      },
      child: Center(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 1400),
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 32,
            vertical: isMobile ? 40 : 80,
          ),

          // ⭐ NEW HERO CONTENT (NO LOGIN, NO PHONE, NO PROMO CARDS)
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ------------------------------------------------------------
              // MAIN TITLE — LUXURY META STYLE (FIXED)
              // ------------------------------------------------------------
              Text(
                "Gift Technology Ltd",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: isMobile ? 40 : 64, // ⭐ Bigger, premium
                  fontWeight: FontWeight.w900, // ⭐ Stronger presence
                  color: Colors.white.withOpacity(
                    0.95,
                  ), // ⭐ White on dark background
                  letterSpacing: 0.8,
                ),
              ),

              const SizedBox(height: 24),

              // ------------------------------------------------------------
              // SUBTITLE — LUXURY HIGHLIGHT FOR DARK BACKGROUND
              // ------------------------------------------------------------
              Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 900),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),

                  // ⭐ Soft highlight background (Meta-style)
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),

                    // ⭐ Subtle blur glow behind text
                    backgroundBlendMode: BlendMode.overlay,
                  ),

                  child: Text(
                    "A Nigerian multinational technology company building secure platforms for payments, utilities, e‑voting, and digital entertainment.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: isMobile ? 17 : 22,
                      height: 1.6,
                      color: Colors.white.withOpacity(
                        0.92,
                      ), // ⭐ Stronger contrast
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 60),

              // ------------------------------------------------------------
              // PRODUCT GRID (ALL PRODUCTS + SERVICES)
              // ------------------------------------------------------------
              _productGrid(isMobile),
            ],
          ),
        ),
      ),
    );
  }

  // ⭐ PRODUCT GRID — DISPLAY ALL PRODUCTS & SERVICES
  Widget _productGrid(bool isMobile) {
    final products = [
      {"name": "GiftPay", "route": "/giftpay"},
      {"name": "Kponkios", "route": "/kponkios"},
      {"name": "TheVoice", "route": "/thevoice"},
      {"name": "E‑Voting System", "route": "/evoting"},
      {"name": "GiftBusiness", "route": "/giftpay"},
      {"name": "GiftWallet", "route": "/giftpay"},
      {"name": "GiftPOS", "route": "/pos"},
      {"name": "GiftCard Marketplace", "route": "/giftpay"},
    ];

    return Wrap(
      spacing: isMobile ? 16 : 24,
      runSpacing: isMobile ? 16 : 24,
      alignment: WrapAlignment.center,
      children: products
          .map((p) => _productCard(p["name"]!, p["route"]!))
          .toList(),
    );
  }

  // ⭐ PRODUCT CARD — LUXURY FINTECH STYLE
  Widget _productCard(String title, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: AnimatedLiftCard(
        child: Container(
          width: 240,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.65),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withOpacity(0.30),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(Icons.apps, size: 40, color: GiftPayTheme.primaryBlue),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ⭐ REUSE YOUR EXISTING ANIMATED CARD
class AnimatedLiftCard extends StatefulWidget {
  final Widget child;
  const AnimatedLiftCard({super.key, required this.child});

  @override
  State<AnimatedLiftCard> createState() => _AnimatedLiftCardState();
}

class _AnimatedLiftCardState extends State<AnimatedLiftCard> {
  double hoverScale = 1.0;
  double tiltX = 0.0;
  double tiltY = 0.0;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hoverScale = 1.03),
      onExit: (_) => setState(() {
        hoverScale = 1.0;
        tiltX = 0.0;
        tiltY = 0.0;
      }),
      onHover: (event) {
        setState(() {
          tiltX = (event.localPosition.dy - 100) / 300;
          tiltY = (event.localPosition.dx - 150) / 300;
        });
      },
      child: AnimatedScale(
        scale: hoverScale,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(tiltX)
            ..rotateY(-tiltY),
          child: widget.child,
        ),
      ),
    );
  }
}
