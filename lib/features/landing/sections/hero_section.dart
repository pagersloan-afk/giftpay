import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';
import '../widgets/phone_showcase_carousel.dart';

/// GiftPay Landing Hero
///
/// Production-focused hero section for the GiftPay web landing page.
///
/// Design goals:
/// - Premium fintech visual hierarchy
/// - Responsive desktop / tablet / mobile layouts
/// - Login remains available without dominating the marketing message
/// - Wallet, utilities, travel and mobility positioned as core capabilities
/// - Phone showcase acts as the primary visual product anchor
/// - Lightweight hover interactions for desktop
/// - No unsupported security, speed, uptime or financial claims
///
/// This widget intentionally does NOT control:
/// - page scrolling
/// - global navigation
/// - landing-page background
/// - authentication logic
class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  static const Color _navy = Color(0xFF273D68);
  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _highlight = Color(0xFF7EA4FF);

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good morning';
    }

    if (hour < 17) {
      return 'Good afternoon';
    }

    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final bool isMobile = width < 760;
    final bool isTablet = width >= 760 && width < 1150;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final animationValue = _animationController.value;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1.0 + (animationValue * 0.35), -1.0),
              end: Alignment(1.0, 1.0 - (animationValue * 0.25)),
              colors: [
                const Color(0xFFEAF0FF),
                Colors.white,
                const Color(0xFFF4F7FF),
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
          child: Stack(
            children: [
              _buildBackgroundGlow(
                alignment: Alignment.topRight,
                size: isMobile ? 260 : 500,
                opacity: 0.10,
              ),
              _buildBackgroundGlow(
                alignment: Alignment.bottomLeft,
                size: isMobile ? 220 : 430,
                opacity: 0.07,
              ),
              child!,
            ],
          ),
        );
      },
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1480),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isMobile ? 18 : 32,
                isMobile ? 24 : 38,
                isMobile ? 18 : 32,
                isMobile ? 58 : 82,
              ),
              child: _buildResponsiveHero(
                context,
                isMobile: isMobile,
                isTablet: isTablet,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // RESPONSIVE HERO
  // ===========================================================================

  Widget _buildResponsiveHero(
    BuildContext context, {
    required bool isMobile,
    required bool isTablet,
  }) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeroIntro(isMobile: true),
          const SizedBox(height: 30),
          _buildPhoneShowcase(isMobile: true),
          const SizedBox(height: 28),
          _buildFeatureCards(context, isMobile: true),
          const SizedBox(height: 28),
          _buildLoginPanel(context, isMobile: true),
        ],
      );
    }

    if (isTablet) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeroIntro(isMobile: false),
          const SizedBox(height: 34),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: _buildFeatureCards(context, isMobile: false),
              ),
              const SizedBox(width: 24),
              Expanded(flex: 5, child: _buildPhoneShowcase(isMobile: false)),
            ],
          ),
          const SizedBox(height: 26),
          _buildLoginPanel(context, isMobile: false),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeroIntro(isMobile: false),
        const SizedBox(height: 42),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: _buildLoginPanel(context, isMobile: false),
            ),
            const SizedBox(width: 28),
            Expanded(
              flex: 6,
              child: _buildFeatureCards(context, isMobile: false),
            ),
            const SizedBox(width: 28),
            Expanded(flex: 5, child: _buildPhoneShowcase(isMobile: false)),
          ],
        ),
      ],
    );
  }

  // ===========================================================================
  // HERO INTRO
  // ===========================================================================

  Widget _buildHeroIntro({required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('THE EVERYDAY DIGITAL PLATFORM'),

        const SizedBox(height: 15),

        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Text(
            'More of your everyday life,\n'
            'connected in one place.',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: isMobile ? 40 : 62,
              height: 1.02,
              fontWeight: FontWeight.w800,
              letterSpacing: isMobile ? -1.6 : -2.8,
              color: _navy,
            ),
          ),
        ),

        const SizedBox(height: 16),

        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Text(
            'GiftPay brings payments, utilities, digital commerce, '
            'travel, ride booking and everyday services into one '
            'connected experience.',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: isMobile ? 16 : 19,
              height: 1.65,
              fontWeight: FontWeight.w400,
              color: _navy.withOpacity(0.62),
            ),
          ),
        ),

        const SizedBox(height: 22),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: const [
            _HeroPill(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Wallet',
            ),
            _HeroPill(icon: Icons.receipt_long_outlined, label: 'Utilities'),
            _HeroPill(icon: Icons.flight_takeoff_outlined, label: 'Travel'),
            _HeroPill(
              icon: Icons.directions_car_outlined,
              label: 'Ride booking',
            ),
          ],
        ),
      ],
    );
  }

  // ===========================================================================
  // FEATURE CARDS
  // ===========================================================================

  Widget _buildFeatureCards(BuildContext context, {required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildWalletCard(context, isMobile: isMobile),
        const SizedBox(height: 16),
        _buildServicesCard(context, isMobile: isMobile),
        const SizedBox(height: 16),
        _buildTravelCard(context, isMobile: isMobile),
      ],
    );
  }

  Widget _buildWalletCard(BuildContext context, {required bool isMobile}) {
    return _HeroGlassCard(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 22 : 26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardIcon(Icons.account_balance_wallet_rounded),

            const SizedBox(height: 18),

            Text(
              'Your digital wallet.',
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: isMobile ? 21 : 23,
                height: 1.15,
                fontWeight: FontWeight.w800,
                color: _navy,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Fund your wallet, manage transactions and keep '
              'everyday payments within a familiar GiftPay experience.',
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: isMobile ? 13.5 : 14,
                height: 1.55,
                color: _navy.withOpacity(0.58),
              ),
            ),

            const SizedBox(height: 18),

            _heroActionButton(
              context,
              label: 'Open Wallet',
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesCard(BuildContext context, {required bool isMobile}) {
    return _HeroGlassCard(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 22 : 26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardIcon(Icons.apps_rounded),

            const SizedBox(height: 18),

            Text(
              'Everyday services.',
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: isMobile ? 21 : 23,
                height: 1.15,
                fontWeight: FontWeight.w800,
                color: _navy,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Airtime, data, electricity, TV, gift cards and other '
              'digital services can live inside one platform.',
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: isMobile ? 13.5 : 14,
                height: 1.55,
                color: _navy.withOpacity(0.58),
              ),
            ),

            const SizedBox(height: 18),

            _heroActionButton(
              context,
              label: 'Explore Services',
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTravelCard(BuildContext context, {required bool isMobile}) {
    return _HeroGlassCard(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 22 : 26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _cardIcon(Icons.flight_takeoff_rounded),
                const SizedBox(width: 10),
                _smallFeatureIcon(Icons.directions_car_rounded),
              ],
            ),

            const SizedBox(height: 18),

            Text(
              'Move. Travel. Explore.',
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: isMobile ? 21 : 23,
                height: 1.15,
                fontWeight: FontWeight.w800,
                color: _navy,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'GiftPay is designed to connect travel and mobility services, '
              'including flight discovery and ride booking through integrated partners.',
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: isMobile ? 13.5 : 14,
                height: 1.55,
                color: _navy.withOpacity(0.58),
              ),
            ),

            const SizedBox(height: 16),

            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: const [
                _ServiceTag(icon: Icons.flight_outlined, label: 'Flights'),
                _ServiceTag(icon: Icons.local_taxi_outlined, label: 'Rides'),
                _ServiceTag(
                  icon: Icons.location_on_outlined,
                  label: 'Mobility',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // LOGIN PANEL
  // ===========================================================================

  Widget _buildLoginPanel(BuildContext context, {required bool isMobile}) {
    return _HeroLoginCard(
      greeting: _getGreeting(),
      isMobile: isMobile,
      onSignIn: () {},
      onEnroll: () {},
      onForgotPassword: () {},
      onSecurity: () {},
      onLegal: () {},
    );
  }

  // ===========================================================================
  // PHONE SHOWCASE
  // ===========================================================================

  Widget _buildPhoneShowcase({required bool isMobile}) {
    return Container(
      constraints: BoxConstraints(minHeight: isMobile ? 350 : 520),
      padding: EdgeInsets.all(isMobile ? 10 : 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.9,
          colors: [
            _blue.withOpacity(0.13),
            Colors.white.withOpacity(0.40),
            Colors.transparent,
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.65)),
      ),
      child: PhoneShowcaseCarousel(
        screens: const [
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
        height: isMobile ? 330 : 480,
      ),
    );
  }

  // ===========================================================================
  // BACKGROUND
  // ===========================================================================

  Widget _buildBackgroundGlow({
    required Alignment alignment,
    required double size,
    required double opacity,
  }) {
    return Align(
      alignment: alignment,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [_blue.withOpacity(opacity), _blue.withOpacity(0.0)],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // COMPONENT HELPERS
  // ===========================================================================

  Widget _sectionLabel(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: _highlight,
          ),
        ),
        const SizedBox(width: 9),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.9,
            color: _blue,
          ),
        ),
      ],
    );
  }

  Widget _cardIcon(IconData icon) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_blue.withOpacity(0.16), _highlight.withOpacity(0.08)],
        ),
        border: Border.all(color: _highlight.withOpacity(0.15)),
      ),
      child: Icon(icon, size: 22, color: _blue),
    );
  }

  Widget _smallFeatureIcon(IconData icon) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: _navy.withOpacity(0.045),
        border: Border.all(color: _navy.withOpacity(0.07)),
      ),
      child: Icon(icon, size: 21, color: _blue),
    );
  }

  Widget _heroActionButton(
    BuildContext context, {
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 46,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// HERO GLASS CARD
// ============================================================================

class _HeroGlassCard extends StatefulWidget {
  final Widget child;

  const _HeroGlassCard({required this.child});

  @override
  State<_HeroGlassCard> createState() => _HeroGlassCardState();
}

class _HeroGlassCardState extends State<_HeroGlassCard> {
  bool _hovered = false;

  static const Color _navy = Color(0xFF273D68);
  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _highlight = Color(0xFF7EA4FF);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (!mounted) return;
        setState(() => _hovered = true);
      },
      onExit: (_) {
        if (!mounted) return;
        setState(() => _hovered = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(_hovered ? 0.86 : 0.72),
              Colors.white.withOpacity(0.47),
              _blue.withOpacity(0.035),
            ],
          ),
          border: Border.all(
            color: _hovered
                ? _highlight.withOpacity(0.22)
                : Colors.white.withOpacity(0.75),
          ),
          boxShadow: [
            BoxShadow(
              color: _navy.withOpacity(_hovered ? 0.11 : 0.065),
              blurRadius: _hovered ? 32 : 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

// ============================================================================
// LOGIN CARD
// ============================================================================

class _HeroLoginCard extends StatefulWidget {
  final String greeting;
  final bool isMobile;
  final VoidCallback onSignIn;
  final VoidCallback onEnroll;
  final VoidCallback onForgotPassword;
  final VoidCallback onSecurity;
  final VoidCallback onLegal;

  const _HeroLoginCard({
    required this.greeting,
    required this.isMobile,
    required this.onSignIn,
    required this.onEnroll,
    required this.onForgotPassword,
    required this.onSecurity,
    required this.onLegal,
  });

  @override
  State<_HeroLoginCard> createState() => _HeroLoginCardState();
}

class _HeroLoginCardState extends State<_HeroLoginCard> {
  bool _rememberUsername = false;
  bool _obscurePassword = true;

  static const Color _navy = Color(0xFF273D68);
  static const Color _blue = Color(0xFF4A6BB8);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(widget.isMobile ? 22 : 26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withOpacity(0.78),
        border: Border.all(color: Colors.white.withOpacity(0.85)),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(0.075),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.greeting,
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: widget.isMobile ? 22 : 24,
              fontWeight: FontWeight.w800,
              color: _navy,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Sign in to your GiftPay account.',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 13,
              color: _navy.withOpacity(0.52),
            ),
          ),

          const SizedBox(height: 24),

          _buildField(label: 'Username', icon: Icons.person_outline_rounded),

          const SizedBox(height: 13),

          _buildField(
            label: 'Password',
            icon: Icons.lock_outline_rounded,
            obscureText: _obscurePassword,
            suffix: IconButton(
              tooltip: _obscurePassword ? 'Show password' : 'Hide password',
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 19,
              ),
            ),
          ),

          const SizedBox(height: 7),

          CheckboxListTile(
            value: _rememberUsername,
            onChanged: (value) {
              setState(() {
                _rememberUsername = value ?? false;
              });
            },
            contentPadding: EdgeInsets.zero,
            dense: true,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(
              'Save username',
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: 13,
                color: _navy.withOpacity(0.70),
              ),
            ),
          ),

          const SizedBox(height: 10),

          if (widget.isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _signInButton(),
                const SizedBox(height: 10),
                _enrollButton(),
              ],
            )
          else
            Row(
              children: [
                Expanded(child: _signInButton()),
                const SizedBox(width: 10),
                Expanded(child: _enrollButton()),
              ],
            ),

          const SizedBox(height: 17),

          _loginLink('Forgot username or password?', widget.onForgotPassword),

          _loginLink('Security Center', widget.onSecurity),

          _loginLink('Privacy, Cookies, and Legal', widget.onLegal),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return TextField(
      obscureText: obscureText,
      style: const TextStyle(fontFamily: 'SegoeUI', fontSize: 14, color: _navy),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 19, color: _navy.withOpacity(0.52)),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white.withOpacity(0.68),
        labelStyle: TextStyle(
          fontFamily: 'SegoeUI',
          fontSize: 13,
          color: _navy.withOpacity(0.55),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 15,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _navy.withOpacity(0.09)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _blue, width: 1.3),
        ),
      ),
    );
  }

  Widget _signInButton() {
    return SizedBox(
      height: 46,
      child: ElevatedButton(
        onPressed: widget.onSignIn,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
        ),
        child: const Text(
          'Sign On',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _enrollButton() {
    return SizedBox(
      height: 46,
      child: OutlinedButton(
        onPressed: widget.onEnroll,
        style: OutlinedButton.styleFrom(
          foregroundColor: _navy,
          side: BorderSide(color: _navy.withOpacity(0.18)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
        ),
        child: const Text(
          'Enroll',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _loginLink(String label, VoidCallback onPressed) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 3),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 12,
            color: _blue.withOpacity(0.82),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// HERO PILL
// ============================================================================

class _HeroPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroPill({required this.icon, required this.label});

  static const Color _navy = Color(0xFF273D68);
  static const Color _blue = Color(0xFF4A6BB8);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.72),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _blue.withOpacity(0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: _blue),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _navy,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SERVICE TAG
// ============================================================================

class _ServiceTag extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ServiceTag({required this.icon, required this.label});

  static const Color _navy = Color(0xFF273D68);
  static const Color _blue = Color(0xFF4A6BB8);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: _blue.withOpacity(0.055),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _blue.withOpacity(0.09)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _blue),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _navy,
            ),
          ),
        ],
      ),
    );
  }
}
