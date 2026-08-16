import 'dart:ui';

import 'package:flutter/material.dart';

class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _softBlue = Color(0xFF75A1FF);
  static const Color _navy = Color(0xFF273D68);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final isMobile = width < 700;
    final isTablet = width >= 700 && width < 1100;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final pulse = Curves.easeInOut.transform(_controller.value);

        return Padding(
          padding: EdgeInsets.only(
            left: isMobile
                ? 18
                : isTablet
                ? 30
                : 52,
            right: isMobile
                ? 18
                : isTablet
                ? 30
                : 52,
            top: isMobile ? 34 : 52,
            bottom: isMobile ? 30 : 54,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1480),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(isMobile ? 28 : 40),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: isMobile ? 14 : 24,
                    sigmaY: isMobile ? 14 : 24,
                  ),
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      minHeight: isMobile ? 690 : 650,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(isMobile ? 28 : 40),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.075),
                          Colors.white.withOpacity(0.025),
                          _blue.withOpacity(0.055 + (pulse * 0.025)),
                          Colors.transparent,
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.095),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _blue.withOpacity(0.09 + (pulse * 0.04)),
                          blurRadius: 90,
                          spreadRadius: -18,
                          offset: const Offset(0, 30),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.28),
                          blurRadius: 50,
                          offset: const Offset(0, 25),
                        ),
                      ],
                    ),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        );
      },
      child: isMobile ? _buildMobileHero(context) : _buildDesktopHero(context),
    );
  }

  // ===========================================================================
  // DESKTOP / TABLET HERO
  // ===========================================================================

  Widget _buildDesktopHero(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isTablet = width < 1100;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 34 : 64,
        vertical: isTablet ? 48 : 68,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 6, child: _buildHeroCopy(context)),

          SizedBox(width: isTablet ? 35 : 70),

          Expanded(flex: 4, child: _buildInfrastructureVisual(context)),
        ],
      ),
    );
  }

  // ===========================================================================
  // MOBILE HERO
  // ===========================================================================

  Widget _buildMobileHero(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 34, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMobileBrandOrb(),

          const SizedBox(height: 34),

          _buildHeroCopy(context),

          const SizedBox(height: 48),

          _buildInfrastructureVisual(context),
        ],
      ),
    );
  }

  // ===========================================================================
  // HERO COPY
  // ===========================================================================

  Widget _buildHeroCopy(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final isMobile = width < 700;
    final isTablet = width >= 700 && width < 1100;

    final titleSize = isMobile
        ? 48.0
        : isTablet
        ? 60.0
        : 76.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---------------------------------------------------------------------
        // EYEBROW
        // ---------------------------------------------------------------------
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _softBlue,
                boxShadow: [
                  BoxShadow(
                    color: _softBlue.withOpacity(0.65),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 11),

            Text(
              'GIFT TECHNOLOGY',
              style: const TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.5,
                color: _softBlue,
              ),
            ),
          ],
        ),

        const SizedBox(height: 25),

        // ---------------------------------------------------------------------
        // MAIN HEADLINE
        // ---------------------------------------------------------------------
        Text(
          'Digital infrastructure\nfor a connected Africa.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: titleSize,
            height: 0.98,
            fontWeight: FontWeight.w800,
            letterSpacing: isMobile ? -1.8 : -3.5,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 27),

        // ---------------------------------------------------------------------
        // DESCRIPTION
        // ---------------------------------------------------------------------
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isMobile ? 620 : 690),
          child: Text(
            'We build technology that moves money, powers commerce, '
            'connects businesses and simplifies everyday digital life.',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: isMobile ? 16 : 18,
              height: 1.65,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.55),
            ),
          ),
        ),

        const SizedBox(height: 35),

        // ---------------------------------------------------------------------
        // ACTIONS
        // ---------------------------------------------------------------------
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _primaryButton(
              label: 'Explore our ecosystem',
              icon: Icons.arrow_forward_rounded,
              onTap: () => _scrollToSection(context, 'ecosystem'),
            ),

            _secondaryButton(
              label: 'Work with us',
              icon: Icons.north_east_rounded,
              onTap: () => _scrollToSection(context, 'contact'),
            ),
          ],
        ),

        const SizedBox(height: 42),

        // ---------------------------------------------------------------------
        // MICRO TRUST LINE
        // ---------------------------------------------------------------------
        Wrap(
          spacing: 18,
          runSpacing: 10,
          children: [
            _miniSignal(Icons.shield_outlined, 'Security-led'),
            _miniSignal(Icons.public_outlined, 'Built for Africa'),
            _miniSignal(Icons.auto_graph_rounded, 'Designed to scale'),
          ],
        ),
      ],
    );
  }

  // ===========================================================================
  // MOBILE BRAND ORB
  // ===========================================================================

  Widget _buildMobileBrandOrb() {
    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            _softBlue.withOpacity(0.20),
            _navy.withOpacity(0.12),
            Colors.transparent,
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: _blue.withOpacity(0.16),
            blurRadius: 45,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.045),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Image.asset(
              'assets/logo/gift_tech_logo.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) {
                return const Icon(
                  Icons.auto_awesome_rounded,
                  size: 22,
                  color: _softBlue,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // INFRASTRUCTURE VISUAL
  // ===========================================================================

  Widget _buildInfrastructureVisual(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final isMobile = width < 700;
    final visualHeight = isMobile ? 340.0 : 470.0;

    return SizedBox(
      height: visualHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // -------------------------------------------------------------------
          // OUTER GLOW
          // -------------------------------------------------------------------
          Container(
            width: isMobile ? 280 : 400,
            height: isMobile ? 280 : 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _blue.withOpacity(0.15),
                  _navy.withOpacity(0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // -------------------------------------------------------------------
          // CENTRAL GLASS SYSTEM
          // -------------------------------------------------------------------
          ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                width: isMobile ? 250 : 330,
                padding: EdgeInsets.all(isMobile ? 22 : 28),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.075),
                      Colors.white.withOpacity(0.025),
                    ],
                  ),
                  border: Border.all(color: Colors.white.withOpacity(0.105)),
                  boxShadow: [
                    BoxShadow(
                      color: _blue.withOpacity(0.13),
                      blurRadius: 60,
                      spreadRadius: -10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _visualHeader(),

                    const SizedBox(height: 24),

                    _systemItem(
                      number: '01',
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'PAYMENTS',
                      description: 'Move value securely.',
                    ),

                    const SizedBox(height: 10),

                    _systemItem(
                      number: '02',
                      icon: Icons.storefront_outlined,
                      title: 'COMMERCE',
                      description: 'Connect businesses.',
                    ),

                    const SizedBox(height: 10),

                    _systemItem(
                      number: '03',
                      icon: Icons.hub_outlined,
                      title: 'INFRASTRUCTURE',
                      description: 'Build for scale.',
                    ),

                    const SizedBox(height: 10),

                    _systemItem(
                      number: '04',
                      icon: Icons.devices_other_outlined,
                      title: 'DIGITAL SERVICES',
                      description: 'Simplify everyday life.',
                    ),
                  ],
                ),
              ),
            ),
          ),

          // -------------------------------------------------------------------
          // FLOATING TOP LABEL
          // -------------------------------------------------------------------
          Positioned(
            top: isMobile ? 12 : 25,
            right: isMobile ? 5 : 18,
            child: _floatingLabel(
              icon: Icons.bolt_rounded,
              text: 'DIGITAL INFRASTRUCTURE',
            ),
          ),

          // -------------------------------------------------------------------
          // FLOATING BOTTOM LABEL
          // -------------------------------------------------------------------
          Positioned(
            bottom: isMobile ? 12 : 22,
            left: isMobile ? 2 : 10,
            child: _floatingLabel(icon: Icons.public_rounded, text: 'AFRICA'),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // VISUAL HEADER
  // ===========================================================================

  Widget _visualHeader() {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [_softBlue.withOpacity(0.22), _navy.withOpacity(0.08)],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.11)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(9),
            child: Image.asset(
              'assets/logo/gift_tech_logo.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) {
                return const Icon(
                  Icons.auto_awesome_rounded,
                  size: 20,
                  color: _softBlue,
                );
              },
            ),
          ),
        ),

        const SizedBox(width: 13),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'GIFT TECHNOLOGY',
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.7,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'CONNECTED ECOSYSTEM',
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: Colors.white.withOpacity(0.35),
                ),
              ),
            ],
          ),
        ),

        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF63D69F),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF63D69F).withOpacity(0.55),
                blurRadius: 10,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // SYSTEM ITEM
  // ===========================================================================

  Widget _systemItem({
    required String number,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        color: Colors.white.withOpacity(0.025),
        border: Border.all(color: Colors.white.withOpacity(0.055)),
      ),
      child: Row(
        children: [
          Text(
            number,
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: Colors.white.withOpacity(0.25),
            ),
          ),

          const SizedBox(width: 12),

          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              color: _blue.withOpacity(0.10),
              border: Border.all(color: _softBlue.withOpacity(0.10)),
            ),
            child: Icon(icon, size: 17, color: _softBlue),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 9,
                    color: Colors.white.withOpacity(0.32),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // FLOATING LABEL
  // ===========================================================================

  Widget _floatingLabel({required IconData icon, required String text}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: Colors.white.withOpacity(0.045),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: _softBlue),
              const SizedBox(width: 6),
              Text(
                text,
                style: const TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 7.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // PRIMARY BUTTON
  // ===========================================================================

  Widget _primaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_softBlue.withOpacity(0.95), _blue.withOpacity(0.95)],
              ),
              boxShadow: [
                BoxShadow(
                  color: _blue.withOpacity(0.22),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 9),
                Icon(icon, size: 16, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // SECONDARY BUTTON
  // ===========================================================================

  Widget _secondaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.white.withOpacity(0.035),
              border: Border.all(color: Colors.white.withOpacity(0.10)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.78),
                  ),
                ),
                const SizedBox(width: 9),
                Icon(icon, size: 15, color: Colors.white.withOpacity(0.65)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // MINI SIGNAL
  // ===========================================================================

  Widget _miniSignal(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: _softBlue.withOpacity(0.80)),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.38),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // SECTION NAVIGATION
  // ===========================================================================

  void _scrollToSection(BuildContext context, String section) {
    final keys = <String, GlobalKey>{
      'ecosystem': const GlobalObjectKey('gift-tech-ecosystem'),
      'contact': const GlobalObjectKey('gift-tech-contact'),
    };

    final key = keys[section];

    if (key == null) return;

    final targetContext = key.currentContext;

    if (targetContext == null) {
      // The section may not yet be attached to the widget tree.
      // We intentionally do not force a route here.
      return;
    }

    Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
  }
}
