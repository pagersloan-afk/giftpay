import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class CorporateDataScreen extends StatelessWidget {
  const CorporateDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GiftTechPageTemplate(
      title: 'Corporate Data Plans',
      description:
          'Reliable and scalable data services for businesses, teams, agents, and enterprise operations across Africa.',
      eyebrow: 'BUSINESS CONNECTIVITY',
      icon: Icons.business_center_outlined,
      metaLabel: 'SERVICE',
      metaValue: 'Corporate Data',
      secondaryMetaLabel: 'BUILT FOR',
      secondaryMetaValue: 'Businesses & Teams',
      child: const _CorporateDataContent(),
    );
  }
}

class _CorporateDataContent extends StatelessWidget {
  const _CorporateDataContent();

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
            eyebrow: 'CORPORATE CONNECTIVITY',
            title: 'Data infrastructure built around your operation.',
            description:
                'Gift Technology provides digital data services designed to support businesses, teams, agents, and organisations that depend on reliable connectivity.',
          ),
          const SizedBox(height: 14),
          _featureGrid(isMobile),
          const SizedBox(height: 20),
          _networkCard(),
          const SizedBox(height: 20),
          _businessUseCases(isMobile),
          const SizedBox(height: 20),
          _platformCard(),
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
            const Color(0xFF273D68).withOpacity(.55),
            const Color(0xFF0B1427).withOpacity(.92),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(.09)),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(.12),
            blurRadius: 45,
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
            child: const Icon(Icons.wifi_rounded, color: lightBlue, size: 26),
          ),
          const SizedBox(width: 17),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Connected businesses move faster.',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Corporate data services from Gift Technology help keep teams and business operations connected through convenient digital data vending.',
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

  Widget _featureGrid(bool isMobile) {
    final features = [
      (
        Icons.groups_outlined,
        'Team Connectivity',
        'Support connectivity needs across employees, teams, and distributed business operations.',
      ),
      (
        Icons.account_balance_outlined,
        'Business Operations',
        'Integrate data services into the wider digital operations of your organisation.',
      ),
      (
        Icons.speed_outlined,
        'Digital Delivery',
        'Use Gift Technology digital services to purchase and deliver data conveniently.',
      ),
      (
        Icons.layers_outlined,
        'Scalable Services',
        'Designed to support growing businesses and different operational requirements.',
      ),
      (
        Icons.receipt_long_outlined,
        'Transaction Visibility',
        'Keep business transactions organised through the wider Gift Technology platform.',
      ),
      (
        Icons.hub_outlined,
        'Platform Integration',
        'Connect data vending with other Gift Technology business and utility capabilities.',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: features.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: 145,
      ),
      itemBuilder: (context, index) {
        final item = features[index];

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xFF0D172B).withOpacity(.65),
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
              _iconTile(item.$1),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.$2,
                      style: const TextStyle(
                        fontFamily: 'SegoeUI',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      item.$3,
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
      },
    );
  }

  Widget _networkCard() {
    final providers = ['MTN', 'Airtel', 'Glo', '9mobile'];

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF172A48).withOpacity(.62),
            const Color(0xFF0A1427).withOpacity(.80),
          ],
        ),
        border: Border.all(color: lightBlue.withOpacity(.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SUPPORTED MOBILE NETWORKS',
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
            'Major Nigerian networks, through one digital platform.',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Gift Technology currently supports data services across the major Nigerian mobile networks listed below.',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 11.2,
              height: 1.55,
              color: Colors.white.withOpacity(.43),
            ),
          ),
          const SizedBox(height: 17),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: providers.map((provider) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.white.withOpacity(.045),
                  border: Border.all(color: Colors.white.withOpacity(.07)),
                ),
                child: Text(
                  provider,
                  style: const TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _businessUseCases(bool isMobile) {
    final cases = [
      (
        Icons.business_outlined,
        'Corporate teams',
        'Keep employees connected with convenient access to mobile data services.',
      ),
      (
        Icons.storefront_outlined,
        'Agents & resellers',
        'Support digital vending operations through Gift Technology services.',
      ),
      (
        Icons.account_tree_outlined,
        'Enterprise operations',
        'Bring data services into broader business and digital workflows.',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeading(
          eyebrow: 'BUILT FOR BUSINESS',
          title: 'One platform. Multiple business needs.',
          description:
              'Whether connectivity is needed by employees, customers, agents, or internal operations, Gift Technology provides a digital foundation for business data services.',
        ),
        const SizedBox(height: 14),
        if (isMobile)
          Column(
            children: cases
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _useCaseCard(item),
                  ),
                )
                .toList(),
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: cases
                .map(
                  (item) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: _useCaseCard(item),
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _useCaseCard((IconData, String, String) item) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        color: Colors.white.withOpacity(.025),
        border: Border.all(color: Colors.white.withOpacity(.055)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _iconTile(item.$1),
          const SizedBox(height: 14),
          Text(
            item.$2,
            style: const TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.$3,
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 10.6,
              height: 1.5,
              color: Colors.white.withOpacity(.42),
            ),
          ),
        ],
      ),
    );
  }

  Widget _platformCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: const Color(0xFF0D172B).withOpacity(.70),
        border: Border.all(color: Colors.white.withOpacity(.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _iconTile(Icons.api_outlined),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Part of a broader digital ecosystem',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Corporate data services sit alongside Gift Technology capabilities for airtime, electricity, wallet services, payments, GiftPOS, and API-based digital operations.',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 11,
                    height: 1.58,
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

  Widget _contactCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryBlue.withOpacity(.25),
            const Color(0xFF0A1427).withOpacity(.82),
          ],
        ),
        border: Border.all(color: lightBlue.withOpacity(.09)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.support_agent_outlined, color: lightBlue, size: 24),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NEED BUSINESS SUPPORT?',
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
                  'Talk to Gift Technology',
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

  Widget _iconTile(IconData icon) {
    return Container(
      width: 43,
      height: 43,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        color: primaryBlue.withOpacity(.11),
        border: Border.all(color: lightBlue.withOpacity(.10)),
      ),
      child: Icon(icon, size: 20, color: lightBlue),
    );
  }
}
