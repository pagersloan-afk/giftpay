import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class AirtimeHeroSection extends StatelessWidget {
  const AirtimeHeroSection({super.key});

  static const Color navy = Color(0xFF273D68);
  static const Color blue = Color(0xFF4A6BB8);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF7FAFF), Color(0xFFFFFFFF), Color(0xFFF2F6FF)],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1220),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 76, 24, 82),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 900;

                if (isDesktop) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Expanded(flex: 11, child: _HeroCopy()),
                      const SizedBox(width: 70),
                      Expanded(flex: 9, child: _HeroVisual()),
                    ],
                  );
                }

                return const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_HeroCopy(), SizedBox(height: 48), _HeroVisual()],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy();

  static const Color navy = Color(0xFF273D68);
  static const Color blue = Color(0xFF4A6BB8);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: blue.withOpacity(0.08),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: blue.withOpacity(0.12)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cell_tower_outlined, size: 16, color: blue),
              SizedBox(width: 8),
              Text(
                'AIRTIME DISTRIBUTION',
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: blue,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'Keep your teams connected.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 52,
            height: 1.08,
            fontWeight: FontWeight.w800,
            color: navy,
            letterSpacing: -1.2,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Distribute airtime to employees, teams and customers '
          'with a faster, simpler way to manage business connectivity.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 19,
            height: 1.6,
            color: Color(0xFF5F6B7D),
          ),
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 18,
          runSpacing: 12,
          children: const [
            _HeroPoint(
              icon: Icons.check_circle_outline,
              text: 'Multiple networks',
            ),
            _HeroPoint(
              icon: Icons.check_circle_outline,
              text: 'Bulk distribution',
            ),
            _HeroPoint(
              icon: Icons.check_circle_outline,
              text: 'GiftPay Wallet',
            ),
          ],
        ),
        const SizedBox(height: 32),
        const _HeroAction(),
      ],
    );
  }
}

class _HeroPoint extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HeroPoint({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF4A6BB8)),
        const SizedBox(width: 7),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF3D4758),
          ),
        ),
      ],
    );
  }
}

class _HeroAction extends StatelessWidget {
  const _HeroAction();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, '/login');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: GiftPayTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 17),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Get Started',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(width: 10),
          Icon(Icons.arrow_forward_rounded, size: 19),
        ],
      ),
    );
  }
}

class _HeroVisual extends StatelessWidget {
  const _HeroVisual();

  static const Color navy = Color(0xFF273D68);
  static const Color blue = Color(0xFF4A6BB8);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: AspectRatio(
          aspectRatio: 1.05,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(34),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        blue.withOpacity(0.13),
                        Colors.white.withOpacity(0.9),
                        navy.withOpacity(0.08),
                      ],
                    ),
                    border: Border.all(color: Colors.white.withOpacity(0.9)),
                    boxShadow: [
                      BoxShadow(
                        color: navy.withOpacity(0.10),
                        blurRadius: 45,
                        offset: const Offset(0, 22),
                      ),
                    ],
                  ),
                ),
              ),
              const Positioned(
                top: 34,
                left: 34,
                right: 34,
                child: _NetworkHeader(),
              ),
              const Positioned(
                left: 34,
                right: 34,
                top: 118,
                child: _AirtimeBalanceCard(),
              ),
              const Positioned(
                left: 34,
                right: 34,
                bottom: 34,
                child: _DistributionCard(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NetworkHeader extends StatelessWidget {
  const _NetworkHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF273D68),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.signal_cellular_alt_rounded,
            color: Colors.white,
            size: 23,
          ),
        ),
        const SizedBox(width: 13),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Airtime distribution',
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF273D68),
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Business dashboard',
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 12,
                  color: Color(0xFF768196),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: Color(0xFF35B97F),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}

class _AirtimeBalanceCard extends StatelessWidget {
  const _AirtimeBalanceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE7EBF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Available balance',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF788396),
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            '₦250,000',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Color(0xFF273D68),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _NetworkPill(label: 'MTN', color: const Color(0xFFFFC900)),
              const SizedBox(width: 7),
              _NetworkPill(label: 'Airtel', color: const Color(0xFFE62B3A)),
              const SizedBox(width: 7),
              _NetworkPill(label: 'Glo', color: const Color(0xFF48A847)),
              const SizedBox(width: 7),
              _NetworkPill(label: '9mobile', color: const Color(0xFF0E9D65)),
            ],
          ),
        ],
      ),
    );
  }
}

class _NetworkPill extends StatelessWidget {
  final String label;
  final Color color;

  const _NetworkPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'SegoeUI',
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _DistributionCard extends StatelessWidget {
  const _DistributionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF273D68),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF273D68).withOpacity(0.20),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.send_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Team distribution',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  '12 recipients • Delivered',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 11,
                    color: Color(0xFFD7DEEB),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF5CD49C),
            size: 23,
          ),
        ],
      ),
    );
  }
}
