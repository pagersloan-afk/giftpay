import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class CareersScreen extends StatelessWidget {
  const CareersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GiftTechPageTemplate(
      title: 'Careers',
      description:
          'Build the technology that powers payments, utilities, digital services, and business operations across Africa.',
      eyebrow: 'GIFT TECHNOLOGY / CAREERS',
      icon: Icons.work_outline_rounded,
      metaLabel: 'CURRENT STATUS',
      metaValue: 'No open positions',
      secondaryMetaLabel: 'CV SUBMISSIONS',
      secondaryMetaValue: 'careers@gifttechnologyltd.com',
      child: const _CareersContent(),
    );
  }
}

class _CareersContent extends StatelessWidget {
  const _CareersContent();

  static const _roles = <_Role>[
    _Role(
      icon: Icons.code_rounded,
      title: 'Engineering',
      text:
          'Build secure, reliable technology across our payment, utility, wallet, and business platforms.',
    ),
    _Role(
      icon: Icons.design_services_outlined,
      title: 'Product Design',
      text:
          'Create clear, accessible, and thoughtful digital experiences for the people and businesses we serve.',
    ),
    _Role(
      icon: Icons.support_agent_rounded,
      title: 'Customer Support',
      text:
          'Help users and businesses get the most from Gift Technology products and services.',
    ),
    _Role(
      icon: Icons.trending_up_rounded,
      title: 'Business Development',
      text:
          'Build relationships and partnerships that expand the reach of our digital technology ecosystem.',
    ),
    _Role(
      icon: Icons.gpp_good_outlined,
      title: 'Compliance & Risk',
      text:
          'Help strengthen responsible operations, controls, and risk management across our platforms.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 760;
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
          _CareersHero(isMobile: isMobile),
          const SizedBox(height: 22),
          const _SectionHeading(
            eyebrow: 'CURRENT OPENINGS',
            title: 'We are not actively hiring right now.',
            description:
                'Gift Technology Ltd currently has no open positions. '
                'When opportunities become available, they will be announced through our official channels.',
          ),
          const SizedBox(height: 14),
          _StatusCard(isMobile: isMobile),
          const SizedBox(height: 22),
          const _SectionHeading(
            eyebrow: 'FUTURE OPPORTUNITIES',
            title: 'Areas we expect to grow.',
            description:
                'As Gift Technology expands its platforms and operations, future opportunities may include the following areas.',
          ),
          const SizedBox(height: 14),
          _RoleGrid(isMobile: isMobile),
          const SizedBox(height: 22),
          _ApplicationCard(isMobile: isMobile),
          const SizedBox(height: 22),
          _CulturePanel(isMobile: isMobile),
        ],
      ),
    );
  }
}

class _CareersHero extends StatelessWidget {
  final bool isMobile;

  const _CareersHero({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 23 : 32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF273D68), Color(0xFF172743), Color(0xFF0D1527)],
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
                const _HeroIcon(),
                const SizedBox(height: 20),
                const _HeroCopy(),
                const SizedBox(height: 18),
                _OpenStatus(),
              ],
            )
          : Row(
              children: [
                const _HeroIcon(),
                const SizedBox(width: 22),
                const Expanded(child: _HeroCopy()),
                const SizedBox(width: 25),
                _OpenStatus(),
              ],
            ),
    );
  }
}

class _HeroIcon extends StatelessWidget {
  const _HeroIcon();

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
        Icons.work_outline_rounded,
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
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GIFT TECHNOLOGY / CAREERS',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
            color: Color(0xFF75A1FF),
          ),
        ),
        SizedBox(height: 9),
        Text(
          'Build technology with purpose.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 25,
            height: 1.15,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Gift Technology builds secure digital platforms for payments, '
          'utilities, e-voting, entertainment, and business operations across Africa.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 13,
            height: 1.65,
            color: Color.fromRGBO(255, 255, 255, .62),
          ),
        ),
      ],
    );
  }
}

class _OpenStatus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 185),
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(.055),
        border: Border.all(color: Colors.white.withOpacity(.10)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HIRING STATUS',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: Color(0xFF75A1FF),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'No open positions',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'CVs are welcome for future consideration.',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 9.5,
              height: 1.35,
              color: Color.fromRGBO(255, 255, 255, .42),
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

class _StatusCard extends StatelessWidget {
  final bool isMobile;

  const _StatusCard({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 19 : 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withOpacity(.025),
        border: Border.all(color: Colors.white.withOpacity(.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4A6BB8).withOpacity(.13),
              border: Border.all(
                color: const Color(0xFF75A1FF).withOpacity(.14),
              ),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: Color(0xFF75A1FF),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No vacancies at this time',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'There are currently no open positions at Gift Technology Ltd. '
                  'This page will be updated when active opportunities become available.',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 11.2,
                    height: 1.5,
                    color: Color.fromRGBO(255, 255, 255, .45),
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

class _RoleGrid extends StatelessWidget {
  final bool isMobile;

  const _RoleGrid({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _CareersContent._roles.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : 2,
        crossAxisSpacing: 13,
        mainAxisSpacing: 13,
        mainAxisExtent: 142,
      ),
      itemBuilder: (_, index) {
        final role = _CareersContent._roles[index];

        return Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            color: Colors.white.withOpacity(.03),
            border: Border.all(color: Colors.white.withOpacity(.055)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFF4A6BB8).withOpacity(.11),
                ),
                child: Icon(
                  role.icon,
                  size: 20,
                  color: const Color(0xFF75A1FF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role.title,
                      style: const TextStyle(
                        fontFamily: 'SegoeUI',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      role.text,
                      style: TextStyle(
                        fontFamily: 'SegoeUI',
                        fontSize: 10.7,
                        height: 1.48,
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
}

class _ApplicationCard extends StatelessWidget {
  final bool isMobile;

  const _ApplicationCard({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 21 : 27),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF4A6BB8).withOpacity(.17),
            const Color(0xFF17243E).withOpacity(.72),
          ],
        ),
        border: Border.all(color: const Color(0xFF75A1FF).withOpacity(.12)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF273D68).withOpacity(.18),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: isMobile
          ? const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ApplicationCopy(),
                SizedBox(height: 18),
                _EmailButton(),
              ],
            )
          : const Row(
              children: [
                Expanded(child: _ApplicationCopy()),
                SizedBox(width: 28),
                _EmailButton(),
              ],
            ),
    );
  }
}

class _ApplicationCopy extends StatelessWidget {
  const _ApplicationCopy();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FUTURE CANDIDATES',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.7,
            color: Color(0xFF75A1FF),
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Want to be considered for a future opportunity?',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 19,
            height: 1.2,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Send your CV to our careers team. While there are no open positions '
          'currently, your profile can be considered when relevant opportunities arise.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 11.5,
            height: 1.55,
            color: Color.fromRGBO(255, 255, 255, .48),
          ),
        ),
      ],
    );
  }
}

class _EmailButton extends StatelessWidget {
  const _EmailButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        color: Colors.white.withOpacity(.07),
        border: Border.all(color: Colors.white.withOpacity(.11)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CAREERS EMAIL',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.3,
              color: Color(0xFF75A1FF),
            ),
          ),
          SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.mail_outline_rounded, size: 16, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'careers@gifttechnologyltd.com',
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CulturePanel extends StatelessWidget {
  final bool isMobile;

  const _CulturePanel({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('01', 'Technology', Icons.memory_rounded),
      ('02', 'Product', Icons.auto_awesome_rounded),
      ('03', 'People', Icons.people_outline_rounded),
      ('04', 'Responsibility', Icons.shield_outlined),
    ];

    return Container(
      padding: EdgeInsets.all(isMobile ? 19 : 23),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(23),
        color: Colors.white.withOpacity(.025),
        border: Border.all(color: Colors.white.withOpacity(.055)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'OUR WORK',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.7,
              color: Color(0xFF75A1FF),
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'The kind of work future teams will contribute to.',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: items.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  color: Colors.white.withOpacity(.035),
                  border: Border.all(color: Colors.white.withOpacity(.055)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.$3, size: 16, color: const Color(0xFF75A1FF)),
                    const SizedBox(width: 7),
                    Text(
                      '${item.$1}  ${item.$2}',
                      style: const TextStyle(
                        fontFamily: 'SegoeUI',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _Role {
  final IconData icon;
  final String title;
  final String text;

  const _Role({required this.icon, required this.title, required this.text});
}
