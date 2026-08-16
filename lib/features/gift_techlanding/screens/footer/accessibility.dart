import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class AccessibilityScreen extends StatelessWidget {
  const AccessibilityScreen({super.key});

  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _lightBlue = Color(0xFF7EA4FF);

  @override
  Widget build(BuildContext context) {
    return GiftTechPageTemplate(
      eyebrow: 'GIFT TECHNOLOGY / INCLUSIVE DESIGN',
      title: 'Accessibility',
      description:
          'We are committed to making our digital experiences clear, usable, and accessible to as many people as possible.',
      icon: Icons.accessibility_new_rounded,
      metaLabel: 'COMMITMENT',
      metaValue: 'Accessible Digital Experiences',
      secondaryMetaLabel: 'SUPPORT',
      secondaryMetaValue: 'Gift Technology Support',
      child: const _AccessibilityContent(),
    );
  }
}

class _AccessibilityContent extends StatelessWidget {
  const _AccessibilityContent();

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
          _hero(isMobile),
          const SizedBox(height: 20),
          _sectionLabel('DESIGN PRINCIPLES'),
          const SizedBox(height: 12),
          _principlesGrid(isMobile),
          const SizedBox(height: 20),
          _digitalExperienceSection(isMobile),
          const SizedBox(height: 20),
          _limitationsSection(isMobile),
          const SizedBox(height: 20),
          _supportSection(isMobile),
        ],
      ),
    );
  }

  Widget _hero(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(27),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF273D68), Color(0xFF355792), Color(0xFF101A2D)],
        ),
        border: Border.all(color: Colors.white.withOpacity(.11)),
        boxShadow: [
          BoxShadow(
            color: _blue.withOpacity(.17),
            blurRadius: 36,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _accessibilityIcon(),
                const SizedBox(height: 18),
                _heroCopy(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _accessibilityIcon(),
                const SizedBox(width: 20),
                Expanded(child: _heroCopy()),
                const SizedBox(width: 20),
                _commitmentBadge(),
              ],
            ),
    );
  }

  Widget _accessibilityIcon() {
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
        Icons.accessibility_new_rounded,
        color: Colors.white,
        size: 33,
      ),
    );
  }

  Widget _heroCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DESIGNED FOR MORE PEOPLE',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.9,
            color: Colors.white.withOpacity(.62),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Technology should feel usable, not complicated.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 22,
            height: 1.18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -.3,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          'Gift Technology aims to create digital experiences with clear '
          'content, understandable interactions, readable interfaces, and '
          'support when a user needs assistance.',
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

  Widget _commitmentBadge() {
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
          const Icon(
            Icons.check_circle_outline_rounded,
            size: 15,
            color: _lightBlue,
          ),
          const SizedBox(width: 7),
          Text(
            'INCLUSIVE BY DESIGN',
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

  Widget _principlesGrid(bool isMobile) {
    const principles = [
      _AccessibilityPrinciple(
        Icons.visibility_outlined,
        'Clear presentation',
        'Information should be structured and presented in a way that is easy to understand and navigate.',
      ),
      _AccessibilityPrinciple(
        Icons.touch_app_outlined,
        'Straightforward interaction',
        'Controls and actions should communicate their purpose clearly so users can complete tasks with confidence.',
      ),
      _AccessibilityPrinciple(
        Icons.text_fields_rounded,
        'Readable content',
        'We aim for clear language, useful hierarchy, and interfaces that make important information easy to find.',
      ),
      _AccessibilityPrinciple(
        Icons.devices_outlined,
        'Responsive experiences',
        'Our digital experiences are designed to adapt across supported screen sizes and device types.',
      ),
      _AccessibilityPrinciple(
        Icons.notifications_none_rounded,
        'Useful feedback',
        'Important actions and transaction states should provide understandable feedback to the user.',
      ),
      _AccessibilityPrinciple(
        Icons.support_agent_outlined,
        'Human support',
        'When a digital experience does not provide the answer, users can contact Gift Technology support for assistance.',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: principles.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: isMobile ? 122 : 132,
      ),
      itemBuilder: (_, index) => _PrincipleCard(principle: principles[index]),
    );
  }

  Widget _digitalExperienceSection(bool isMobile) {
    return _ContentPanel(
      isMobile: isMobile,
      icon: Icons.web_outlined,
      label: 'DIGITAL EXPERIENCE',
      title: 'Accessibility is part of the product experience.',
      body:
          'Gift Technology builds digital platforms for payments, utilities, '
          'business operations, entertainment, and other services. Across these '
          'experiences, we aim to keep navigation, content, transaction states, '
          'and important actions understandable and usable.',
    );
  }

  Widget _limitationsSection(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.white.withOpacity(.032),
        border: Border.all(color: Colors.white.withOpacity(.075)),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _noteIcon(),
                const SizedBox(height: 16),
                _limitationsCopy(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _noteIcon(),
                const SizedBox(width: 18),
                Expanded(child: _limitationsCopy()),
              ],
            ),
    );
  }

  Widget _noteIcon() {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _blue.withOpacity(.11),
        border: Border.all(color: _lightBlue.withOpacity(.15)),
      ),
      child: const Icon(
        Icons.info_outline_rounded,
        color: _lightBlue,
        size: 25,
      ),
    );
  }

  Widget _limitationsCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('CONTINUOUS IMPROVEMENT'),
        const SizedBox(height: 8),
        const Text(
          'Accessibility is an ongoing process.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          'Digital products can vary across devices, operating systems, browsers, '
          'assistive technologies, and third-party services. We do not claim that '
          'every part of every experience will always be accessible in every '
          'environment. We use feedback and identified issues to improve the experience over time.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 12.7,
            height: 1.6,
            color: Colors.white.withOpacity(.51),
          ),
        ),
      ],
    );
  }

  Widget _supportSection(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF101A2D), Color(0xFF1D2E50)],
        ),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _supportCopy(),
                const SizedBox(height: 18),
                _contactCard(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _supportCopy()),
                const SizedBox(width: 28),
                SizedBox(width: 340, child: _contactCard()),
              ],
            ),
    );
  }

  Widget _supportCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('NEED ASSISTANCE?'),
        const SizedBox(height: 8),
        const Text(
          'Tell us when something is difficult to use.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'If you encounter an accessibility barrier, a confusing interaction, '
          'or another issue that prevents you from using a Gift Technology service, '
          'contact our support team. Please include the service, device or browser '
          'where relevant, and a description of the issue.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 12.7,
            height: 1.58,
            color: Colors.white.withOpacity(.50),
          ),
        ),
      ],
    );
  }

  Widget _contactCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        color: Colors.white.withOpacity(.045),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _contactRow(Icons.email_outlined, 'support@gifttechnologyltd.com'),
          const SizedBox(height: 12),
          _contactRow(Icons.phone_outlined, '+234 901 085 3849'),
          const SizedBox(height: 12),
          _contactRow(
            Icons.location_on_outlined,
            'Port Harcourt, Rivers, Nigeria',
          ),
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: _lightBlue),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 12,
              height: 1.45,
              color: Colors.white.withOpacity(.58),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return const Text(
      'ACCESSIBILITY',
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

class _AccessibilityPrinciple {
  final IconData icon;
  final String title;
  final String description;

  const _AccessibilityPrinciple(this.icon, this.title, this.description);
}

class _PrincipleCard extends StatefulWidget {
  final _AccessibilityPrinciple principle;

  const _PrincipleCard({required this.principle});

  @override
  State<_PrincipleCard> createState() => _PrincipleCardState();
}

class _PrincipleCardState extends State<_PrincipleCard> {
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
          borderRadius: BorderRadius.circular(20),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: _blue.withOpacity(.10),
                border: Border.all(color: _lightBlue.withOpacity(.14)),
              ),
              child: Icon(widget.principle.icon, size: 21, color: _lightBlue),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.principle.title,
                    style: const TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 14.2,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.principle.description,
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 11.7,
                      height: 1.45,
                      color: Colors.white.withOpacity(.49),
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

class _ContentPanel extends StatelessWidget {
  final bool isMobile;
  final IconData icon;
  final String label;
  final String title;
  final String body;

  const _ContentPanel({
    required this.isMobile,
    required this.icon,
    required this.label,
    required this.title,
    required this.body,
  });

  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _lightBlue = Color(0xFF7EA4FF);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_blue.withOpacity(.10), Colors.white.withOpacity(.028)],
        ),
        border: Border.all(color: _lightBlue.withOpacity(.10)),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_icon(), const SizedBox(height: 16), _copy()],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _icon(),
                const SizedBox(width: 18),
                Expanded(child: _copy()),
              ],
            ),
    );
  }

  Widget _icon() {
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

  Widget _copy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
            color: _lightBlue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          body,
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 12.7,
            height: 1.6,
            color: Colors.white.withOpacity(.52),
          ),
        ),
      ],
    );
  }
}
