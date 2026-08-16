import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class InvestorsScreen extends StatelessWidget {
  const InvestorsScreen({super.key});

  static const Color _navy = Color(0xFF273D68);
  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _lightBlue = Color(0xFF5D8FFF);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 760;

    return GiftTechPageTemplate(
      title: 'Investors',
      description:
          'Financial reports, investor updates, and corporate governance information.',
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          isMobile ? 16 : 28,
          8,
          isMobile ? 16 : 28,
          32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _hero(isMobile),
            const SizedBox(height: 22),
            _overview(),
            const SizedBox(height: 22),
            _informationGrid(isMobile),
            const SizedBox(height: 22),
            _companyPanel(isMobile),
          ],
        ),
      ),
    );
  }

  Widget _hero(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_navy, _blue.withOpacity(.78), const Color(0xFF142542)],
        ),
        border: Border.all(color: Colors.white.withOpacity(.13)),
        boxShadow: [
          BoxShadow(
            color: _blue.withOpacity(.20),
            blurRadius: 42,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_heroIcon(), const SizedBox(height: 20), _heroText()],
            )
          : Row(
              children: [
                _heroIcon(),
                const SizedBox(width: 22),
                Expanded(child: _heroText()),
                const SizedBox(width: 24),
                _badge(),
              ],
            ),
    );
  }

  Widget _heroIcon() {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(.09),
        border: Border.all(color: Colors.white.withOpacity(.15)),
        boxShadow: [
          BoxShadow(
            color: _lightBlue.withOpacity(.22),
            blurRadius: 28,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(
        Icons.account_balance_outlined,
        color: Colors.white,
        size: 31,
      ),
    );
  }

  Widget _heroText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GIFT TECHNOLOGY / CORPORATE',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: Colors.white.withOpacity(.68),
          ),
        ),
        const SizedBox(height: 9),
        const Text(
          'Investors',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 31,
            height: 1.05,
            fontWeight: FontWeight.w800,
            letterSpacing: -.9,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'A central destination for financial reports, investor updates, '
          'and corporate governance information.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 14,
            height: 1.55,
            color: Colors.white.withOpacity(.70),
          ),
        ),
      ],
    );
  }

  Widget _badge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white.withOpacity(.075),
        border: Border.all(color: Colors.white.withOpacity(.13)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.trending_up_rounded, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            'CORPORATE INFORMATION',
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

  Widget _overview() {
    return _glassPanel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _iconBox(Icons.insights_outlined),
          const SizedBox(width: 17),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'A clear view of the company',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'The investor experience brings together the information '
                  'stakeholders need to understand Gift Technology, its '
                  'corporate communications, and its governance framework.',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 13,
                    height: 1.6,
                    color: Colors.white.withOpacity(.56),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _informationGrid(bool isMobile) {
    const items = [
      (
        Icons.description_outlined,
        'Financial Reports',
        'A dedicated destination for financial reporting and company-level financial information.',
      ),
      (
        Icons.campaign_outlined,
        'Investor Updates',
        'Keep investor-facing communications and important company updates organized in one place.',
      ),
      (
        Icons.account_balance_outlined,
        'Corporate Governance',
        'Present governance information with clarity, structure, and transparency.',
      ),
      (
        Icons.business_outlined,
        'Company Information',
        'Learn more about Gift Technology Ltd and the organization behind its technology platforms.',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: isMobile ? 158 : 170,
      ),
      itemBuilder: (_, index) => _InvestorCard(
        icon: items[index].$1,
        title: items[index].$2,
        description: items[index].$3,
      ),
    );
  }

  Widget _companyPanel(bool isMobile) {
    final identity = Column(
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
          'Technology built for Africa.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
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
            fontSize: 13,
            height: 1.6,
            color: Colors.white.withOpacity(.58),
          ),
        ),
      ],
    );

    final contacts = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _contact(
          Icons.location_on_outlined,
          'Plot 12, 6th Avenue, Rumuaghaolu Road, SARS Rd, Port Harcourt 500101, Rivers, Nigeria',
        ),
        const SizedBox(height: 13),
        _contact(Icons.phone_outlined, '+234 901 085 3849'),
        const SizedBox(height: 13),
        _contact(Icons.mail_outline_rounded, 'support@gifttechnologyltd.com'),
        const SizedBox(height: 13),
        _contact(Icons.language_outlined, 'www.gifttechnologyltd.com'),
      ],
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_blue.withOpacity(.16), Colors.white.withOpacity(.035)],
        ),
        border: Border.all(color: _blue.withOpacity(.19)),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [identity, const SizedBox(height: 22), contacts],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: identity),
                const SizedBox(width: 30),
                SizedBox(width: 330, child: contacts),
              ],
            ),
    );
  }

  Widget _contact(IconData icon, String text) {
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
              height: 1.4,
              color: Colors.white.withOpacity(.60),
            ),
          ),
        ),
      ],
    );
  }

  Widget _glassPanel({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.045),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(.085)),
      ),
      child: child,
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _blue.withOpacity(.11),
        border: Border.all(color: _blue.withOpacity(.18)),
      ),
      child: Icon(icon, size: 21, color: _lightBlue),
    );
  }
}

class _InvestorCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;

  const _InvestorCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  State<_InvestorCard> createState() => _InvestorCardState();
}

class _InvestorCardState extends State<_InvestorCard> {
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
        padding: const EdgeInsets.all(21),
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
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: _blue.withOpacity(.10),
                border: Border.all(color: _blue.withOpacity(.17)),
              ),
              child: Icon(widget.icon, size: 21, color: _lightBlue),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    widget.description,
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
