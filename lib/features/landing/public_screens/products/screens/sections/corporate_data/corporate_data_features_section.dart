import 'package:flutter/material.dart';

class CorporateDataFeaturesSection extends StatelessWidget {
  const CorporateDataFeaturesSection({super.key});

  static const Color _navy = Color(0xFF273D68);
  static const Color _blue = Color(0xFF4A6BB8);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final bool mobile = width < 700;
    final bool tablet = width >= 700 && width < 1100;

    final int columns = mobile
        ? 1
        : tablet
        ? 2
        : 3;

    const features = [
      _CorporateFeature(
        icon: Icons.bolt_rounded,
        title: 'Instant digital vending',
        description:
            'Purchase and provision eligible data services quickly through '
            'GiftPay digital vending infrastructure.',
      ),
      _CorporateFeature(
        icon: Icons.groups_rounded,
        title: 'Employee connectivity',
        description:
            'Support employee and team connectivity with centrally managed '
            'business data requirements.',
      ),
      _CorporateFeature(
        icon: Icons.devices_rounded,
        title: 'Device provisioning',
        description:
            'Organize connectivity for business devices, operational lines '
            'and other connected endpoints.',
      ),
      _CorporateFeature(
        icon: Icons.account_balance_wallet_rounded,
        title: 'Centralized wallet',
        description:
            'Manage business utility spending from your GiftPay Wallet '
            'instead of handling multiple payment flows.',
      ),
      _CorporateFeature(
        icon: Icons.receipt_long_rounded,
        title: 'Transaction visibility',
        description:
            'Keep your business activity organized with clear transaction '
            'records and digital payment history.',
      ),
      _CorporateFeature(
        icon: Icons.dashboard_customize_rounded,
        title: 'One business platform',
        description:
            'Bring data and other supported digital services together '
            'inside one modern GiftPay business environment.',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              children: const [
                Text(
                  'Everything your business needs to stay connected.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 30,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                    color: _navy,
                  ),
                ),
                SizedBox(height: 13),
                Text(
                  'GiftPay brings business connectivity and digital utility '
                  'management into one secure, simple experience.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 16,
                    height: 1.6,
                    color: Color(0xFF687386),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        LayoutBuilder(
          builder: (context, constraints) {
            final double spacing = mobile ? 14 : 18;
            final double cardWidth =
                (constraints.maxWidth - ((columns - 1) * spacing)) / columns;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: features.map((feature) {
                return SizedBox(
                  width: cardWidth,
                  child: _FeatureCard(feature: feature),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _CorporateFeature {
  final IconData icon;
  final String title;
  final String description;

  const _CorporateFeature({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _FeatureCard extends StatelessWidget {
  final _CorporateFeature feature;

  const _FeatureCard({required this.feature});

  static const Color _navy = Color(0xFF273D68);
  static const Color _blue = Color(0xFF4A6BB8);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 190),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5EAF2)),
        boxShadow: [
          BoxShadow(
            color: _navy.withOpacity(0.055),
            blurRadius: 24,
            offset: const Offset(0, 10),
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
              color: _blue.withOpacity(0.09),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(feature.icon, color: _blue, size: 24),
          ),
          const SizedBox(height: 17),
          Text(
            feature.title,
            style: const TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: _navy,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            feature.description,
            style: const TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 14,
              height: 1.55,
              color: Color(0xFF687386),
            ),
          ),
        ],
      ),
    );
  }
}
