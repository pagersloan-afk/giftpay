import 'package:flutter/material.dart';

class GiftPayApiFeaturesSection extends StatelessWidget {
  const GiftPayApiFeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final bool mobile = width < 700;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: mobile ? 20 : 42,
        vertical: mobile ? 30 : 42,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE4E9F2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF273D68).withOpacity(0.055),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionIntro(),
          const SizedBox(height: 28),
          _FeatureGrid(mobile: mobile),
        ],
      ),
    );
  }
}

class _SectionIntro extends StatelessWidget {
  const _SectionIntro();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF4A6BB8).withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'ONE INTEGRATION LAYER',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 10,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w900,
              color: Color(0xFF4A6BB8),
            ),
          ),
        ),
        const SizedBox(height: 13),
        const Text(
          'Infrastructure built for real transactions.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 28,
            height: 1.15,
            fontWeight: FontWeight.w900,
            color: Color(0xFF273D68),
          ),
        ),
        const SizedBox(height: 9),
        const Text(
          'Connect your application to GiftPay and orchestrate digital utility '
          'services without building every vending integration from scratch.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 15,
            height: 1.6,
            color: Color(0xFF687386),
          ),
        ),
      ],
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  final bool mobile;

  const _FeatureGrid({required this.mobile});

  @override
  Widget build(BuildContext context) {
    const cards = [
      _ApiFeatureCard(
        icon: Icons.bolt_rounded,
        title: 'Utility vending',
        description:
            'Programmatically initiate supported utility transactions '
            'from your own application.',
      ),
      _ApiFeatureCard(
        icon: Icons.phone_android_rounded,
        title: 'Airtime & data',
        description:
            'Connect airtime and data experiences to your product with '
            'a consistent transaction workflow.',
      ),
      _ApiFeatureCard(
        icon: Icons.flash_on_rounded,
        title: 'Electricity',
        description:
            'Build electricity vending experiences around meter and '
            'token transaction flows.',
      ),
      _ApiFeatureCard(
        icon: Icons.account_balance_wallet_rounded,
        title: 'Wallet infrastructure',
        description:
            'Use controlled wallet debit and credit flows for eligible '
            'business transaction experiences.',
      ),
      _ApiFeatureCard(
        icon: Icons.webhook_rounded,
        title: 'Transaction webhooks',
        description:
            'Receive transaction lifecycle events so your systems can '
            'synchronize status reliably.',
      ),
      _ApiFeatureCard(
        icon: Icons.security_rounded,
        title: 'Secure integration',
        description:
            'Designed around authenticated API requests, references, '
            'transaction tracking and controlled access.',
      ),
    ];

    if (mobile) {
      return Column(
        children: [
          cards[0],
          const SizedBox(height: 12),
          cards[1],
          const SizedBox(height: 12),
          cards[2],
          const SizedBox(height: 12),
          cards[3],
          const SizedBox(height: 12),
          cards[4],
          const SizedBox(height: 12),
          cards[5],
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = (constraints.maxWidth - 24) / 3;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final card in cards) SizedBox(width: cardWidth, child: card),
          ],
        );
      },
    );
  }
}

class _ApiFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _ApiFeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE5EAF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: const Color(0xFF4A6BB8).withOpacity(0.09),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, size: 21, color: const Color(0xFF4A6BB8)),
          ),
          const SizedBox(height: 15),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Color(0xFF273D68),
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
