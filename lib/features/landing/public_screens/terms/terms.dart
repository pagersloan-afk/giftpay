import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:utilityhub/features/landing/widgets/landing_header.dart';
import 'package:utilityhub/features/landing/sections/landing_footer.dart';
import 'package:utilityhub/features/landing/widgets/landing_responsive_layout.dart';

class GiftPayTermsPage extends StatefulWidget {
  const GiftPayTermsPage({super.key});

  @override
  State<GiftPayTermsPage> createState() => _GiftPayTermsPageState();
}

class _GiftPayTermsPageState extends State<GiftPayTermsPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _backgroundController;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;

    if (context == null) return;

    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < 700;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),
      appBar: const LandingHeader(),
      body: AnimatedBuilder(
        animation: _backgroundController,
        builder: (context, child) {
          return Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _TermsBackgroundPainter(
                      _backgroundController.value,
                    ),
                  ),
                ),
              ),

              SingleChildScrollView(
                controller: _scrollController,
                child: LandingResponsiveLayout(
                  child: Column(
                    children: [
                      SizedBox(height: mobile ? 16 : 26),

                      _TermsHeroSection(),

                      SizedBox(height: mobile ? 18 : 26),

                      _AcceptanceBanner(),

                      SizedBox(height: mobile ? 18 : 26),

                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (mobile) {
                            return _MobileTermsContent(
                              onSectionTap: _scrollToSection,
                            );
                          }

                          return _DesktopTermsContent(
                            onSectionTap: _scrollToSection,
                          );
                        },
                      ),

                      SizedBox(height: mobile ? 24 : 40),

                      const LandingFooter(),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/* ================================================================
   BACKGROUND
================================================================ */

class _TermsBackgroundPainter extends CustomPainter {
  final double progress;

  const _TermsBackgroundPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final wave = math.sin(progress * math.pi * 2);

    final bluePaint = Paint()
      ..color = const Color(0xFF4A6BB8).withOpacity(0.045)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 75);

    final navyPaint = Paint()
      ..color = const Color(0xFF273D68).withOpacity(0.035)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 90);

    canvas.drawCircle(
      Offset(size.width * (0.08 + wave * 0.025), size.height * 0.08),
      180,
      bluePaint,
    );

    canvas.drawCircle(
      Offset(size.width * (0.92 - wave * 0.02), size.height * 0.45),
      220,
      navyPaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.35, size.height * 0.88),
      170,
      bluePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TermsBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/* ================================================================
   HERO
================================================================ */

class _TermsHeroSection extends StatelessWidget {
  const _TermsHeroSection();

  static const navy = Color(0xFF273D68);
  static const blue = Color(0xFF4A6BB8);
  static const lightBlue = Color(0xFF75A1FF);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < 700;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(mobile ? 22 : 30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF273D68), Color(0xFF365792), Color(0xFF4A6BB8)],
        ),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.20),
            blurRadius: 38,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: mobile ? -80 : -50,
            top: mobile ? -70 : -100,
            child: Container(
              width: mobile ? 230 : 340,
              height: mobile ? 230 : 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: lightBlue.withOpacity(0.13),
              ),
            ),
          ),
          Positioned(
            right: mobile ? -60 : 120,
            bottom: -120,
            child: Container(
              width: mobile ? 190 : 280,
              height: mobile ? 190 : 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.055),
              ),
            ),
          ),
          Positioned(
            left: mobile ? -100 : -80,
            bottom: -120,
            child: Container(
              width: mobile ? 210 : 300,
              height: mobile ? 210 : 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: blue.withOpacity(0.25),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(mobile ? 24 : 48),
            child: mobile
                ? const _MobileTermsHero()
                : const _DesktopTermsHero(),
          ),
        ],
      ),
    );
  }
}

class _DesktopTermsHero extends StatelessWidget {
  const _DesktopTermsHero();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(flex: 7, child: _TermsHeroCopy()),
        const SizedBox(width: 50),
        Expanded(flex: 3, child: Center(child: _LegalDocumentVisual())),
      ],
    );
  }
}

class _MobileTermsHero extends StatelessWidget {
  const _MobileTermsHero();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TermsHeroCopy(),
        SizedBox(height: 30),
        Center(child: _LegalDocumentVisual()),
      ],
    );
  }
}

class _TermsHeroCopy extends StatelessWidget {
  const _TermsHeroCopy();

  static const navy = Color(0xFF273D68);
  static const blue = Color(0xFF4A6BB8);

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 700;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.16)),
          ),
          child: const Text(
            'GIFTPAY LEGAL',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: 18),

        Text(
          'Terms & Conditions',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: mobile ? 36 : 52,
            height: 1.06,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 16),

        Text(
          'The rules, responsibilities and conditions that govern your use of GiftPay.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: mobile ? 14 : 17,
            height: 1.6,
            color: Colors.white.withOpacity(0.82),
          ),
        ),

        const SizedBox(height: 24),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: const [
            _LegalPill(
              icon: Icons.verified_user_rounded,
              label: 'Official terms',
            ),
            _LegalPill(
              icon: Icons.lock_outline_rounded,
              label: 'Secure platform',
            ),
            _LegalPill(icon: Icons.public_rounded, label: 'GiftPay services'),
          ],
        ),

        const SizedBox(height: 26),

        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 11),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Last updated',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '20 August 2026',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _LegalDocumentVisual extends StatelessWidget {
  const _LegalDocumentVisual();

  static const navy = Color(0xFF273D68);
  static const blue = Color(0xFF4A6BB8);

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 700;

    return Transform.rotate(
      angle: -0.025,
      child: Container(
        width: mobile ? 225 : 255,
        height: mobile ? 275 : 310,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.20),
              blurRadius: 35,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: blue.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(Icons.gavel_rounded, color: blue, size: 22),
                ),
                const Spacer(),
                Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF4A6BB8),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            const Text(
              'GiftPay',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: navy,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'TERMS & CONDITIONS',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: Color(0xFF7B8596),
              ),
            ),

            const SizedBox(height: 20),

            _DocumentLine(width: mobile ? 145 : 170),
            const SizedBox(height: 9),
            _DocumentLine(width: mobile ? 170 : 205),
            const SizedBox(height: 9),
            _DocumentLine(width: mobile ? 125 : 155),
            const SizedBox(height: 9),
            _DocumentLine(width: mobile ? 155 : 185),

            const Spacer(),

            Row(
              children: [
                const Icon(Icons.verified_rounded, color: blue, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Official GiftPay document',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: mobile ? 9 : 10,
                    fontWeight: FontWeight.w700,
                    color: navy,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentLine extends StatelessWidget {
  final double width;

  const _DocumentLine({required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 7,
      decoration: BoxDecoration(
        color: const Color(0xFFE9EDF4),
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

class _LegalPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _LegalPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.09),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.13)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/* ================================================================
   ACCEPTANCE BANNER
================================================================ */

class _AcceptanceBanner extends StatelessWidget {
  const _AcceptanceBanner();

  static const navy = Color(0xFF273D68);
  static const blue = Color(0xFF4A6BB8);

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 700;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(mobile ? 17 : 22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(mobile ? 18 : 22),
        border: Border.all(color: const Color(0xFFE3E8F1)),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.045),
            blurRadius: 25,
            offset: const Offset(0, 10),
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
              color: blue.withOpacity(0.09),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: blue,
              size: 22,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Text(
              'By accessing or using GiftPay, you acknowledge that you have read, understood and agree to be bound by these Terms & Conditions and any applicable policies referenced herein.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                height: 1.55,
                color: Color(0xFF5F6B7D),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ================================================================
   DESKTOP CONTENT
================================================================ */

class _DesktopTermsContent extends StatelessWidget {
  final void Function(GlobalKey key) onSectionTap;

  const _DesktopTermsContent({required this.onSectionTap});

  static const navy = Color(0xFF273D68);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 245,
          child: _TermsNavigation(onSectionTap: onSectionTap),
        ),

        const SizedBox(width: 24),

        const Expanded(child: _TermsDocument()),
      ],
    );
  }
}

/* ================================================================
   MOBILE CONTENT
================================================================ */

class _MobileTermsContent extends StatelessWidget {
  final void Function(GlobalKey key) onSectionTap;

  const _MobileTermsContent({required this.onSectionTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TermsNavigation(onSectionTap: onSectionTap, mobile: true),

        const SizedBox(height: 18),

        const _TermsDocument(),
      ],
    );
  }
}

/* ================================================================
   NAVIGATION
================================================================ */

class _TermsNavigation extends StatelessWidget {
  final void Function(GlobalKey key) onSectionTap;
  final bool mobile;

  const _TermsNavigation({required this.onSectionTap, this.mobile = false});

  static const navy = Color(0xFF273D68);
  static const blue = Color(0xFF4A6BB8);

  static final GlobalKey overviewKey = GlobalKey();
  static final GlobalKey accountKey = GlobalKey();
  static final GlobalKey servicesKey = GlobalKey();
  static final GlobalKey transactionsKey = GlobalKey();
  static final GlobalKey responsibilitiesKey = GlobalKey();
  static final GlobalKey prohibitedKey = GlobalKey();
  static final GlobalKey intellectualKey = GlobalKey();
  static final GlobalKey privacyKey = GlobalKey();
  static final GlobalKey liabilityKey = GlobalKey();
  static final GlobalKey terminationKey = GlobalKey();
  static final GlobalKey changesKey = GlobalKey();
  static final GlobalKey contactKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final items = <_NavigationItem>[
      _NavigationItem(
        title: 'Overview',
        icon: Icons.description_outlined,
        keyRef: overviewKey,
      ),
      _NavigationItem(
        title: 'Your account',
        icon: Icons.person_outline_rounded,
        keyRef: accountKey,
      ),
      _NavigationItem(
        title: 'GiftPay services',
        icon: Icons.apps_rounded,
        keyRef: servicesKey,
      ),
      _NavigationItem(
        title: 'Transactions',
        icon: Icons.receipt_long_outlined,
        keyRef: transactionsKey,
      ),
      _NavigationItem(
        title: 'Your responsibilities',
        icon: Icons.verified_user_outlined,
        keyRef: responsibilitiesKey,
      ),
      _NavigationItem(
        title: 'Prohibited use',
        icon: Icons.block_outlined,
        keyRef: prohibitedKey,
      ),
      _NavigationItem(
        title: 'Intellectual property',
        icon: Icons.copyright_outlined,
        keyRef: intellectualKey,
      ),
      _NavigationItem(
        title: 'Privacy',
        icon: Icons.lock_outline_rounded,
        keyRef: privacyKey,
      ),
      _NavigationItem(
        title: 'Liability',
        icon: Icons.shield_outlined,
        keyRef: liabilityKey,
      ),
      _NavigationItem(
        title: 'Termination',
        icon: Icons.power_settings_new_rounded,
        keyRef: terminationKey,
      ),
      _NavigationItem(
        title: 'Changes',
        icon: Icons.update_rounded,
        keyRef: changesKey,
      ),
      _NavigationItem(
        title: 'Contact',
        icon: Icons.mail_outline_rounded,
        keyRef: contactKey,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(mobile ? 16 : 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(mobile ? 19 : 22),
        border: Border.all(color: const Color(0xFFE4E9F1)),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.055),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ON THIS PAGE',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: blue,
            ),
          ),
          const SizedBox(height: 13),

          if (mobile)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.map((item) {
                return InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => onSectionTap(item.keyRef),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FB),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0xFFE4E8F0)),
                    ),
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: navy,
                      ),
                    ),
                  ),
                );
              }).toList(),
            )
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: InkWell(
                  borderRadius: BorderRadius.circular(11),
                  onTap: () => onSectionTap(item.keyRef),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 9,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item.icon,
                          size: 17,
                          color: const Color(0xFF7C8798),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: navy,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavigationItem {
  final String title;
  final IconData icon;
  final GlobalKey keyRef;

  const _NavigationItem({
    required this.title,
    required this.icon,
    required this.keyRef,
  });
}

/* ================================================================
   LEGAL DOCUMENT
================================================================ */

class _TermsDocument extends StatelessWidget {
  const _TermsDocument();

  static const navy = Color(0xFF273D68);
  static const blue = Color(0xFF4A6BB8);
  static const text = Color(0xFF4F5B6D);

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 700;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(mobile ? 20 : 38),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(mobile ? 20 : 28),
        border: Border.all(color: const Color(0xFFE3E8F0)),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.06),
            blurRadius: 34,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            key: _TermsNavigation.overviewKey,
            child: const _LegalSection(
              number: '01',
              title: 'Introduction',
              child: Text(
                'These Terms & Conditions govern your access to and use of GiftPay, including its website, mobile applications, digital products, payment functionality and related services. By using GiftPay, you agree to comply with these terms.',
              ),
            ),
          ),

          const _LegalDivider(),

          Container(
            key: _TermsNavigation.accountKey,
            child: const _LegalSection(
              number: '02',
              title: 'Your GiftPay account',
              children: [
                _LegalParagraph(
                  'Certain GiftPay services may require you to create or maintain an account. You are responsible for providing accurate information and keeping your account information current.',
                ),
                _LegalBullet(
                  'You must provide truthful and accurate information.',
                ),
                _LegalBullet(
                  'You are responsible for protecting your login credentials.',
                ),
                _LegalBullet(
                  'You should notify GiftPay promptly if you believe your account has been compromised.',
                ),
                _LegalBullet(
                  'You must not knowingly allow unauthorized persons to use your account.',
                ),
              ],
            ),
          ),

          const _LegalDivider(),

          Container(
            key: _TermsNavigation.servicesKey,
            child: const _LegalSection(
              number: '03',
              title: 'GiftPay services',
              children: [
                _LegalParagraph(
                  'GiftPay provides access to a range of digital and financial utility services. These may include airtime, data, electricity payments, television services, gift cards, transfers, travel-related services and other products made available from time to time.',
                ),
                _LegalParagraph(
                  'Individual services may be subject to additional terms, eligibility requirements, fees, limits or conditions provided at the point of use.',
                ),
              ],
            ),
          ),

          const _LegalDivider(),

          Container(
            key: _TermsNavigation.transactionsKey,
            child: const _LegalSection(
              number: '04',
              title: 'Transactions and payments',
              children: [
                _LegalParagraph(
                  'When you initiate a transaction through GiftPay, you authorize the applicable transaction to be processed using the payment method you provide or the available balance associated with your account.',
                ),
                _LegalBullet(
                  'You are responsible for reviewing transaction details before confirmation.',
                ),
                _LegalBullet(
                  'Transaction processing may depend on third-party providers and financial institutions.',
                ),
                _LegalBullet(
                  'A transaction may be delayed, declined, reversed or otherwise affected by circumstances outside GiftPay’s reasonable control.',
                ),
                _LegalBullet(
                  'Applicable fees will be displayed where required before completion of a transaction.',
                ),
              ],
            ),
          ),

          const _LegalDivider(),

          Container(
            key: _TermsNavigation.responsibilitiesKey,
            child: const _LegalSection(
              number: '05',
              title: 'Your responsibilities',
              children: [
                _LegalParagraph(
                  'You agree to use GiftPay only for lawful purposes and in accordance with these Terms & Conditions.',
                ),
                _LegalBullet(
                  'You must comply with applicable laws and regulations.',
                ),
                _LegalBullet(
                  'You must provide accurate information when requested.',
                ),
                _LegalBullet(
                  'You must not interfere with the operation or security of GiftPay.',
                ),
                _LegalBullet(
                  'You must not attempt to gain unauthorized access to systems, accounts or data.',
                ),
              ],
            ),
          ),

          const _LegalDivider(),

          Container(
            key: _TermsNavigation.prohibitedKey,
            child: const _LegalSection(
              number: '06',
              title: 'Prohibited use',
              children: [
                _LegalParagraph(
                  'You may not use GiftPay to engage in unlawful, fraudulent, abusive or deceptive activity. You must not use the platform in a manner that could harm GiftPay, its users, service providers or other parties.',
                ),
                _LegalBullet(
                  'Fraudulent transactions or identity misrepresentation.',
                ),
                _LegalBullet(
                  'Unauthorized access, probing or attempts to bypass security controls.',
                ),
                _LegalBullet('Use of GiftPay for illegal financial activity.'),
                _LegalBullet(
                  'Distribution of malicious software or harmful content.',
                ),
                _LegalBullet(
                  'Activity designed to disrupt or degrade GiftPay services.',
                ),
              ],
            ),
          ),

          const _LegalDivider(),

          Container(
            key: _TermsNavigation.intellectualKey,
            child: const _LegalSection(
              number: '07',
              title: 'Intellectual property',
              children: [
                _LegalParagraph(
                  'GiftPay and its associated branding, visual identity, software, content, interfaces, designs, trademarks and other intellectual property are protected by applicable intellectual property laws.',
                ),
                _LegalParagraph(
                  'Except where expressly permitted, you may not copy, reproduce, modify, distribute, reverse engineer or commercially exploit GiftPay intellectual property without appropriate authorization.',
                ),
              ],
            ),
          ),

          const _LegalDivider(),

          Container(
            key: _TermsNavigation.privacyKey,
            child: const _LegalSection(
              number: '08',
              title: 'Privacy and personal information',
              children: [
                _LegalParagraph(
                  'Your use of GiftPay may involve the collection and processing of personal information. GiftPay handles personal information in accordance with its applicable Privacy Policy and relevant data protection requirements.',
                ),
                _LegalParagraph(
                  'You should review the applicable Privacy Policy to understand how information is collected, used, stored and protected.',
                ),
              ],
            ),
          ),

          const _LegalDivider(),

          Container(
            key: _TermsNavigation.liabilityKey,
            child: const _LegalSection(
              number: '09',
              title: 'Service availability and liability',
              children: [
                _LegalParagraph(
                  'GiftPay aims to provide reliable and secure services but does not guarantee that every service will always be available, uninterrupted or error-free.',
                ),
                _LegalParagraph(
                  'To the extent permitted by applicable law, GiftPay will not be responsible for losses arising from circumstances outside its reasonable control, including third-party service interruptions, telecommunications failures, financial institution issues or events beyond reasonable control.',
                ),
              ],
            ),
          ),

          const _LegalDivider(),

          Container(
            key: _TermsNavigation.terminationKey,
            child: const _LegalSection(
              number: '10',
              title: 'Suspension and termination',
              children: [
                _LegalParagraph(
                  'GiftPay may suspend, restrict or terminate access to an account or service where reasonably necessary, including where there is suspected fraud, abuse, security risk, unlawful activity or violation of these terms.',
                ),
                _LegalParagraph(
                  'Where appropriate and legally permitted, GiftPay may provide notice before taking such action.',
                ),
              ],
            ),
          ),

          const _LegalDivider(),

          Container(
            key: _TermsNavigation.changesKey,
            child: const _LegalSection(
              number: '11',
              title: 'Changes to these terms',
              children: [
                _LegalParagraph(
                  'GiftPay may update these Terms & Conditions from time to time to reflect changes in its services, legal requirements, security practices or business operations.',
                ),
                _LegalParagraph(
                  'The updated version will be made available through the appropriate GiftPay channels. Your continued use of GiftPay after an update may constitute acceptance of the revised terms where permitted by law.',
                ),
              ],
            ),
          ),

          const _LegalDivider(),

          Container(
            key: _TermsNavigation.contactKey,
            child: const _LegalSection(
              number: '12',
              title: 'Contact GiftPay',
              children: [
                _LegalParagraph(
                  'If you have questions, concerns or requests relating to these Terms & Conditions, please contact GiftPay through the official support channels provided on the GiftPay platform.',
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [blue.withOpacity(0.08), const Color(0xFFF6F8FD)],
              ),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: blue.withOpacity(0.14)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.gavel_rounded, size: 21, color: blue),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Important: These Terms & Conditions are provided as the public-facing terms for GiftPay. They should be reviewed and finalized by qualified legal counsel before publication as the company’s definitive legal terms.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      height: 1.55,
                      fontWeight: FontWeight.w600,
                      color: navy,
                    ),
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

/* ================================================================
   LEGAL COMPONENTS
================================================================ */

class _LegalSection extends StatelessWidget {
  final String number;
  final String title;
  final Widget? child;
  final List<Widget>? children;

  const _LegalSection({
    required this.number,
    required this.title,
    this.child,
    this.children,
  });

  static const navy = Color(0xFF273D68);
  static const blue = Color(0xFF4A6BB8);

  @override
  Widget build(BuildContext context) {
    final content = children ?? [if (child != null) child!];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: blue.withOpacity(0.09),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: blue.withOpacity(0.12)),
              ),
              child: Text(
                number,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: blue,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    height: 1.2,
                    fontWeight: FontWeight.w900,
                    color: navy,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        Padding(
          padding: const EdgeInsets.only(left: 56),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: content,
          ),
        ),
      ],
    );
  }
}

class _LegalParagraph extends StatelessWidget {
  final String text;

  const _LegalParagraph(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          height: 1.7,
          color: Color(0xFF4F5B6D),
        ),
      ),
    );
  }
}

class _LegalBullet extends StatelessWidget {
  final String text;

  const _LegalBullet(this.text);

  static const blue = Color(0xFF4A6BB8);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8, right: 11),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: blue,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                height: 1.65,
                color: Color(0xFF5C6778),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalDivider extends StatelessWidget {
  const _LegalDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 30),
      child: Divider(height: 1, color: Color(0xFFE8ECF2)),
    );
  }
}
