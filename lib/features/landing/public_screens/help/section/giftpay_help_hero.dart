import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class GiftPayHelpHero extends StatelessWidget {
  const GiftPayHelpHero({super.key});

  static const Color navy = Color(0xFF273D68);
  static const Color blue = Color(0xFF4A6BB8);
  static const Color lightBlue = Color(0xFF75A1FF);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < 700;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(mobile ? 22 : 30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [navy, blue, Color(0xFF35558F)],
        ),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.20),
            blurRadius: 35,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: mobile ? -80 : -30,
            top: mobile ? -80 : -100,
            child: Container(
              width: mobile ? 230 : 330,
              height: mobile ? 230 : 330,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: lightBlue.withOpacity(0.13),
              ),
            ),
          ),
          Positioned(
            right: mobile ? -60 : 120,
            bottom: -120,
            child: Container(
              width: mobile ? 190 : 270,
              height: mobile ? 190 : 270,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.055),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(mobile ? 24 : 48),
            child: mobile
                ? const _MobileHeroContent()
                : const _DesktopHeroContent(),
          ),
        ],
      ),
    );
  }
}

class _DesktopHeroContent extends StatelessWidget {
  const _DesktopHeroContent();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(flex: 7, child: _HeroCopy()),
        SizedBox(width: 45),
        Expanded(flex: 3, child: _HeroVisual()),
      ],
    );
  }
}

class _MobileHeroContent extends StatelessWidget {
  const _MobileHeroContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_HeroCopy(), SizedBox(height: 30), _HeroVisual()],
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy();

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 700;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: const Text(
            'GIFTPAY HELP CENTRE',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.25,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Need help with GiftPay?',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: mobile ? 34 : 48,
            height: 1.08,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          'Find clear answers about your account, payments, gift cards, '
          'airtime, data, bills, flights and other GiftPay services.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: mobile ? 15 : 17,
            height: 1.55,
            color: Colors.white.withOpacity(0.82),
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 9,
          runSpacing: 9,
          children: const [
            _TrustPill(icon: Icons.search_rounded, label: 'Find answers'),
            _TrustPill(icon: Icons.support_agent_rounded, label: 'Support'),
            _TrustPill(icon: Icons.security_rounded, label: 'Secure help'),
          ],
        ),
      ],
    );
  }
}

class _HeroVisual extends StatelessWidget {
  const _HeroVisual();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 230,
        height: 230,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.075),
          border: Border.all(color: Colors.white.withOpacity(0.13)),
        ),
        child: Center(
          child: Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.18),
                  Colors.white.withOpacity(0.055),
                ],
              ),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.14),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              size: 76,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _TrustPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TrustPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.085),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
