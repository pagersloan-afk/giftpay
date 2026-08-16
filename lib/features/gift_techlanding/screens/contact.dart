import 'package:flutter/material.dart';

import 'gifttech_dedicated_page_template.dart';

class GiftTechContactScreen extends StatelessWidget {
  const GiftTechContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GiftTechDedicatedPageTemplate(
      title: 'Contact',
      eyebrow: 'LET’S CONNECT',
      icon: Icons.mail_outline_rounded,
      description:
          'Whether you need support, want to explore a partnership, or are interested in the Gift Technology ecosystem, we are building channels for meaningful conversations.',
      metaLabel: 'HEADQUARTERS',
      metaValue: 'Port Harcourt, Nigeria',
      secondaryMetaLabel: 'SUPPORT',
      secondaryMetaValue: 'support@gifttechnologyltd.com',
      child: const _ContactContent(),
    );
  }
}

class _ContactContent extends StatelessWidget {
  const _ContactContent();

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 720;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          if (mobile)
            const Column(
              children: [
                _ContactCard(
                  icon: Icons.support_agent_outlined,
                  eyebrow: 'CUSTOMER SUPPORT',
                  title: 'Need help?',
                  description:
                      'For product assistance, service issues, account questions, and support requests.',
                  value: 'support@gifttechnologyltd.com',
                ),
                SizedBox(height: 16),
                _ContactCard(
                  icon: Icons.handshake_outlined,
                  eyebrow: 'STRATEGIC PARTNERSHIPS',
                  title: 'Build with us.',
                  description:
                      'We are open to strategic partnerships that can strengthen the Gift Technology ecosystem.',
                  value: 'Partnership inquiries',
                ),
                SizedBox(height: 16),
                _ContactCard(
                  icon: Icons.trending_up_rounded,
                  eyebrow: 'INVESTOR INQUIRIES',
                  title: 'Explore the opportunity.',
                  description:
                      'Gift Technology Ltd is privately owned and does not currently offer a public investment or crowdfunding opportunity.',
                  value: 'investors@gifttechnologyltd.com',
                ),
                SizedBox(height: 16),
                _ContactCard(
                  icon: Icons.location_on_outlined,
                  eyebrow: 'OUR LOCATION',
                  title: 'Port Harcourt',
                  description:
                      'Our current physical presence is in Port Harcourt, Rivers State, Nigeria.',
                  value: '6th Ave. SARS Road, Rukpoku, Port Harcourt, Nigeria',
                ),
              ],
            )
          else
            const Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _ContactCard(
                        icon: Icons.support_agent_outlined,
                        eyebrow: 'CUSTOMER SUPPORT',
                        title: 'Need help?',
                        description:
                            'For product assistance, service issues, account questions, and support requests.',
                        value: 'support@gifttechnologyltd.com',
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _ContactCard(
                        icon: Icons.handshake_outlined,
                        eyebrow: 'STRATEGIC PARTNERSHIPS',
                        title: 'Build with us.',
                        description:
                            'We are open to strategic partnerships that can strengthen the Gift Technology ecosystem.',
                        value: 'Partnership inquiries',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _ContactCard(
                        icon: Icons.trending_up_rounded,
                        eyebrow: 'INVESTOR INQUIRIES',
                        title: 'Explore the opportunity.',
                        description:
                            'Gift Technology Ltd is privately owned and does not currently offer a public investment or crowdfunding opportunity.',
                        value: 'investors@gifttechnologyltd.com',
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _ContactCard(
                        icon: Icons.location_on_outlined,
                        eyebrow: 'OUR LOCATION',
                        title: 'Port Harcourt',
                        description:
                            'Our current physical presence is in Port Harcourt, Rivers State, Nigeria.',
                        value:
                            '6th Ave. SARS Road, Rukpoku, Port Harcourt, Nigeria',
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.value,
  });

  final IconData icon;
  final String eyebrow;
  final String title;
  final String description;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(27),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.white.withOpacity(0.035),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFF4A6BB8).withOpacity(0.13),
              border: Border.all(
                color: const Color(0xFF75A1FF).withOpacity(0.11),
              ),
            ),
            child: Icon(icon, color: const Color(0xFF75A1FF), size: 22),
          ),
          const SizedBox(height: 19),
          Text(
            eyebrow,
            style: const TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.7,
              color: Color(0xFF75A1FF),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 13,
              height: 1.65,
              color: Colors.white.withOpacity(0.49),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              color: const Color(0xFF4A6BB8).withOpacity(0.08),
              border: Border.all(
                color: const Color(0xFF75A1FF).withOpacity(0.08),
              ),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.67),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
