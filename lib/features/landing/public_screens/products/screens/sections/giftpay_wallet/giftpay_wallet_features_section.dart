import 'package:flutter/material.dart';

class GiftPayWalletFeaturesSection extends StatelessWidget {
  const GiftPayWalletFeaturesSection({super.key});

  static const Color navy = Color(0xFF273D68);
  static const Color blue = Color(0xFF4A6BB8);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final bool mobile = width < 700;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(mobile ? 22 : 38),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE7EBF2)),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.055),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section heading
          Center(
            child: Column(
              children: const [
                Text(
                  'Everything you need to manage payments',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 28,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    color: navy,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'A simple wallet experience built around the services you use every day.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 15,
                    height: 1.55,
                    color: Color(0xFF687386),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          LayoutBuilder(
            builder: (context, constraints) {
              final int columns = constraints.maxWidth >= 1000
                  ? 3
                  : constraints.maxWidth >= 650
                  ? 2
                  : 1;

              const double spacing = 16;

              final double cardWidth = columns == 1
                  ? constraints.maxWidth
                  : (constraints.maxWidth - ((columns - 1) * spacing)) /
                        columns;

              final cards = const [
                _WalletFeatureCard(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Wallet balance',
                  description:
                      'Keep funds available for your next payment and see your available balance clearly.',
                ),
                _WalletFeatureCard(
                  icon: Icons.flash_on_outlined,
                  title: 'Fast service payments',
                  description:
                      'Use your wallet to purchase supported airtime, data, electricity and digital services.',
                ),
                _WalletFeatureCard(
                  icon: Icons.receipt_long_outlined,
                  title: 'Transaction history',
                  description:
                      'Review your wallet activity and keep track of completed payment transactions.',
                ),
                _WalletFeatureCard(
                  icon: Icons.business_center_outlined,
                  title: 'Built for personal and business use',
                  description:
                      'Manage recurring utility needs and business payment activity from one platform.',
                ),
                _WalletFeatureCard(
                  icon: Icons.lock_outline_rounded,
                  title: 'Account protection',
                  description:
                      'GiftPay is designed with account controls and secure authentication around your wallet activity.',
                ),
                _WalletFeatureCard(
                  icon: Icons.grid_view_rounded,
                  title: 'One GiftPay experience',
                  description:
                      'Access supported GiftPay services without maintaining separate balances for every utility.',
                ),
              ];

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: cards
                    .map((card) => SizedBox(width: cardWidth, child: card))
                    .toList(),
              );
            },
          ),

          const SizedBox(height: 30),

          // Product flow
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(mobile ? 18 : 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF2F6FF), Color(0xFFF9FBFF)],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFDCE5F7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'How the GiftPay Wallet works',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: navy,
                  ),
                ),
                const SizedBox(height: 18),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final bool compact = constraints.maxWidth < 700;

                    final steps = const [
                      _WalletStep(
                        number: '01',
                        title: 'Fund',
                        description:
                            'Add funds to your GiftPay wallet through the available funding options.',
                      ),
                      _WalletStep(
                        number: '02',
                        title: 'Choose',
                        description:
                            'Select the service you want to pay for from the GiftPay platform.',
                      ),
                      _WalletStep(
                        number: '03',
                        title: 'Pay',
                        description:
                            'Confirm the transaction and receive the applicable service or confirmation.',
                      ),
                    ];

                    if (compact) {
                      return Column(
                        children: [
                          for (int i = 0; i < steps.length; i++) ...[
                            steps[i],
                            if (i != steps.length - 1)
                              const SizedBox(height: 14),
                          ],
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int i = 0; i < steps.length; i++) ...[
                          Expanded(child: steps[i]),
                          if (i != steps.length - 1)
                            const Padding(
                              padding: EdgeInsets.only(
                                top: 18,
                                left: 12,
                                right: 12,
                              ),
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                                color: blue,
                              ),
                            ),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _WalletFeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  static const Color navy = Color(0xFF273D68);
  static const Color blue = Color(0xFF4A6BB8);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFD),
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
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: navy,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            description,
            style: const TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 13.5,
              height: 1.55,
              color: Color(0xFF687386),
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletStep extends StatelessWidget {
  final String number;
  final String title;
  final String description;

  const _WalletStep({
    required this.number,
    required this.title,
    required this.description,
  });

  static const Color navy = Color(0xFF273D68);
  static const Color blue = Color(0xFF4A6BB8);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: blue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            number,
            style: const TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: navy,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                description,
                style: const TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 13,
                  height: 1.5,
                  color: Color(0xFF687386),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
