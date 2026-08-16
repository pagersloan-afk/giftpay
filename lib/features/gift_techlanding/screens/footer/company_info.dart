import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class CompanyInfoScreen extends StatelessWidget {
  const CompanyInfoScreen({super.key});

  static const Color _navy = Color(0xFF273D68);
  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _lightBlue = Color(0xFF7EA4FF);

  @override
  Widget build(BuildContext context) {
    return GiftTechPageTemplate(
      eyebrow: 'GIFT TECHNOLOGY / COMPANY',
      title: 'Company\nInformation',
      description:
          'Corporate information, registration details, and the operating profile of Gift Technology Ltd.',
      icon: Icons.business_outlined,
      metaLabel: 'COMPANY',
      metaValue: 'Gift Technology Ltd',
      secondaryMetaLabel: 'HEADQUARTERS',
      secondaryMetaValue: 'Port Harcourt, Nigeria',
      child: const _CompanyInformationContent(),
    );
  }
}

class _CompanyInformationContent extends StatelessWidget {
  const _CompanyInformationContent();

  static const Color _navy = Color(0xFF273D68);
  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _lightBlue = Color(0xFF7EA4FF);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 760;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _profileHero(isMobile),
          const SizedBox(height: 18),
          _sectionLabel('CORPORATE DETAILS'),
          const SizedBox(height: 12),
          _detailsGrid(isMobile),
          const SizedBox(height: 18),
          _missionSection(isMobile),
          const SizedBox(height: 18),
          _operatingProfile(isMobile),
          const SizedBox(height: 18),
          _contactSection(isMobile),
        ],
      ),
    );
  }

  Widget _profileHero(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF273D68), Color(0xFF355792), Color(0xFF101A2D)],
        ),
        border: Border.all(color: Colors.white.withOpacity(.11)),
        boxShadow: [
          BoxShadow(
            color: _blue.withOpacity(.16),
            blurRadius: 34,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _companyMark(),
                const SizedBox(height: 18),
                _profileCopy(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _companyMark(),
                const SizedBox(width: 20),
                Expanded(child: _profileCopy()),
                const SizedBox(width: 20),
                _privateBadge(),
              ],
            ),
    );
  }

  Widget _companyMark() {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(.075),
        border: Border.all(color: Colors.white.withOpacity(.14)),
        boxShadow: [
          BoxShadow(color: _lightBlue.withOpacity(.18), blurRadius: 30),
        ],
      ),
      child: const Icon(
        Icons.account_balance_outlined,
        color: Colors.white,
        size: 31,
      ),
    );
  }

  Widget _profileCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GIFT TECHNOLOGY LTD',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: Colors.white.withOpacity(.62),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Building secure digital infrastructure for Africa.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 21,
            height: 1.18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -.3,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          'Gift Technology Ltd is a Nigerian multinational technology company '
          'headquartered in Port Harcourt, Rivers, Nigeria. We build secure '
          'digital platforms that power payments, utilities, e-voting, '
          'entertainment, and business operations across Africa.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 12.8,
            height: 1.6,
            color: Colors.white.withOpacity(.60),
          ),
        ),
      ],
    );
  }

  Widget _privateBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white.withOpacity(.07),
        border: Border.all(color: Colors.white.withOpacity(.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified_outlined, size: 15, color: _lightBlue),
          const SizedBox(width: 7),
          Text(
            'PRIVATELY OWNED',
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

  Widget _detailsGrid(bool isMobile) {
    const details = [
      _CompanyDetail(
        Icons.badge_outlined,
        'Registration number',
        '9607125',
        'Corporate registration',
      ),
      _CompanyDetail(
        Icons.receipt_long_outlined,
        'Tax identification number',
        '262xxxxxxx396',
        'TIN',
      ),
      _CompanyDetail(
        Icons.location_on_outlined,
        'Headquarters',
        'Port Harcourt, Rivers, Nigeria',
        'Principal location',
      ),
      _CompanyDetail(
        Icons.phone_outlined,
        'Phone',
        '+234 901 085 3849',
        'Corporate contact',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: details.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: isMobile ? 108 : 116,
      ),
      itemBuilder: (_, index) => _DetailCard(detail: details[index]),
    );
  }

  Widget _missionSection(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withOpacity(.035),
        border: Border.all(color: Colors.white.withOpacity(.075)),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _roundIcon(Icons.public_outlined),
                const SizedBox(height: 16),
                _missionCopy(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _roundIcon(Icons.public_outlined),
                const SizedBox(width: 18),
                Expanded(child: _missionCopy()),
              ],
            ),
    );
  }

  Widget _missionCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('OUR PROFILE'),
        const SizedBox(height: 8),
        const Text(
          'Technology built for real-world African needs.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          'Gift Technology develops secure digital platforms across payments, '
          'utilities, e-voting, entertainment, and business operations. '
          'Our products are designed to connect everyday digital services '
          'with dependable technology infrastructure.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 12.8,
            height: 1.6,
            color: Colors.white.withOpacity(.52),
          ),
        ),
      ],
    );
  }

  Widget _operatingProfile(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_blue.withOpacity(.10), Colors.white.withOpacity(.028)],
        ),
        border: Border.all(color: _lightBlue.withOpacity(.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('OPERATING PROFILE'),
          const SizedBox(height: 8),
          const Text(
            'A digital-first technology company.',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gift Technology is privately owned and does not currently make '
            'a public investment offering or crowdfunding offering. The company '
            'is open to strategic partnerships.',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 12.8,
              height: 1.6,
              color: Colors.white.withOpacity(.52),
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: const [
              _Pill('Payments'),
              _Pill('Utilities'),
              _Pill('E-voting'),
              _Pill('Entertainment'),
              _Pill('Business operations'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _contactSection(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withOpacity(.03),
        border: Border.all(color: Colors.white.withOpacity(.07)),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _contactHeading(),
                const SizedBox(height: 18),
                _contactDetails(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _contactHeading()),
                const SizedBox(width: 28),
                SizedBox(width: 370, child: _contactDetails()),
              ],
            ),
    );
  }

  Widget _contactHeading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('CORPORATE CONTACT'),
        const SizedBox(height: 8),
        const Text(
          'Connect with Gift Technology.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'For general corporate enquiries, support, or partnership discussions, '
          'use the official contact details below.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 12.7,
            height: 1.55,
            color: Colors.white.withOpacity(.50),
          ),
        ),
      ],
    );
  }

  Widget _contactDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _contactRow(
          Icons.location_on_outlined,
          'Plot 12, 6th Avenue, Rumuaghaolu Road, SARS Rd,\n'
          'Port Harcourt 500101, Rivers, Nigeria',
        ),
        const SizedBox(height: 12),
        _contactRow(Icons.phone_outlined, '+234 901 085 3849'),
        const SizedBox(height: 12),
        _contactRow(Icons.email_outlined, 'support@gifttechnologyltd.com'),
        const SizedBox(height: 12),
        _contactRow(Icons.language_outlined, 'www.gifttechnologyltd.com'),
      ],
    );
  }

  Widget _contactRow(IconData icon, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: _lightBlue),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 12.2,
              height: 1.45,
              color: Colors.white.withOpacity(.58),
            ),
          ),
        ),
      ],
    );
  }

  Widget _roundIcon(IconData icon) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _blue.withOpacity(.11),
        border: Border.all(color: _lightBlue.withOpacity(.15)),
      ),
      child: Icon(icon, color: _lightBlue, size: 25),
    );
  }

  Widget _sectionLabel(String text) {
    return const Text(
      'CORPORATE DETAILS',
      style: TextStyle(
        fontFamily: 'SegoeUI',
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.8,
        color: _lightBlue,
      ),
    );
  }
}

class _CompanyDetail {
  final IconData icon;
  final String label;
  final String value;
  final String caption;

  const _CompanyDetail(this.icon, this.label, this.value, this.caption);
}

class _DetailCard extends StatefulWidget {
  final _CompanyDetail detail;

  const _DetailCard({required this.detail});

  @override
  State<_DetailCard> createState() => _DetailCardState();
}

class _DetailCardState extends State<_DetailCard> {
  bool _hovered = false;

  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _lightBlue = Color(0xFF7EA4FF);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(19),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(_hovered ? .075 : .045),
              Colors.white.withOpacity(.018),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(_hovered ? .13 : .065),
          ),
          boxShadow: [
            BoxShadow(
              color: _blue.withOpacity(_hovered ? .12 : .035),
              blurRadius: _hovered ? 25 : 16,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 41,
              height: 41,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: _blue.withOpacity(.10),
                border: Border.all(color: _lightBlue.withOpacity(.13)),
              ),
              child: Icon(widget.detail.icon, size: 20, color: _lightBlue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.detail.label,
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: .7,
                      color: Colors.white.withOpacity(.43),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.detail.value,
                    style: const TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.detail.caption,
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 10.5,
                      color: Colors.white.withOpacity(.35),
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

class _Pill extends StatelessWidget {
  final String text;

  const _Pill(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white.withOpacity(.045),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'SegoeUI',
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: Colors.white.withOpacity(.60),
        ),
      ),
    );
  }
}
