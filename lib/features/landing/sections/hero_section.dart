import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';
import '../widgets/phone_showcase_carousel.dart';

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

    // ⭐ Smooth Stripe-style animation (12 seconds loop)
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

  // Greeting logic
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning";
    if (hour < 17) return "Good afternoon";
    return "Good evening";
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    final bool isMobile = width < 900;
    final bool isTablet = width >= 900 && width < 1200;
    final bool isDesktop = width >= 1200;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // ⭐ Stripe-style animated gradient movement
        final alignmentShift = _controller.value * 0.6;

        return Container(
          width: double.infinity,
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
            horizontal: isMobile ? 12.0 : 20.0,
            vertical: isMobile ? 24.0 : 50.0,
          ),

          // ⭐ Your existing hero layout preserved
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _loginPanel(true),
                    const SizedBox(height: 28),
                    _walletPromo(context, true),
                    const SizedBox(height: 28),
                    _servicesPromo(context, true),
                    const SizedBox(height: 28),
                    _phonePreview(true),
                  ],
                )
              : isTablet
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _loginPanel(false)),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        children: [
                          _walletPromo(context, false),
                          const SizedBox(height: 24),
                          _servicesPromo(context, false),
                        ],
                      ),
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _loginPanel(false)),
                    const SizedBox(width: 40),
                    Expanded(
                      child: Column(
                        children: [
                          _walletPromo(context, false),
                          const SizedBox(height: 28),
                          _servicesPromo(context, false),
                        ],
                      ),
                    ),
                    const SizedBox(width: 40),
                    Expanded(child: _phonePreview(false)),
                  ],
                ),
        ),
      ),
    );
  }

  // ⭐ LOGIN PANEL
  Widget _loginPanel(bool isMobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        final bool isTiny = maxWidth < 350;

        return AnimatedLiftCard(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(isTiny ? 12.0 : (isMobile ? 16.0 : 28.0)),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontWeight: FontWeight.w700,
                    fontSize: isTiny ? 18.0 : (isMobile ? 20.0 : 22.0),
                    color: Colors.black87,
                  ),
                ),

                SizedBox(height: isTiny ? 14.0 : 20.0),

                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: TextField(
                    decoration: _inputDecoration("Username"),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),

                const SizedBox(height: 14.0),

                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: TextField(
                    obscureText: true,
                    decoration: _inputDecoration("Password"),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),

                const SizedBox(height: 14.0),

                Row(
                  children: [
                    Checkbox(
                      value: false,
                      onChanged: (_) {},
                      visualDensity: VisualDensity.compact,
                    ),
                    Flexible(
                      child: Text(
                        "Save username",
                        style: TextStyle(
                          fontFamily: 'SegoeUI',
                          fontSize: isTiny ? 12.0 : (isMobile ? 13.0 : 15.0),
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: isTiny ? 16.0 : 20.0),

                isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: GiftPayTheme.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 26.0,
                                vertical: isTiny ? 12.0 : 14.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                            ),
                            child: Text(
                              "Sign On",
                              style: TextStyle(
                                fontFamily: 'SegoeUI',
                                fontWeight: FontWeight.w600,
                                fontSize: isTiny ? 14.0 : 15.0,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12.0),

                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 26.0,
                                vertical: isTiny ? 12.0 : 14.0,
                              ),
                              side: const BorderSide(color: Colors.black87),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                            ),
                            child: Text(
                              "Enroll",
                              style: TextStyle(
                                fontFamily: 'SegoeUI',
                                fontSize: isTiny ? 14.0 : 15.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: GiftPayTheme.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32.0,
                                vertical: 16.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                            ),
                            child: const Text(
                              "Sign On",
                              style: TextStyle(
                                fontFamily: 'SegoeUI',
                                fontWeight: FontWeight.w600,
                                fontSize: 17.0,
                              ),
                            ),
                          ),

                          const SizedBox(width: 14.0),

                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32.0,
                                vertical: 16.0,
                              ),
                              side: const BorderSide(color: Colors.black87),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                            ),
                            child: const Text(
                              "Enroll",
                              style: TextStyle(
                                fontFamily: 'SegoeUI',
                                fontSize: 17.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),

                SizedBox(height: isTiny ? 16.0 : 20.0),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _link("Forgot username or password?", isMobile),
                    _link("Security Center", isMobile),
                    _link("Privacy, Cookies, and Legal", isMobile),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ⭐ WALLET PROMO
  Widget _walletPromo(BuildContext context, bool isMobile) {
    return AnimatedLiftCard(
      child: Container(
        padding: EdgeInsets.all(isMobile ? 18 : 28),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your Digital Wallet, Supercharged",
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontWeight: FontWeight.w700,
                fontSize: isMobile ? 18 : 20,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              "Fund your wallet instantly, withdraw anytime, and manage all your payments in one secure place.",
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: isMobile ? 14 : 15,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: GiftPayTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 30 : 38,
                  vertical: isMobile ? 16 : 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                "Open Wallet",
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ⭐ SERVICES PROMO
  Widget _servicesPromo(BuildContext context, bool isMobile) {
    return AnimatedLiftCard(
      child: Container(
        padding: EdgeInsets.all(isMobile ? 18 : 28),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "All Your Utilities, One Platform",
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontWeight: FontWeight.w700,
                fontSize: isMobile ? 18 : 20,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              "Electricity, Airtime, Data, Gift Cards, TV, Health — fast, reliable, and always available.",
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: isMobile ? 14 : 15,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: GiftPayTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 26 : 32,
                  vertical: isMobile ? 14 : 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                "Explore Services",
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ⭐ PHONE PREVIEW
  Widget _phonePreview(bool isMobile) {
    return PhoneShowcaseCarousel(
      screens: [
        'assets/screens/screen1.png',
        'assets/screens/screen2.png',
        'assets/screens/screen3.png',
        'assets/screens/screen4.png',
        'assets/screens/screen5.png',
        'assets/screens/screen6.png',
        'assets/screens/screen7.png',
        'assets/screens/screen8.png',
        'assets/screens/screen9.png',
        'assets/screens/screen10.png',
      ],
      height: isMobile ? 300 : 420,
    );
  }

  // ⭐ Shared Decorations
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      // ⭐ Transparent white glass effect
      color: Colors.white.withOpacity(0.55),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white.withOpacity(0.30), width: 1.2),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 22,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black87),
      border: const OutlineInputBorder(),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black38),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  Widget _link(String text, bool isMobile) {
    return TextButton(
      onPressed: () {},
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'SegoeUI',
          fontSize: isMobile ? 13 : 15,
          color: Colors.black87,
          height: 1.4,
        ),
      ),
    );
  }
}

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
            ..setEntry(3, 2, 0.001) // ⭐ perspective
            ..rotateX(tiltX)
            ..rotateY(-tiltY),
          child: widget.child,
        ),
      ),
    );
  }
}
