import 'package:flutter/material.dart';

class BusinessDashboardFeaturesSection extends StatelessWidget {
  const BusinessDashboardFeaturesSection({super.key});

  static const Color navy = Color(0xFF273D68);
  static const Color blue = Color(0xFF4A6BB8);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final bool mobile = width < 700;
    final bool tablet = width >= 700 && width < 1050;

    final int columns = mobile
        ? 1
        : tablet
        ? 2
        : 3;

    final double spacing = mobile ? 14 : 18;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading(),

        SizedBox(height: mobile ? 28 : 34),

        GridView.count(
          crossAxisCount: columns,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: mobile
              ? 2.15
              : tablet
              ? 1.45
              : 1.28,
          children: const [
            _BusinessFeatureCard(
              icon: Icons.dashboard_customize_rounded,
              title: 'One business view',
              description:
                  'Keep everyday utility activity organized from one central experience.',
            ),
            _BusinessFeatureCard(
              icon: Icons.flash_on_rounded,
              title: 'Instant vending',
              description:
                  'Deliver supported digital utility services quickly through connected vending providers.',
            ),
            _BusinessFeatureCard(
              icon: Icons.groups_rounded,
              title: 'Team management',
              description:
                  'Structure utility spending around employees, teams and business needs.',
            ),
            _BusinessFeatureCard(
              icon: Icons.account_balance_wallet_rounded,
              title: 'Wallet-powered payments',
              description:
                  'Fund your GiftPay wallet and use it to manage eligible business transactions.',
            ),
            _BusinessFeatureCard(
              icon: Icons.receipt_long_rounded,
              title: 'Transaction visibility',
              description:
                  'Keep a clear record of business utility transactions and payment activity.',
            ),
            _BusinessFeatureCard(
              icon: Icons.insights_rounded,
              title: 'Operational insight',
              description:
                  'Understand spending activity and make better decisions with organized business data.',
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final bool mobile = width < 700;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFF4A6BB8),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Built for the way businesses operate.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: mobile ? 27 : 34,
            height: 1.15,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF273D68),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 11),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: const Text(
            'GiftPay brings business utility payments, vending and '
            'spending visibility together so your team can spend less '
            'time managing routine transactions.',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 15,
              height: 1.65,
              color: Color(0xFF687386),
            ),
          ),
        ),
      ],
    );
  }
}

class _BusinessFeatureCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;

  const _BusinessFeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  State<_BusinessFeatureCard> createState() => _BusinessFeatureCardState();
}

class _BusinessFeatureCardState extends State<_BusinessFeatureCard> {
  bool _hovered = false;

  static const Color navy = Color(0xFF273D68);
  static const Color blue = Color(0xFF4A6BB8);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (mounted) {
          setState(() => _hovered = true);
        }
      },
      onExit: (_) {
        if (mounted) {
          setState(() => _hovered = false);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(22),
        transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _hovered ? const Color(0xFFD3DDF1) : const Color(0xFFE6EAF1),
          ),
          boxShadow: [
            BoxShadow(
              color: navy.withOpacity(_hovered ? 0.09 : 0.045),
              blurRadius: _hovered ? 25 : 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: blue.withOpacity(0.09),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(widget.icon, color: blue, size: 23),
            ),

            const SizedBox(height: 17),

            Text(
              widget.title,
              style: const TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: navy,
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: Text(
                widget.description,
                style: const TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 13,
                  height: 1.55,
                  color: Color(0xFF687386),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
