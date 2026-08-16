import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class GiftTechBusinessesScreen extends StatelessWidget {
  const GiftTechBusinessesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GiftTechPageTemplate(
      title: 'Businesses',
      description:
          'Digital infrastructure for businesses that need dependable payments, utility services, transaction management, and connected operational tools.',
      eyebrow: 'GIFT TECHNOLOGY / BUSINESS',
      icon: Icons.business_center_rounded,
      metaLabel: 'BUSINESS PLATFORM',
      metaValue: 'Payments • Utilities • Operations',
      secondaryMetaLabel: 'SERVICES',
      secondaryMetaValue: 'GiftPOS • GiftPay • API',
      child: const _BusinessesContent(),
    );
  }
}

class _BusinessesContent extends StatelessWidget {
  const _BusinessesContent();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 720;
    final horizontal = isMobile
        ? 20.0
        : width < 1100
        ? 34.0
        : 56.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeroPanel(isMobile: isMobile),
          const SizedBox(height: 22),
          _SectionHeading(
            eyebrow: 'BUSINESS INFRASTRUCTURE',
            title:
                'Technology that helps businesses move money and manage operations.',
            description:
                'Gift Technology combines payment acceptance, utility services, transaction tools, and developer infrastructure into a connected digital ecosystem for businesses.',
          ),
          const SizedBox(height: 14),
          _CoreProducts(isMobile: isMobile),
          const SizedBox(height: 22),
          _SectionHeading(
            eyebrow: 'GROWTH & OPERATIONS',
            title:
                'Built around the transactions your business handles every day.',
            description:
                'From accepting customer payments to purchasing utilities and reviewing transaction activity, our business capabilities are designed to keep essential operations connected.',
          ),
          const SizedBox(height: 14),
          _OperationsGrid(isMobile: isMobile),
          const SizedBox(height: 22),
          _SectionHeading(
            eyebrow: 'GIFT PAY API',
            title:
                'Connect your own applications to digital transaction services.',
            description:
                'The GiftPay API provides REST-based capabilities for businesses and developers integrating digital payments and utility vending into their own products and workflows.',
          ),
          const SizedBox(height: 14),
          _ApiPanel(isMobile: isMobile),
          const SizedBox(height: 22),
          _BusinessTypesPanel(isMobile: isMobile),
          const SizedBox(height: 22),
          _SecurityPanel(isMobile: isMobile),
        ],
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  final bool isMobile;

  const _HeroPanel({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 23 : 32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF273D68), Color(0xFF15233F), Color(0xFF0D1527)],
        ),
        border: Border.all(color: Colors.white.withOpacity(.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.20),
            blurRadius: 35,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroIcon(),
                const SizedBox(height: 20),
                const _HeroCopy(),
              ],
            )
          : Row(
              children: [
                _HeroIcon(),
                const SizedBox(width: 22),
                const Expanded(child: _HeroCopy()),
                const SizedBox(width: 20),
                _HeroBadge(),
              ],
            ),
    );
  }
}

class _HeroIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withOpacity(.07),
        border: Border.all(color: Colors.white.withOpacity(.12)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF75A1FF).withOpacity(.18),
            blurRadius: 30,
          ),
        ],
      ),
      child: const Icon(
        Icons.business_center_rounded,
        size: 34,
        color: Color(0xFF75A1FF),
      ),
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
        const Text(
          'GIFT TECHNOLOGY / BUSINESS',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
            color: Color(0xFF75A1FF),
          ),
        ),
        const SizedBox(height: 9),
        const Text(
          'Digital infrastructure for modern businesses.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 25,
            height: 1.15,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Run payments, utilities, point-of-sale transactions, and '
          'digital integrations through Gift Technology business services.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 13,
            height: 1.65,
            color: Colors.white.withOpacity(.62),
          ),
        ),
      ],
    );
  }
}

class _HeroBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(.055),
        border: Border.all(color: Colors.white.withOpacity(.10)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BUSINESS ECOSYSTEM',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: Color(0xFF75A1FF),
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Payments + Operations',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String description;

  const _SectionHeading({
    required this.eyebrow,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.7,
            color: Color(0xFF75A1FF),
          ),
        ),
        const SizedBox(height: 7),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          description,
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 12.5,
            height: 1.58,
            color: Colors.white.withOpacity(.48),
          ),
        ),
      ],
    );
  }
}

class _CoreProducts extends StatelessWidget {
  final bool isMobile;

  const _CoreProducts({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    const products = [
      (
        Icons.point_of_sale_rounded,
        'GiftPOS',
        'Accept card and transfer payments, print receipts, review transaction history, manage settlements, and support multiple terminals and staff accounts.',
      ),
      (
        Icons.account_balance_wallet_rounded,
        'GiftPay Wallet',
        'Fund wallets, withdraw to bank accounts, transfer to other GiftPay users, purchase utilities, and manage business transactions.',
      ),
      (
        Icons.api_rounded,
        'GiftPay API',
        'Connect applications to wallet debit and credit, airtime vending, data vending, electricity vending, and transaction lookup services.',
      ),
      (
        Icons.receipt_long_rounded,
        'Utilities',
        'Purchase airtime, data, electricity tokens, cable TV services, and supported internet subscriptions through the utilities platform.',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: 171,
      ),
      itemBuilder: (_, index) {
        final item = products[index];
        return _FeatureCard(
          icon: item.$1,
          title: item.$2,
          description: item.$3,
        );
      },
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(.035),
        border: Border.all(color: Colors.white.withOpacity(.065)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: const Color(0xFF4A6BB8).withOpacity(.12),
              border: Border.all(
                color: const Color(0xFF75A1FF).withOpacity(.14),
              ),
            ),
            child: Icon(icon, size: 21, color: const Color(0xFF75A1FF)),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 11.2,
              height: 1.45,
              color: Colors.white.withOpacity(.47),
            ),
          ),
        ],
      ),
    );
  }
}

class _OperationsGrid extends StatelessWidget {
  final bool isMobile;

  const _OperationsGrid({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    const items = [
      (
        Icons.credit_card_rounded,
        'Accept payments',
        'GiftPOS supports card and transfer payment acceptance for business transactions.',
      ),
      (
        Icons.bar_chart_rounded,
        'Track performance',
        'Review transaction history, daily sales summaries, and settlement reports.',
      ),
      (
        Icons.groups_rounded,
        'Manage teams',
        'Use staff accounts and multi-terminal support for distributed business operations.',
      ),
      (
        Icons.bolt_rounded,
        'Power utilities',
        'Purchase electricity tokens and other supported utility services for operational needs.',
      ),
      (
        Icons.swap_horiz_rounded,
        'Move funds',
        'Use supported GiftPay wallet capabilities for funding, withdrawals, and user transfers.',
      ),
      (
        Icons.integration_instructions_rounded,
        'Integrate systems',
        'Connect your application to available GiftPay REST API transaction services.',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 138,
      ),
      itemBuilder: (_, index) {
        final item = items[index];
        return _SmallFeature(
          icon: item.$1,
          title: item.$2,
          description: item.$3,
        );
      },
    );
  }
}

class _SmallFeature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _SmallFeature({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(.03),
        border: Border.all(color: Colors.white.withOpacity(.055)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF75A1FF)),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 10.5,
              height: 1.42,
              color: Colors.white.withOpacity(.42),
            ),
          ),
        ],
      ),
    );
  }
}

class _ApiPanel extends StatelessWidget {
  final bool isMobile;

  const _ApiPanel({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    const capabilities = [
      ('01', 'Wallet debit / credit'),
      ('02', 'Airtime vending'),
      ('03', 'Data vending'),
      ('04', 'Electricity vending'),
      ('05', 'Transaction lookup'),
    ];

    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF172743), Color(0xFF0E172A)],
        ),
        border: Border.all(color: Colors.white.withOpacity(.07)),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ApiCopy(),
                const SizedBox(height: 20),
                _ApiList(capabilities: capabilities),
              ],
            )
          : Row(
              children: [
                const Expanded(child: _ApiCopy()),
                const SizedBox(width: 35),
                SizedBox(
                  width: 365,
                  child: _ApiList(capabilities: capabilities),
                ),
              ],
            ),
    );
  }
}

class _ApiCopy extends StatelessWidget {
  const _ApiCopy();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white.withOpacity(.055),
            border: Border.all(color: Colors.white.withOpacity(.08)),
          ),
          child: const Text(
            'REST API',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: Color(0xFF75A1FF),
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Build Gift Technology services into your own workflow.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 20,
            height: 1.22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'GiftPay API is available through REST services, with JavaScript '
          '(Node.js) and Flutter/Dart SDK support. Python support is coming.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 12,
            height: 1.55,
            color: Colors.white.withOpacity(.50),
          ),
        ),
        const SizedBox(height: 13),
        Text(
          'Sandbox access is available through Supabase API keys.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 10.5,
            height: 1.45,
            color: Colors.white.withOpacity(.34),
          ),
        ),
      ],
    );
  }
}

class _ApiList extends StatelessWidget {
  final List<(String, String)> capabilities;

  const _ApiList({required this.capabilities});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: capabilities.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: Colors.white.withOpacity(.04),
              border: Border.all(color: Colors.white.withOpacity(.06)),
            ),
            child: Row(
              children: [
                Text(
                  item.$1,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withOpacity(.25),
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 16,
                  color: Color(0xFF75A1FF),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    item.$2,
                    style: const TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _BusinessTypesPanel extends StatelessWidget {
  final bool isMobile;

  const _BusinessTypesPanel({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    const audiences = [
      (
        Icons.storefront_rounded,
        'Retail businesses',
        'Payment acceptance, sales tracking, and utility purchasing.',
      ),
      (
        Icons.point_of_sale_rounded,
        'Merchants',
        'POS capabilities for card and transfer transactions.',
      ),
      (
        Icons.hub_rounded,
        'Distributors',
        'Digital vending and recurring utility transaction workflows.',
      ),
      (
        Icons.apartment_rounded,
        'Estates & property teams',
        'Electricity purchasing for operational and property requirements.',
      ),
    ];

    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withOpacity(.025),
        border: Border.all(color: Colors.white.withOpacity(.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'BUSINESS USE CASES',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.7,
              color: Color(0xFF75A1FF),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'A flexible ecosystem for different operating models.',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: audiences.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 1 : 2,
              crossAxisSpacing: 11,
              mainAxisSpacing: 11,
              mainAxisExtent: 113,
            ),
            itemBuilder: (_, index) {
              final item = audiences[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(17),
                  color: Colors.white.withOpacity(.03),
                  border: Border.all(color: Colors.white.withOpacity(.055)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 39,
                      height: 39,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(11),
                        color: const Color(0xFF4A6BB8).withOpacity(.11),
                      ),
                      child: Icon(
                        item.$1,
                        size: 19,
                        color: const Color(0xFF75A1FF),
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.$2,
                            style: const TextStyle(
                              fontFamily: 'SegoeUI',
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.$3,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'SegoeUI',
                              fontSize: 10,
                              height: 1.35,
                              color: Colors.white.withOpacity(.42),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SecurityPanel extends StatelessWidget {
  final bool isMobile;

  const _SecurityPanel({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 21 : 25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF4A6BB8).withOpacity(.16),
            const Color(0xFF17243E).withOpacity(.70),
          ],
        ),
        border: Border.all(color: const Color(0xFF75A1FF).withOpacity(.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(.06),
              border: Border.all(color: Colors.white.withOpacity(.09)),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Color(0xFF75A1FF),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SECURITY & ACCOUNT CONTROL',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: Color(0xFF75A1FF),
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Business transactions stay connected to the controls built into the Gift Technology ecosystem.',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'GiftPay Wallet supports KYC verification, security PIN, 2FA, '
                  'notifications, transaction history, and business dashboard '
                  'capabilities. Specific service controls depend on the applicable product.',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 10.8,
                    height: 1.5,
                    color: Colors.white.withOpacity(.45),
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
