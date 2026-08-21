import 'package:flutter/material.dart';

class BusinessDashboardHeroSection extends StatelessWidget {
  const BusinessDashboardHeroSection({super.key});

  static const Color navy = Color(0xFF273D68);
  static const Color blue = Color(0xFF4A6BB8);
  static const Color lightBlue = Color(0xFF75A1FF);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final bool mobile = width < 700;
    final bool tablet = width >= 700 && width < 1100;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: mobile
            ? 22
            : tablet
            ? 42
            : 72,
        vertical: mobile ? 52 : 78,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1F3157), Color(0xFF273D68), Color(0xFF34558F)],
        ),
        borderRadius: BorderRadius.circular(mobile ? 24 : 30),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.16),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -80,
            child: _GlowCircle(
              size: mobile ? 190 : 280,
              color: lightBlue,
              opacity: 0.10,
            ),
          ),
          Positioned(
            bottom: -120,
            left: -80,
            child: _GlowCircle(
              size: mobile ? 200 : 300,
              color: blue,
              opacity: 0.12,
            ),
          ),
          Positioned(
            right: mobile ? -20 : 80,
            top: mobile ? 170 : 85,
            child: Icon(
              Icons.business_rounded,
              size: mobile ? 110 : 180,
              color: Colors.white.withOpacity(0.035),
            ),
          ),
          mobile ? const _MobileHeroContent() : const _DesktopHeroContent(),
        ],
      ),
    );
  }
}

class _DesktopHeroContent extends StatelessWidget {
  const _DesktopHeroContent();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: 6, child: _HeroCopy()),
        SizedBox(width: width < 1200 ? 35 : 70),
        const Expanded(flex: 4, child: _BusinessPreview()),
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
      children: [_HeroCopy(), SizedBox(height: 38), _BusinessPreview()],
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final bool mobile = width < 700;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.14)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.business_center_rounded,
                size: 15,
                color: Color(0xFFBFD3FF),
              ),
              SizedBox(width: 7),
              Text(
                'GIFT PAY FOR BUSINESS',
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: Color(0xFFBFD3FF),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        Text(
          'One control center for your business utilities.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: mobile ? 34 : 48,
            height: 1.08,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.8,
          ),
        ),

        const SizedBox(height: 20),

        Text(
          'Give your team a smarter way to manage airtime, data, '
          'electricity and other everyday business payments — '
          'with GiftPay handling the experience from one secure platform.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: mobile ? 16 : 18,
            height: 1.65,
            color: Colors.white.withOpacity(0.76),
          ),
        ),

        const SizedBox(height: 28),

        const Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _HeroBadge(icon: Icons.flash_on_rounded, text: 'Instant vending'),
            _HeroBadge(
              icon: Icons.account_balance_wallet_rounded,
              text: 'Wallet payments',
            ),
            _HeroBadge(
              icon: Icons.analytics_rounded,
              text: 'Business visibility',
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HeroBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFFAFC8FF)),
          const SizedBox(width: 7),
          Text(
            text,
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

class _BusinessPreview extends StatelessWidget {
  const _BusinessPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 430),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.075),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.dashboard_rounded,
                  color: Colors.white,
                  size: 19,
                ),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Text(
                  'Business overview',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF6FE3A1),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: const [
              Expanded(
                child: _MetricCard(
                  label: 'Utilities',
                  value: 'Active',
                  icon: Icons.bolt_rounded,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  label: 'Team',
                  value: 'Managed',
                  icon: Icons.groups_rounded,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Business activity',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 12,
                    color: Color(0xFFB9C8E5),
                  ),
                ),
                SizedBox(height: 9),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Payments & vending',
                        style: TextStyle(
                          fontFamily: 'SegoeUI',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.trending_up_rounded,
                      color: Color(0xFF8FB2FF),
                      size: 19,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF9FBCFF), size: 19),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 11,
              color: Color(0xFFAEBBD2),
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
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(opacity),
      ),
    );
  }
}
