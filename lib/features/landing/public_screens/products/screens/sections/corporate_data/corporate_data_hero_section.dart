import 'package:flutter/material.dart';

class CorporateDataHeroSection extends StatelessWidget {
  const CorporateDataHeroSection({super.key});

  static const Color _navy = Color(0xFF273D68);
  static const Color _blue = Color(0xFF4A6BB8);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final bool mobile = width < 700;
    final bool tablet = width >= 700 && width < 1100;

    final double horizontalPadding = mobile
        ? 22
        : tablet
        ? 40
        : 72;

    final double verticalPadding = mobile
        ? 46
        : tablet
        ? 64
        : 88;

    final double titleSize = mobile
        ? 34
        : tablet
        ? 44
        : 56;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF273D68), Color(0xFF314E83), Color(0xFF4A6BB8)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: mobile ? -80 : -40,
            top: mobile ? -70 : -90,
            child: _GlowCircle(size: mobile ? 190 : 300, color: _blue),
          ),
          Positioned(
            right: mobile ? -30 : 120,
            bottom: mobile ? -100 : -150,
            child: _GlowCircle(
              size: mobile ? 150 : 240,
              color: Colors.white,
              opacity: 0.055,
            ),
          ),
          Column(
            crossAxisAlignment: mobile
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withOpacity(0.16)),
                ),
                child: const Text(
                  'BUSINESS CONNECTIVITY',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 850),
                child: Text(
                  'Corporate data, built for the way your business works.',
                  textAlign: mobile ? TextAlign.center : TextAlign.left,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: titleSize,
                    height: 1.08,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.2,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Text(
                  'Provision data for employees, teams and connected devices '
                  'from one secure GiftPay platform. Manage business '
                  'connectivity with simple, fast and reliable digital vending.',
                  textAlign: mobile ? TextAlign.center : TextAlign.left,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: mobile ? 16 : 18,
                    height: 1.6,
                    color: Colors.white.withOpacity(0.82),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Wrap(
                alignment: mobile ? WrapAlignment.center : WrapAlignment.start,
                spacing: 10,
                runSpacing: 10,
                children: const [
                  _HeroBadge(
                    icon: Icons.bolt_rounded,
                    label: 'Instant vending',
                  ),
                  _HeroBadge(
                    icon: Icons.groups_rounded,
                    label: 'Built for teams',
                  ),
                  _HeroBadge(
                    icon: Icons.security_rounded,
                    label: 'Secure platform',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.09),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 7),
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

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _GlowCircle({
    required this.size,
    required this.color,
    this.opacity = 0.10,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(opacity),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(opacity),
              blurRadius: size * 0.35,
              spreadRadius: size * 0.05,
            ),
          ],
        ),
      ),
    );
  }
}
