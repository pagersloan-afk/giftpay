import 'package:flutter/material.dart';

class BulkHeroSection extends StatelessWidget {
  const BulkHeroSection({super.key});

  static const Color navy = Color(0xFF273D68);
  static const Color blue = Color(0xFF4A6BB8);
  static const Color lightBlue = Color(0xFF75A1FF);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final bool mobile = width < 700;
    final bool tablet = width >= 700 && width < 1100;

    final double horizontalPadding = mobile
        ? 24
        : tablet
        ? 40
        : 64;

    final double verticalPadding = mobile ? 42 : 68;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF273D68), Color(0xFF304C80), Color(0xFF3D5FA0)],
        ),
        borderRadius: BorderRadius.circular(mobile ? 22 : 28),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.16),
            blurRadius: 35,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: mobile ? -80 : -30,
            top: mobile ? -70 : -90,
            child: _GlowCircle(
              size: mobile ? 190 : 280,
              color: lightBlue.withOpacity(0.14),
            ),
          ),
          Positioned(
            right: mobile ? 20 : 90,
            bottom: mobile ? -90 : -130,
            child: _GlowCircle(
              size: mobile ? 180 : 260,
              color: Colors.white.withOpacity(0.055),
            ),
          ),

          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1050),
            child: mobile
                ? _MobileHeroContent()
                : _DesktopHeroContent(tablet: tablet),
          ),
        ],
      ),
    );
  }
}

class _DesktopHeroContent extends StatelessWidget {
  final bool tablet;

  const _DesktopHeroContent({required this.tablet});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: 6, child: _HeroCopy()),
        const SizedBox(width: 42),
        Expanded(flex: 4, child: _HeroVisual()),
      ],
    );
  }
}

class _MobileHeroContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [_HeroCopy(), SizedBox(height: 34), _HeroVisual()],
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
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: const Text(
            'GIFT PAY • BUSINESS UTILITIES',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          'Bulk Electricity,\nsimplified.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 42,
            height: 1.05,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 20),

        Text(
          'Generate and distribute electricity tokens for '
          'multiple meters from one secure GiftPay workflow.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 17,
            height: 1.55,
            fontWeight: FontWeight.w400,
            color: Colors.white.withOpacity(0.82),
          ),
        ),

        const SizedBox(height: 26),

        const Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _HeroTag(icon: Icons.bolt_rounded, label: 'Fast processing'),
            _HeroTag(icon: Icons.groups_rounded, label: 'Built for teams'),
            _HeroTag(icon: Icons.shield_rounded, label: 'Secure payments'),
          ],
        ),
      ],
    );
  }
}

class _HeroTag extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroTag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.085),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 15,
            color: Color(0xFFBBD0FF),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroVisual extends StatelessWidget {
  const _HeroVisual();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 240, maxWidth: 430),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.075),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.13)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.electric_bolt_rounded,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Text(
                  'Electricity distribution',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          const _MeterRow(meter: 'Meter •••• 4821', status: 'Ready'),
          const SizedBox(height: 11),
          const _MeterRow(meter: 'Meter •••• 7314', status: 'Ready'),
          const SizedBox(height: 11),
          const _MeterRow(meter: 'Meter •••• 9042', status: 'Ready'),

          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            height: 1,
            color: Colors.white.withOpacity(0.10),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 15,
                color: Colors.white.withOpacity(0.65),
              ),
              const SizedBox(width: 7),
              Text(
                'Powered by GiftPay',
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.65),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MeterRow extends StatelessWidget {
  final String meter;
  final String status;

  const _MeterRow({required this.meter, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.055),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.speed_rounded, size: 18, color: Color(0xFFBBD0FF)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              meter,
              style: const TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          Text(
            status,
            style: const TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFFBBD0FF),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
