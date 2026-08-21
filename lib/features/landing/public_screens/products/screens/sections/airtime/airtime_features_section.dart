import 'package:flutter/material.dart';

class AirtimeFeaturesSection extends StatelessWidget {
  const AirtimeFeaturesSection({super.key});

  static const Color navy = Color(0xFF273D68);
  static const Color blue = Color(0xFF4A6BB8);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Everything your business needs',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: navy,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: SizedBox(
                width: 720,
                child: Text(
                  'GiftPay makes airtime distribution easier to manage, '
                  'more transparent and better suited for modern Nigerian businesses.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 16,
                    height: 1.6,
                    color: Color(0xFF687386),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 38),
            _buildGrid(width),
          ],
        );
      },
    );
  }

  Widget _buildGrid(double width) {
    final columns = width >= 1100
        ? 3
        : width >= 700
        ? 2
        : 1;

    final cards = const [
      _FeatureCardData(
        icon: Icons.autorenew_rounded,
        title: 'Automated allowances',
        description:
            'Set recurring airtime allowances for employees, teams or operational groups.',
      ),
      _FeatureCardData(
        icon: Icons.network_cell_rounded,
        title: 'Major networks',
        description:
            'Support airtime distribution across MTN, Airtel, Glo and 9mobile.',
      ),
      _FeatureCardData(
        icon: Icons.groups_rounded,
        title: 'Bulk distribution',
        description:
            'Send airtime to multiple recipients without handling each transaction manually.',
      ),
      _FeatureCardData(
        icon: Icons.flash_on_rounded,
        title: 'Fast delivery',
        description:
            'Give your recipients a convenient airtime experience with fast processing.',
      ),
      _FeatureCardData(
        icon: Icons.account_balance_wallet_rounded,
        title: 'GiftPay Wallet',
        description:
            'Manage business airtime spending through your centralized GiftPay wallet.',
      ),
      _FeatureCardData(
        icon: Icons.receipt_long_rounded,
        title: 'Transaction visibility',
        description:
            'Keep your distribution activity organized with accessible transaction records.',
      ),
    ];

    if (columns == 1) {
      return Column(
        children: [
          for (int i = 0; i < cards.length; i++) ...[
            _FeatureCard(data: cards[i]),
            if (i != cards.length - 1) const SizedBox(height: 16),
          ],
        ],
      );
    }

    final rows = <Widget>[];

    for (int i = 0; i < cards.length; i += columns) {
      final rowCards = <Widget>[];

      for (int j = 0; j < columns; j++) {
        final index = i + j;

        if (index < cards.length) {
          rowCards.add(Expanded(child: _FeatureCard(data: cards[index])));
        } else {
          rowCards.add(const Expanded(child: SizedBox()));
        }

        if (j != columns - 1) {
          rowCards.add(const SizedBox(width: 18));
        }
      }

      rows.add(
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: rowCards),
      );

      if (i + columns < cards.length) {
        rows.add(const SizedBox(height: 18));
      }
    }

    return Column(children: rows);
  }
}

class _FeatureCardData {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureCardData({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _FeatureCard extends StatelessWidget {
  final _FeatureCardData data;

  const _FeatureCard({required this.data});

  static const Color navy = Color(0xFF273D68);
  static const Color blue = Color(0xFF4A6BB8);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5EAF2)),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.045),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: blue.withOpacity(0.09),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(data.icon, color: blue, size: 25),
          ),
          const SizedBox(height: 20),
          Text(
            data.title,
            style: const TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: navy,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            data.description,
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
