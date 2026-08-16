import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class GiftTechBulkElectricityScreen extends StatelessWidget {
  const GiftTechBulkElectricityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GiftTechPageTemplate(
      title: 'Bulk Electricity Tokens',
      description:
          'Reliable bulk electricity vending for businesses, estates, property managers, agents, distributors, and organisations managing recurring prepaid electricity needs.',
      eyebrow: 'GIFT TECHNOLOGY / UTILITIES',
      icon: Icons.bolt_rounded,
      metaLabel: 'SERVICE',
      metaValue: 'Bulk Electricity',
      secondaryMetaLabel: 'NETWORK COVERAGE',
      secondaryMetaValue:
          'PHED • AEDC • IKEDC • EEDC • KEDCO • JED • BEDC • IBEDC',
      child: const _BulkElectricityContent(),
    );
  }
}

class _BulkElectricityContent extends StatelessWidget {
  const _BulkElectricityContent();

  static const _blue = Color(0xFF4A6BB8);
  static const _lightBlue = Color(0xFF75A1FF);

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
            eyebrow: 'BUILT FOR HIGH-VOLUME UTILITY OPERATIONS',
            title: 'Electricity vending designed around recurring demand.',
            description:
                'Gift Technology provides electricity vending capabilities for organisations that need to purchase and distribute prepaid electricity at scale. The service is suited to operational teams, estates, agents, distributors, and businesses managing multiple electricity purchases.',
          ),
          const SizedBox(height: 14),
          _CapabilityGrid(isMobile: isMobile),
          const SizedBox(height: 22),
          _SectionHeading(
            eyebrow: 'SUPPORTED DISTRIBUTION NETWORKS',
            title: 'Coverage across major Nigerian electricity providers.',
            description:
                'Bulk electricity transactions can be supported across the electricity providers currently available through the Gift Technology utilities platform.',
          ),
          const SizedBox(height: 14),
          _DiscoGrid(isMobile: isMobile),
          const SizedBox(height: 22),
          _SectionHeading(
            eyebrow: 'OPERATIONAL FLOW',
            title: 'A straightforward digital vending workflow.',
            description:
                'The experience is designed to keep utility purchasing clear, traceable, and easy to manage from transaction initiation through token delivery and record keeping.',
          ),
          const SizedBox(height: 14),
          _FlowPanel(isMobile: isMobile),
          const SizedBox(height: 22),
          _BusinessPanel(isMobile: isMobile),
          const SizedBox(height: 22),
          _NoticePanel(),
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
              children: [_IconTile(), const SizedBox(height: 20), _HeroCopy()],
            )
          : Row(
              children: [
                _IconTile(),
                const SizedBox(width: 22),
                const Expanded(child: _HeroCopy()),
                const SizedBox(width: 20),
                _HeroBadge(),
              ],
            ),
    );
  }
}

class _IconTile extends StatelessWidget {
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
      child: const Icon(Icons.bolt_rounded, size: 35, color: Color(0xFF75A1FF)),
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
          'GIFT TECHNOLOGY / UTILITIES',
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
          'Power utility distribution at scale.',
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
          'Bulk electricity token vending gives businesses and distribution '
          'operators a digital way to manage recurring prepaid electricity '
          'purchases through Gift Technology.',
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
            'UTILITY SERVICE',
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
            'Electricity Tokens',
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

class _CapabilityGrid extends StatelessWidget {
  final bool isMobile;

  const _CapabilityGrid({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        Icons.receipt_long_rounded,
        'Digital vending',
        'Purchase prepaid electricity tokens through the digital utilities platform.',
      ),
      (
        Icons.business_center_rounded,
        'Business operations',
        'Designed for organisations managing recurring electricity requirements.',
      ),
      (
        Icons.groups_rounded,
        'Distribution use',
        'Suitable for agents, distributors, estates, and property operations.',
      ),
      (
        Icons.history_rounded,
        'Transaction records',
        'Keep utility purchases visible through transaction history and records.',
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
      itemBuilder: (_, index) {
        final item = items[index];
        return _CapabilityCard(
          icon: item.$1,
          title: item.$2,
          description: item.$3,
        );
      },
    );
  }
}

class _CapabilityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _CapabilityCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(.035),
        border: Border.all(color: Colors.white.withOpacity(.065)),
      ),
      child: Row(
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
            child: Icon(icon, color: const Color(0xFF75A1FF), size: 21),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 11.5,
                    height: 1.48,
                    color: Colors.white.withOpacity(.47),
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

class _DiscoGrid extends StatelessWidget {
  final bool isMobile;

  const _DiscoGrid({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    const providers = [
      ('PHED', 'Port Harcourt Electricity Distribution'),
      ('AEDC', 'Abuja Electricity Distribution'),
      ('IKEDC', 'Ikeja Electricity Distribution'),
      ('EEDC', 'Enugu Electricity Distribution'),
      ('KEDCO', 'Kano Electricity Distribution'),
      ('JED', 'Jos Electricity Distribution'),
      ('BEDC', 'Benin Electricity Distribution'),
      ('IBEDC', 'Ibadan Electricity Distribution'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: providers.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 2 : 4,
        crossAxisSpacing: 11,
        mainAxisSpacing: 11,
        mainAxisExtent: 92,
      ),
      itemBuilder: (_, index) {
        final provider = providers[index];
        return Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            color: Colors.white.withOpacity(.032),
            border: Border.all(color: Colors.white.withOpacity(.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                provider.$1,
                style: const TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                provider.$2,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 9.5,
                  height: 1.3,
                  color: Colors.white.withOpacity(.40),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FlowPanel extends StatelessWidget {
  final bool isMobile;

  const _FlowPanel({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    const steps = [
      (
        '01',
        Icons.assignment_rounded,
        'Select utility',
        'Choose the supported electricity provider and enter the required meter details.',
      ),
      (
        '02',
        Icons.payments_rounded,
        'Submit payment',
        'Complete the transaction through the available payment flow.',
      ),
      (
        '03',
        Icons.bolt_rounded,
        'Token generated',
        'When the transaction succeeds, the electricity token is generated.',
      ),
      (
        '04',
        Icons.receipt_long_rounded,
        'Keep the record',
        'Transaction information remains available for operational reference.',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(.045),
            Colors.white.withOpacity(.015),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(.07)),
      ),
      child: isMobile
          ? Column(
              children: [
                for (var i = 0; i < steps.length; i++) ...[
                  _FlowStep(
                    number: steps[i].$1,
                    icon: steps[i].$2,
                    title: steps[i].$3,
                    description: steps[i].$4,
                  ),
                  if (i != steps.length - 1)
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Container(
                        width: 1,
                        height: 18,
                        color: Colors.white.withOpacity(.08),
                      ),
                    ),
                ],
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < steps.length; i++) ...[
                  Expanded(
                    child: _FlowStep(
                      number: steps[i].$1,
                      icon: steps[i].$2,
                      title: steps[i].$3,
                      description: steps[i].$4,
                    ),
                  ),
                  if (i != steps.length - 1)
                    Padding(
                      padding: const EdgeInsets.only(top: 21),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: Colors.white.withOpacity(.14),
                      ),
                    ),
                ],
              ],
            ),
    );
  }
}

class _FlowStep extends StatelessWidget {
  final String number;
  final IconData icon;
  final String title;
  final String description;

  const _FlowStep({
    required this.number,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4A6BB8).withOpacity(.13),
                  border: Border.all(
                    color: const Color(0xFF75A1FF).withOpacity(.13),
                  ),
                ),
                child: Icon(icon, size: 17, color: const Color(0xFF75A1FF)),
              ),
              const SizedBox(width: 9),
              Text(
                number,
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.3,
                  color: Colors.white.withOpacity(.27),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 10.7,
              height: 1.42,
              color: Colors.white.withOpacity(.43),
            ),
          ),
        ],
      ),
    );
  }
}

class _BusinessPanel extends StatelessWidget {
  final bool isMobile;

  const _BusinessPanel({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final benefits = [
      ('BUSINESSES', Icons.business_center_rounded),
      ('ESTATES', Icons.location_city_rounded),
      ('DISTRIBUTORS', Icons.hub_rounded),
      ('PROPERTY OPERATORS', Icons.domain_rounded),
    ];

    return Container(
      padding: EdgeInsets.all(isMobile ? 21 : 25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1D3157), Color(0xFF101A2E)],
        ),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _businessCopy(),
                const SizedBox(height: 18),
                _audienceGrid(benefits),
              ],
            )
          : Row(
              children: [
                Expanded(child: _businessCopy()),
                const SizedBox(width: 30),
                SizedBox(width: 360, child: _audienceGrid(benefits)),
              ],
            ),
    );
  }

  Widget _businessCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DESIGNED FOR OPERATIONS',
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
          'Built for organisations with more than one meter, customer, or transaction.',
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
          'Use the electricity vending capability as part of a broader digital '
          'utility workflow for recurring purchases and distribution operations.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 12,
            height: 1.55,
            color: Colors.white.withOpacity(.50),
          ),
        ),
      ],
    );
  }

  Widget _audienceGrid(List<(String, IconData)> items) {
    return Wrap(
      spacing: 9,
      runSpacing: 9,
      children: items.map((item) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            color: Colors.white.withOpacity(.045),
            border: Border.all(color: Colors.white.withOpacity(.07)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.$2, size: 15, color: const Color(0xFF75A1FF)),
              const SizedBox(width: 7),
              Text(
                item.$1,
                style: const TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .4,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _NoticePanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xFF4A6BB8).withOpacity(.07),
        border: Border.all(color: const Color(0xFF75A1FF).withOpacity(.11)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 19,
            color: Color(0xFF75A1FF),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              'Electricity services and provider availability are subject to '
              'the current utilities configuration. Transaction and token '
              'delivery status should be confirmed through the applicable '
              'Gift Technology service flow.',
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: 10.8,
                height: 1.5,
                color: Colors.white.withOpacity(.45),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
