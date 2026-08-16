import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class CreatorsScreen extends StatelessWidget {
  const CreatorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GiftTechPageTemplate(
      title: 'Creators',
      description:
          'Digital infrastructure for creators, independent businesses, and emerging digital entrepreneurs building and operating across Africa.',
      eyebrow: 'CREATOR ECOSYSTEM',
      icon: Icons.auto_awesome_outlined,
      metaLabel: 'ECOSYSTEM',
      metaValue: 'Creators & Digital Businesses',
      secondaryMetaLabel: 'PLATFORM',
      secondaryMetaValue: 'Gift Technology',
      child: const _CreatorsContent(),
    );
  }
}

class _CreatorsContent extends StatelessWidget {
  const _CreatorsContent();

  static const Color primaryBlue = Color(0xFF4A6BB8);
  static const Color lightBlue = Color(0xFF75A1FF);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 720;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _heroCard(isMobile),
          const SizedBox(height: 20),
          _sectionHeading(
            eyebrow: 'BUILD WITH DIGITAL INFRASTRUCTURE',
            title: 'Tools that help digital businesses move.',
            description:
                'Gift Technology builds secure digital platforms that support payments, utilities, wallets, business operations, and API-powered services — giving creators and digital entrepreneurs infrastructure they can build around.',
          ),
          const SizedBox(height: 14),
          _capabilityGrid(isMobile),
          const SizedBox(height: 20),
          _giftPayCard(),
          const SizedBox(height: 20),
          _apiCard(),
          const SizedBox(height: 20),
          _businessCard(isMobile),
          const SizedBox(height: 20),
          _communityCard(),
          const SizedBox(height: 20),
          _contactCard(),
        ],
      ),
    );
  }

  Widget _heroCard(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 22 : 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryBlue.withOpacity(.45),
            const Color(0xFF0A1427).withOpacity(.94),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(.09)),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(.13),
            blurRadius: 48,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: lightBlue.withOpacity(.10),
              border: Border.all(color: lightBlue.withOpacity(.14)),
            ),
            child: const Icon(
              Icons.auto_awesome_outlined,
              color: lightBlue,
              size: 26,
            ),
          ),
          const SizedBox(width: 17),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Build. Create. Operate.',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Gift Technology provides digital infrastructure for people and businesses building the next generation of services across Africa.',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 12,
                    height: 1.6,
                    color: Color.fromRGBO(255, 255, 255, .52),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeading({
    required String eyebrow,
    required String title,
    required String description,
  }) {
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
            color: lightBlue,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          description,
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 12,
            height: 1.58,
            color: Colors.white.withOpacity(.45),
          ),
        ),
      ],
    );
  }

  Widget _capabilityGrid(bool isMobile) {
    final items = [
      (
        Icons.account_balance_wallet_outlined,
        'Digital Payments',
        'Payment and wallet infrastructure for digital businesses and their customers.',
      ),
      (
        Icons.api_outlined,
        'API Services',
        'GiftPay API capabilities for integrating wallet and utility services into applications.',
      ),
      (
        Icons.bolt_outlined,
        'Digital Utilities',
        'Airtime, data, electricity, cable TV, and internet services through one ecosystem.',
      ),
      (
        Icons.storefront_outlined,
        'Business Tools',
        'Digital services designed to support merchants, businesses, agents, and operational teams.',
      ),
      (
        Icons.receipt_long_outlined,
        'Transaction Infrastructure',
        'Transaction history and operational visibility across supported Gift Technology services.',
      ),
      (
        Icons.security_outlined,
        'Secure Platforms',
        'Security-focused digital infrastructure designed for payments and business operations.',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: 145,
      ),
      itemBuilder: (context, index) {
        final item = items[index];

        return _GlassCard(icon: item.$1, title: item.$2, description: item.$3);
      },
    );
  }

  Widget _giftPayCard() {
    return _FeaturePanel(
      icon: Icons.account_balance_wallet_outlined,
      eyebrow: 'GIFT PAY',
      title: 'A foundation for digital transactions.',
      description:
          'GiftPay provides wallet functionality including funding, withdrawals, transfers, airtime, data, electricity payments, transaction history, KYC verification, security PINs, 2FA, notifications, and business capabilities.',
    );
  }

  Widget _apiCard() {
    return _FeaturePanel(
      icon: Icons.integration_instructions_outlined,
      eyebrow: 'GIFT PAY API',
      title: 'Build services on top of real digital infrastructure.',
      description:
          'The GiftPay API provides REST capabilities for wallet debit and credit, airtime vending, data vending, electricity vending, and transaction lookup. JavaScript/Node.js and Flutter/Dart SDKs are available, with Python listed as coming soon.',
    );
  }

  Widget _businessCard(bool isMobile) {
    final items = [
      'Business dashboard capabilities',
      'Digital payments and transfers',
      'Airtime and data vending',
      'Electricity and utility services',
      'Transaction history',
      'Merchant and operational tools',
    ];

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: const Color(0xFF0D172B).withOpacity(.70),
        border: Border.all(color: Colors.white.withOpacity(.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FOR DIGITAL ENTREPRENEURS',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
              color: lightBlue,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Turn digital ideas into operating businesses.',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Creators and entrepreneurs can build around a growing ecosystem of payment, wallet, utility, and business capabilities.',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 11.2,
              height: 1.55,
              color: Colors.white.withOpacity(.43),
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: items.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.white.withOpacity(.035),
                  border: Border.all(color: Colors.white.withOpacity(.06)),
                ),
                child: Text(
                  item,
                  style: const TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _communityCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF273D68).withOpacity(.28),
            const Color(0xFF0A1427).withOpacity(.82),
          ],
        ),
        border: Border.all(color: lightBlue.withOpacity(.09)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.groups_outlined, color: lightBlue, size: 25),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'COMMUNITY & ECOSYSTEM',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: lightBlue,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Creators are part of Africa’s digital future.',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Gift Technology is building an ecosystem where digital platforms, businesses, developers, and emerging entrepreneurs can connect with the infrastructure they need to operate.',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 11,
                    height: 1.55,
                    color: Color.fromRGBO(255, 255, 255, .43),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withOpacity(.025),
        border: Border.all(color: Colors.white.withOpacity(.055)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.mail_outline_rounded, color: lightBlue, size: 23),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CREATOR & BUSINESS ENQUIRIES',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: lightBlue,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Connect with Gift Technology',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'support@gifttechnologyltd.com',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '+234 901 085 3849  •  Port Harcourt, Rivers, Nigeria',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 10.5,
                    color: Color.fromRGBO(255, 255, 255, .40),
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

class _GlassCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _GlassCard({
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
        color: const Color(0xFF0D172B).withOpacity(.64),
        border: Border.all(color: Colors.white.withOpacity(.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.12),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: const Color(0xFF4A6BB8).withOpacity(.11),
              border: Border.all(
                color: const Color(0xFF75A1FF).withOpacity(.10),
              ),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF75A1FF)),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 10.7,
                    height: 1.5,
                    color: Colors.white.withOpacity(.43),
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

class _FeaturePanel extends StatelessWidget {
  final IconData icon;
  final String eyebrow;
  final String title;
  final String description;

  const _FeaturePanel({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF172A48).withOpacity(.56),
            const Color(0xFF0A1427).withOpacity(.82),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(.065)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: const Color(0xFF4A6BB8).withOpacity(.12),
            ),
            child: Icon(icon, color: const Color(0xFF75A1FF), size: 23),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow,
                  style: const TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: Color(0xFF75A1FF),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 11.1,
                    height: 1.57,
                    color: Colors.white.withOpacity(.43),
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
