import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

/// Premium Terms screen for Gift Technology Ltd.
///
/// The existing source describes this page as:
/// "Terms and conditions governing the use of Gift Technology platforms."
///
/// This screen intentionally focuses on presentation and document navigation.
/// It does not invent legal clauses, dates, fees, obligations, or regulatory
/// statements that are not present in the supplied source material.
class GiftTechTermsScreen extends StatelessWidget {
  const GiftTechTermsScreen({super.key});

  static const Color _navy = Color(0xFF142850);
  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _electricBlue = Color(0xFF5D8FFF);

  @override
  Widget build(BuildContext context) {
    return GiftTechPageTemplate(
      title: 'Terms',
      description:
          'Terms and conditions governing the use of Gift Technology platforms.',
      child: _TermsContent(),
    );
  }
}

class _TermsContent extends StatelessWidget {
  const _TermsContent();

  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _electricBlue = Color(0xFF5D8FFF);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 700;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 28,
        vertical: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDocumentIntro(isMobile),
          const SizedBox(height: 22),
          _buildNavigationGrid(isMobile),
          const SizedBox(height: 22),
          _buildTrustPanel(isMobile),
        ],
      ),
    );
  }

  Widget _buildDocumentIntro(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.085),
            Colors.white.withOpacity(0.035),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.11)),
        boxShadow: [
          BoxShadow(
            color: _blue.withOpacity(0.08),
            blurRadius: 38,
            spreadRadius: 2,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIconOrb(),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GIFT TECHNOLOGY / LEGAL',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                    color: _electricBlue.withOpacity(0.95),
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  'Terms of Use',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: isMobile ? 24 : 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.7,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  'The framework governing access to and use of Gift Technology platforms and services.',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: isMobile ? 13 : 14,
                    height: 1.55,
                    color: Colors.white.withOpacity(0.60),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconOrb() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white.withOpacity(0.13), _blue.withOpacity(0.12)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: [BoxShadow(color: _blue.withOpacity(0.14), blurRadius: 24)],
      ),
      child: const Icon(Icons.gavel_rounded, color: _electricBlue, size: 25),
    );
  }

  Widget _buildNavigationGrid(bool isMobile) {
    final items = const [
      (
        number: '01',
        title: 'Platform Use',
        text:
            'Guidance for using Gift Technology platforms within the applicable terms.',
        icon: Icons.apps_rounded,
      ),
      (
        number: '02',
        title: 'User Responsibilities',
        text:
            'The responsibilities associated with accessing and using our digital platforms.',
        icon: Icons.verified_user_outlined,
      ),
      (
        number: '03',
        title: 'Services',
        text:
            'A structured place for the terms that govern the services made available through our ecosystem.',
        icon: Icons.layers_outlined,
      ),
      (
        number: '04',
        title: 'Important Information',
        text:
            'Review the applicable terms carefully before using a Gift Technology platform.',
        icon: Icons.info_outline_rounded,
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
        mainAxisExtent: isMobile ? 142 : 154,
      ),
      itemBuilder: (context, index) {
        final item = items[index];

        return _LuxuryDocumentCard(
          number: item.number,
          title: item.title,
          text: item.text,
          icon: item.icon,
        );
      },
    );
  }

  Widget _buildTrustPanel(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withOpacity(0.045),
        border: Border.all(color: Colors.white.withOpacity(0.085)),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTrustIcon(),
                const SizedBox(height: 16),
                _buildTrustCopy(),
              ],
            )
          : Row(
              children: [
                _buildTrustIcon(),
                const SizedBox(width: 18),
                Expanded(child: _buildTrustCopy()),
              ],
            ),
    );
  }

  Widget _buildTrustIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _blue.withOpacity(0.10),
        border: Border.all(color: _blue.withOpacity(0.18)),
      ),
      child: const Icon(Icons.shield_outlined, color: _electricBlue, size: 21),
    );
  }

  Widget _buildTrustCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'A clearer digital relationship',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'These terms provide the framework for engaging with Gift Technology platforms. '
          'Please review the complete applicable terms before proceeding.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 13,
            height: 1.55,
            color: Colors.white.withOpacity(0.55),
          ),
        ),
      ],
    );
  }
}

class _LuxuryDocumentCard extends StatefulWidget {
  final String number;
  final String title;
  final String text;
  final IconData icon;

  const _LuxuryDocumentCard({
    required this.number,
    required this.title,
    required this.text,
    required this.icon,
  });

  @override
  State<_LuxuryDocumentCard> createState() => _LuxuryDocumentCardState();
}

class _LuxuryDocumentCardState extends State<_LuxuryDocumentCard> {
  bool _hovered = false;

  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _electricBlue = Color(0xFF5D8FFF);

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
              Colors.white.withOpacity(_hovered ? 0.085 : 0.065),
              Colors.white.withOpacity(0.025),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(_hovered ? 0.15 : 0.085),
          ),
          boxShadow: [
            BoxShadow(
              color: _blue.withOpacity(_hovered ? 0.14 : 0.055),
              blurRadius: _hovered ? 30 : 20,
              offset: const Offset(0, 12),
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
                borderRadius: BorderRadius.circular(14),
                color: _blue.withOpacity(0.10),
                border: Border.all(color: _blue.withOpacity(0.16)),
              ),
              child: Icon(widget.icon, size: 20, color: _electricBlue),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.number,
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: _electricBlue.withOpacity(0.75),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 12.5,
                      height: 1.45,
                      color: Colors.white.withOpacity(0.50),
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
