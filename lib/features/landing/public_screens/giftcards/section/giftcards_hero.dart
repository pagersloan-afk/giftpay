import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class GiftCardsHeroSection extends StatelessWidget {
  const GiftCardsHeroSection({super.key});

  static const Color navy = Color(0xFF273D68);
  static const Color blue = Color(0xFF4A6BB8);
  static const Color lightBlue = Color(0xFF75A1FF);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < 700;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 360),
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
            right: mobile ? -70 : -30,
            top: mobile ? -60 : -80,
            child: Container(
              width: mobile ? 210 : 300,
              height: mobile ? 210 : 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: lightBlue.withOpacity(0.14),
              ),
            ),
          ),
          Positioned(
            right: mobile ? -50 : 100,
            bottom: -100,
            child: Container(
              width: mobile ? 180 : 260,
              height: mobile ? 180 : 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(mobile ? 24 : 48),
            child: mobile ? _MobileHero() : const _DesktopHero(),
          ),
        ],
      ),
    );
  }
}

class _DesktopHero extends StatelessWidget {
  const _DesktopHero();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(flex: 6, child: _HeroCopy()),
        const SizedBox(width: 40),
        Expanded(flex: 4, child: _GiftCardVisual()),
      ],
    );
  }
}

class _MobileHero extends StatelessWidget {
  const _MobileHero();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_HeroCopy(), SizedBox(height: 28), _GiftCardVisual()],
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.11),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.16)),
          ),
          child: const Text(
            'GIFTPAY GIFT CARDS',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Give something they\'ll actually love.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 42,
            height: 1.08,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Buy digital gift cards for entertainment, shopping, gaming and everyday experiences — delivered instantly through GiftPay.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 17,
            height: 1.55,
            color: Colors.white.withOpacity(0.82),
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: const [
            _TrustPill(icon: Icons.bolt_rounded, label: 'Instant delivery'),
            _TrustPill(icon: Icons.lock_rounded, label: 'Secure checkout'),
            _TrustPill(
              icon: Icons.card_giftcard_rounded,
              label: 'Digital delivery',
            ),
          ],
        ),
        const SizedBox(height: 28),
        ElevatedButton.icon(
          onPressed: null,
          icon: Icon(
            Icons.arrow_forward_rounded,
            color: GiftPayTheme.primaryBlue,
          ),
          label: Text(
            'Browse Gift Cards',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: GiftPayTheme.primaryBlue,
            ),
          ),
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Colors.white),
            foregroundColor: WidgetStateProperty.all(GiftPayTheme.primaryBlue),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
            ),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
          ),
        ),
      ],
    );
  }
}

class _GiftCardVisual extends StatelessWidget {
  const _GiftCardVisual();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform.rotate(
        angle: -0.035,
        child: Container(
          width: 270,
          height: 175,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFFFFF), Color(0xFFE9F0FF)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.20),
                blurRadius: 30,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -25,
                top: -35,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF4A6BB8).withOpacity(0.12),
                  ),
                ),
              ),
              const Align(
                alignment: Alignment.topLeft,
                child: Icon(
                  Icons.card_giftcard_rounded,
                  size: 34,
                  color: Color(0xFF4A6BB8),
                ),
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'GiftPay',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF273D68),
                  ),
                ),
              ),
              const Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'DIGITAL GIFT CARD',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3,
                    color: Color(0xFF687386),
                  ),
                ),
              ),
            ],
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
        color: Colors.white.withOpacity(0.09),
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
              fontFamily: 'SegoeUI',
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
