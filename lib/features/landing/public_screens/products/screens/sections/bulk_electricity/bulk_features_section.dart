import 'package:flutter/material.dart';

class BulkFeaturesSection extends StatelessWidget {
  const BulkFeaturesSection({super.key});

  static const Color navy = Color(0xFF273D68);
  static const Color blue = Color(0xFF4A6BB8);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final bool mobile = width < 700;
    final bool tablet = width >= 700 && width < 1050;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: mobile ? 20 : 34,
        vertical: mobile ? 28 : 38,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE7EBF2)),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.045),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: const [
                Text(
                  'Built for everyday electricity operations',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 27,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    color: navy,
                  ),
                ),
                SizedBox(height: 11),
                SizedBox(
                  width: 720,
                  child: Text(
                    'GiftPay makes it easier for businesses, estates, '
                    'teams and service operators to manage multiple '
                    'electricity token purchases from one place.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 15,
                      height: 1.6,
                      color: Color(0xFF687386),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          LayoutBuilder(
            builder: (context, constraints) {
              if (mobile) {
                return const Column(
                  children: [
                    _FeatureCard(
                      icon: Icons.bolt_rounded,
                      title: 'Bulk token generation',
                      description:
                          'Process electricity token purchases for '
                          'multiple meters without handling each '
                          'request separately.',
                    ),
                    SizedBox(height: 14),
                    _FeatureCard(
                      icon: Icons.groups_rounded,
                      title: 'Built for teams',
                      description:
                          'Support staff, tenants, field teams and '
                          'distributed operations with a centralized '
                          'utility workflow.',
                    ),
                    SizedBox(height: 14),
                    _FeatureCard(
                      icon: Icons.flash_on_rounded,
                      title: 'Fast delivery',
                      description:
                          'Keep token distribution moving with a '
                          'simple digital process designed for '
                          'speed and convenience.',
                    ),
                    SizedBox(height: 14),
                    _FeatureCard(
                      icon: Icons.account_balance_wallet_rounded,
                      title: 'Wallet-powered payments',
                      description:
                          'Use your GiftPay balance as a convenient '
                          'way to manage approved utility payments.',
                    ),
                  ],
                );
              }

              final double cardWidth = tablet
                  ? (constraints.maxWidth - 16) / 2
                  : (constraints.maxWidth - 48) / 4;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: const _FeatureCard(
                      icon: Icons.bolt_rounded,
                      title: 'Bulk token generation',
                      description:
                          'Process electricity token purchases for '
                          'multiple meters without handling each '
                          'request separately.',
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: const _FeatureCard(
                      icon: Icons.groups_rounded,
                      title: 'Built for teams',
                      description:
                          'Support staff, tenants, field teams and '
                          'distributed operations with a centralized '
                          'utility workflow.',
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: const _FeatureCard(
                      icon: Icons.flash_on_rounded,
                      title: 'Fast delivery',
                      description:
                          'Keep token distribution moving with a '
                          'simple digital process designed for speed '
                          'and convenience.',
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: const _FeatureCard(
                      icon: Icons.account_balance_wallet_rounded,
                      title: 'Wallet-powered payments',
                      description:
                          'Use your GiftPay balance as a convenient '
                          'way to manage approved utility payments.',
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 34),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: blue, size: 21),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Availability and processing may depend on the '
                    'electricity provider, meter type and applicable '
                    'service conditions.',
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 13,
                      height: 1.5,
                      color: Color(0xFF687386),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  static const Color navy = Color(0xFF273D68);
  static const Color blue = Color(0xFF4A6BB8);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 205),
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7EBF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: blue.withOpacity(0.09),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: blue, size: 23),
          ),

          const SizedBox(height: 17),

          Text(
            title,
            style: const TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: navy,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            description,
            style: const TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 13,
              height: 1.55,
              color: Color(0xFF687386),
            ),
          ),
        ],
      ),
    );
  }
}
