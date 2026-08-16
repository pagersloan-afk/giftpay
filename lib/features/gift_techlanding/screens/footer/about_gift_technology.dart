import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

/// Production-ready About Gift Technology page.
///
/// Content is based on the company profile supplied for the Gift Technology
/// website. No unsupported leadership names, founding dates, awards, customer
/// counts, funding figures, or regulatory claims are introduced.
class AboutGiftTechScreen extends StatelessWidget {
  const AboutGiftTechScreen({super.key});

  static const Color _navy = Color(0xFF273D68);
  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _lightBlue = Color(0xFF5D8FFF);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 760;

    return GiftTechPageTemplate(
      title: 'About Gift Technology Ltd',
      description:
          'Learn about our mission, leadership, history, and vision for Africa’s digital future.',
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          isMobile ? 16 : 28,
          8,
          isMobile ? 16 : 28,
          36,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHero(isMobile),
            const SizedBox(height: 22),
            _buildCompanyStory(isMobile),
            const SizedBox(height: 22),
            _buildPlatformGrid(isMobile),
            const SizedBox(height: 22),
            _buildVisionPanel(isMobile),
            const SizedBox(height: 22),
            _buildCompanyIdentity(isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 24 : 34),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_navy, _blue.withOpacity(.78), const Color(0xFF101C32)],
        ),
        border: Border.all(color: Colors.white.withOpacity(.13)),
        boxShadow: [
          BoxShadow(
            color: _blue.withOpacity(.20),
            blurRadius: 48,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroMark(),
                const SizedBox(height: 22),
                _buildHeroCopy(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildHeroMark(),
                const SizedBox(width: 24),
                Expanded(child: _buildHeroCopy()),
                const SizedBox(width: 28),
                _buildAfricaBadge(),
              ],
            ),
    );
  }

  Widget _buildHeroMark() {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(.085),
        border: Border.all(color: Colors.white.withOpacity(.15)),
        boxShadow: [
          BoxShadow(
            color: _lightBlue.withOpacity(.24),
            blurRadius: 32,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(Icons.public_outlined, color: Colors.white, size: 34),
    );
  }

  Widget _buildHeroCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GIFT TECHNOLOGY LTD / OUR STORY',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: Colors.white.withOpacity(.68),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Technology with purpose.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 32,
            height: 1.06,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 11),
        Text(
          'Building secure digital platforms for payments, utilities, '
          'e-voting, entertainment, and business operations across Africa.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 14,
            height: 1.6,
            color: Colors.white.withOpacity(.70),
          ),
        ),
      ],
    );
  }

  Widget _buildAfricaBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white.withOpacity(.075),
        border: Border.all(color: Colors.white.withOpacity(.13)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on_outlined, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            'PORT HARCOURT / NIGERIA',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.15,
              color: Colors.white.withOpacity(.70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyStory(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 30),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.045),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withOpacity(.085)),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel('WHO WE ARE'),
                const SizedBox(height: 10),
                _storyText(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 190, child: _sectionLabel('WHO WE ARE')),
                const SizedBox(width: 24),
                Expanded(child: _storyText()),
              ],
            ),
    );
  }

  Widget _storyText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gift Technology Ltd is a Nigerian multinational technology company '
          'headquartered in Port Harcourt, Rivers, Nigeria.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 20,
            height: 1.35,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 13),
        Text(
          'We build secure digital platforms that power payments, utilities, '
          'e-voting, entertainment, and business operations across Africa.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 14,
            height: 1.65,
            color: Colors.white.withOpacity(.58),
          ),
        ),
      ],
    );
  }

  Widget _buildPlatformGrid(bool isMobile) {
    const platforms = [
      _PlatformItem(
        Icons.account_balance_wallet_outlined,
        'Payments',
        'Digital experiences designed to support modern payment needs.',
      ),
      _PlatformItem(
        Icons.bolt_outlined,
        'Utilities',
        'Digital access to everyday utility services and experiences.',
      ),
      _PlatformItem(
        Icons.how_to_vote_outlined,
        'E-Voting',
        'Technology supporting secure and structured digital voting experiences.',
      ),
      _PlatformItem(
        Icons.play_circle_outline_rounded,
        'Entertainment',
        'Digital platforms connecting people with entertainment experiences.',
      ),
      _PlatformItem(
        Icons.business_center_outlined,
        'Business Operations',
        'Technology designed to help businesses operate and serve customers digitally.',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('WHAT WE BUILD'),
        const SizedBox(height: 13),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: platforms.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 1 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: isMobile ? 142 : 150,
          ),
          itemBuilder: (_, index) => _PlatformCard(item: platforms[index]),
        ),
      ],
    );
  }

  Widget _buildVisionPanel(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 23 : 31),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _blue.withOpacity(.17),
            _navy.withOpacity(.30),
            Colors.white.withOpacity(.035),
          ],
        ),
        border: Border.all(color: _blue.withOpacity(.20)),
        boxShadow: [
          BoxShadow(
            color: _blue.withOpacity(.09),
            blurRadius: 34,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildVisionIcon(),
                const SizedBox(height: 20),
                _buildVisionCopy(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildVisionIcon(),
                const SizedBox(width: 20),
                Expanded(child: _buildVisionCopy()),
              ],
            ),
    );
  }

  Widget _buildVisionIcon() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(.07),
        border: Border.all(color: Colors.white.withOpacity(.12)),
      ),
      child: const Icon(
        Icons.auto_awesome_outlined,
        color: _lightBlue,
        size: 26,
      ),
    );
  }

  Widget _buildVisionCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'OUR VISION',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
            color: _lightBlue.withOpacity(.95),
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'A stronger digital future for Africa.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Our work is focused on building secure digital platforms that '
          'make essential technology experiences more accessible, connected, '
          'and useful across Africa.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 13.5,
            height: 1.6,
            color: Colors.white.withOpacity(.58),
          ),
        ),
      ],
    );
  }

  Widget _buildCompanyIdentity(bool isMobile) {
    final contacts = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _contactRow(
          Icons.location_on_outlined,
          'Plot 12, 6th Avenue, Rumuaghaolu Road, SARS Rd, '
          'Port Harcourt 500101, Rivers, Nigeria',
        ),
        const SizedBox(height: 13),
        _contactRow(Icons.phone_outlined, '+234 901 085 3849'),
        const SizedBox(height: 13),
        _contactRow(
          Icons.mail_outline_rounded,
          'support@gifttechnologyltd.com',
        ),
        const SizedBox(height: 13),
        _contactRow(Icons.language_outlined, 'www.gifttechnologyltd.com'),
      ],
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: Colors.white.withOpacity(.035),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_companyTitle(), const SizedBox(height: 20), contacts],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _companyTitle()),
                const SizedBox(width: 30),
                SizedBox(width: 350, child: contacts),
              ],
            ),
    );
  }

  Widget _companyTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GIFT TECHNOLOGY LTD',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
            color: _lightBlue.withOpacity(.95),
          ),
        ),
        const SizedBox(height: 9),
        const Text(
          'Built in Nigeria. Designed for Africa.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Port Harcourt, Rivers, Nigeria',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 13,
            color: Colors.white.withOpacity(.48),
          ),
        ),
      ],
    );
  }

  Widget _contactRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: _lightBlue),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 12.5,
              height: 1.45,
              color: Colors.white.withOpacity(.58),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'SegoeUI',
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.8,
        color: _lightBlue.withOpacity(.95),
      ),
    );
  }
}

class _PlatformItem {
  final IconData icon;
  final String title;
  final String description;

  const _PlatformItem(this.icon, this.title, this.description);
}

class _PlatformCard extends StatefulWidget {
  final _PlatformItem item;

  const _PlatformCard({required this.item});

  @override
  State<_PlatformCard> createState() => _PlatformCardState();
}

class _PlatformCardState extends State<_PlatformCard> {
  bool _hovered = false;

  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _lightBlue = Color(0xFF5D8FFF);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(_hovered ? .085 : .06),
              Colors.white.withOpacity(.025),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(_hovered ? .15 : .085),
          ),
          boxShadow: [
            BoxShadow(
              color: _blue.withOpacity(_hovered ? .14 : .05),
              blurRadius: _hovered ? 30 : 20,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: _blue.withOpacity(.10),
                border: Border.all(color: _blue.withOpacity(.17)),
              ),
              child: Icon(widget.item.icon, size: 21, color: _lightBlue),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.title,
                    style: const TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    widget.item.description,
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 12.5,
                      height: 1.5,
                      color: Colors.white.withOpacity(.52),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
