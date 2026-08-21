import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:utilityhub/features/landing/widgets/landing_header.dart';
import 'package:utilityhub/features/landing/sections/landing_footer.dart';
import 'package:utilityhub/features/landing/widgets/landing_responsive_layout.dart';

class GiftPayPrivacyPage extends StatefulWidget {
  const GiftPayPrivacyPage({super.key});

  @override
  State<GiftPayPrivacyPage> createState() => _GiftPayPrivacyPageState();
}

class _GiftPayPrivacyPageState extends State<GiftPayPrivacyPage>
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
                    painter: _PrivacyBackgroundPainter(
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

                      const _PrivacyHeroSection(),

                      SizedBox(height: mobile ? 18 : 26),

                      const _PrivacyNoticeBanner(),

                      SizedBox(height: mobile ? 18 : 26),

                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (mobile) {
                            return _MobilePrivacyContent(
                              onSectionTap: _scrollToSection,
                            );
                          }

                          return _DesktopPrivacyContent(
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

class _PrivacyBackgroundPainter extends CustomPainter {
  final double progress;

  const _PrivacyBackgroundPainter(this.progress);

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
  bool shouldRepaint(covariant _PrivacyBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/* ================================================================
   HERO
================================================================ */

class _PrivacyHeroSection extends StatelessWidget {
  const _PrivacyHeroSection();

  static const navy = Color(0xFF273D68);
  static const blue = Color(0xFF4A6BB8);
  static const lightBlue = Color(0xFF75A1FF);

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 700;

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
                ? const _MobilePrivacyHero()
                : const _DesktopPrivacyHero(),
          ),
        ],
      ),
    );
  }
}

class _DesktopPrivacyHero extends StatelessWidget {
  const _DesktopPrivacyHero();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(flex: 7, child: _PrivacyHeroCopy()),
        SizedBox(width: 50),
        Expanded(flex: 3, child: Center(child: _PrivacyDocumentVisual())),
      ],
    );
  }
}

class _MobilePrivacyHero extends StatelessWidget {
  const _MobilePrivacyHero();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PrivacyHeroCopy(),
        SizedBox(height: 30),
        Center(child: _PrivacyDocumentVisual()),
      ],
    );
  }
}

class _PrivacyHeroCopy extends StatelessWidget {
  const _PrivacyHeroCopy();

  static const navy = Color(0xFF273D68);

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
            'GIFTPAY PRIVACY',
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
          'Privacy Policy',
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
          'Learn how GiftPay collects, uses, protects and manages information when you use our services.',
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
            _PrivacyPill(icon: Icons.shield_outlined, label: 'Data protection'),
            _PrivacyPill(
              icon: Icons.lock_outline_rounded,
              label: 'Secure handling',
            ),
            _PrivacyPill(
              icon: Icons.visibility_outlined,
              label: 'Transparency',
            ),
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

/* ================================================================
   PRIVACY DOCUMENT VISUAL
================================================================ */

class _PrivacyDocumentVisual extends StatelessWidget {
  const _PrivacyDocumentVisual();

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
                  child: const Icon(
                    Icons.shield_rounded,
                    color: blue,
                    size: 22,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: blue,
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
              'PRIVACY POLICY',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: Color(0xFF7B8596),
              ),
            ),

            const SizedBox(height: 20),

            _PrivacyDocumentLine(width: mobile ? 145 : 170),
            const SizedBox(height: 9),
            _PrivacyDocumentLine(width: mobile ? 170 : 205),
            const SizedBox(height: 9),
            _PrivacyDocumentLine(width: mobile ? 125 : 155),
            const SizedBox(height: 9),
            _PrivacyDocumentLine(width: mobile ? 155 : 185),

            const Spacer(),

            Row(
              children: [
                const Icon(Icons.lock_rounded, color: blue, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Your information matters',
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

class _PrivacyDocumentLine extends StatelessWidget {
  final double width;

  const _PrivacyDocumentLine({required this.width});

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

class _PrivacyPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PrivacyPill({required this.icon, required this.label});

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
   PRIVACY NOTICE
================================================================ */

class _PrivacyNoticeBanner extends StatelessWidget {
  const _PrivacyNoticeBanner();

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
              Icons.privacy_tip_outlined,
              color: blue,
              size: 22,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Text(
              'This Privacy Policy explains how information may be collected, used, stored and protected when you access or use GiftPay. By using GiftPay, you acknowledge this policy and the applicable privacy practices described herein.',
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

class _DesktopPrivacyContent extends StatelessWidget {
  final void Function(GlobalKey key) onSectionTap;

  const _DesktopPrivacyContent({required this.onSectionTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 245,
          child: _PrivacyNavigation(onSectionTap: onSectionTap),
        ),
        const SizedBox(width: 24),
        const Expanded(child: _PrivacyDocument()),
      ],
    );
  }
}

/* ================================================================
   MOBILE CONTENT
================================================================ */

class _MobilePrivacyContent extends StatelessWidget {
  final void Function(GlobalKey key) onSectionTap;

  const _MobilePrivacyContent({required this.onSectionTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PrivacyNavigation(onSectionTap: onSectionTap, mobile: true),
        const SizedBox(height: 18),
        const _PrivacyDocument(),
      ],
    );
  }
}

/* ================================================================
   NAVIGATION
================================================================ */

class _PrivacyNavigation extends StatelessWidget {
  final void Function(GlobalKey key) onSectionTap;
  final bool mobile;

  const _PrivacyNavigation({required this.onSectionTap, this.mobile = false});

  static const navy = Color(0xFF273D68);
  static const blue = Color(0xFF4A6BB8);

  static final GlobalKey overviewKey = GlobalKey();
  static final GlobalKey informationKey = GlobalKey();
  static final GlobalKey collectionKey = GlobalKey();
  static final GlobalKey usageKey = GlobalKey();
  static final GlobalKey sharingKey = GlobalKey();
  static final GlobalKey paymentsKey = GlobalKey();
  static final GlobalKey retentionKey = GlobalKey();
  static final GlobalKey securityKey = GlobalKey();
  static final GlobalKey rightsKey = GlobalKey();
  static final GlobalKey cookiesKey = GlobalKey();
  static final GlobalKey childrenKey = GlobalKey();
  static final GlobalKey changesKey = GlobalKey();
  static final GlobalKey contactKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final items = <_PrivacyNavigationItem>[
      _PrivacyNavigationItem(
        title: 'Overview',
        icon: Icons.privacy_tip_outlined,
        keyRef: overviewKey,
      ),
      _PrivacyNavigationItem(
        title: 'Information we collect',
        icon: Icons.info_outline_rounded,
        keyRef: informationKey,
      ),
      _PrivacyNavigationItem(
        title: 'How information is collected',
        icon: Icons.input_rounded,
        keyRef: collectionKey,
      ),
      _PrivacyNavigationItem(
        title: 'How we use information',
        icon: Icons.auto_awesome_outlined,
        keyRef: usageKey,
      ),
      _PrivacyNavigationItem(
        title: 'Information sharing',
        icon: Icons.share_outlined,
        keyRef: sharingKey,
      ),
      _PrivacyNavigationItem(
        title: 'Payments & transactions',
        icon: Icons.payments_outlined,
        keyRef: paymentsKey,
      ),
      _PrivacyNavigationItem(
        title: 'Data retention',
        icon: Icons.inventory_2_outlined,
        keyRef: retentionKey,
      ),
      _PrivacyNavigationItem(
        title: 'Security',
        icon: Icons.shield_outlined,
        keyRef: securityKey,
      ),
      _PrivacyNavigationItem(
        title: 'Your privacy rights',
        icon: Icons.verified_user_outlined,
        keyRef: rightsKey,
      ),
      _PrivacyNavigationItem(
        title: 'Cookies & technologies',
        icon: Icons.cookie_outlined,
        keyRef: cookiesKey,
      ),
      _PrivacyNavigationItem(
        title: 'Children & privacy',
        icon: Icons.child_care_outlined,
        keyRef: childrenKey,
      ),
      _PrivacyNavigationItem(
        title: 'Changes to this policy',
        icon: Icons.update_rounded,
        keyRef: changesKey,
      ),
      _PrivacyNavigationItem(
        title: 'Contact GiftPay',
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

class _PrivacyNavigationItem {
  final String title;
  final IconData icon;
  final GlobalKey keyRef;

  const _PrivacyNavigationItem({
    required this.title,
    required this.icon,
    required this.keyRef,
  });
}

/* ================================================================
   PRIVACY DOCUMENT
================================================================ */

class _PrivacyDocument extends StatelessWidget {
  const _PrivacyDocument();

  static const navy = Color(0xFF273D68);
  static const blue = Color(0xFF4A6BB8);

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
            key: _PrivacyNavigation.overviewKey,
            child: const _PrivacySection(
              number: '01',
              title: 'Introduction',
              child: Text(
                'This Privacy Policy explains how GiftPay may collect, use, disclose, store and protect information relating to users of the GiftPay website, applications, digital products and related services.',
              ),
            ),
          ),

          const _PrivacyDivider(),

          Container(
            key: _PrivacyNavigation.informationKey,
            child: const _PrivacySection(
              number: '02',
              title: 'Information we may collect',
              children: [
                _PrivacyParagraph(
                  'The information GiftPay collects may vary depending on the services you use, the transactions you initiate and the information required to provide or secure those services.',
                ),
                _PrivacyBullet(
                  'Account and contact information, such as your name, email address, telephone number and other account details.',
                ),
                _PrivacyBullet(
                  'Identity or verification information where verification is required.',
                ),
                _PrivacyBullet(
                  'Transaction information, including transaction references, service details, amounts and status.',
                ),
                _PrivacyBullet(
                  'Payment-related information necessary to process or verify transactions.',
                ),
                _PrivacyBullet(
                  'Device, browser, technical and usage information associated with your interaction with GiftPay.',
                ),
              ],
            ),
          ),

          const _PrivacyDivider(),

          Container(
            key: _PrivacyNavigation.collectionKey,
            child: const _PrivacySection(
              number: '03',
              title: 'How information is collected',
              children: [
                _PrivacyParagraph(
                  'GiftPay may collect information directly from you when you create an account, complete a transaction, contact support, submit information through a form or otherwise interact with GiftPay.',
                ),
                _PrivacyParagraph(
                  'Certain technical information may also be collected automatically when you access or use GiftPay, including information relating to your device, browser, network connection and interaction with the platform.',
                ),
                _PrivacyParagraph(
                  'GiftPay may also receive relevant information from service providers, payment processors, verification providers or other third parties where necessary to provide requested services or meet applicable requirements.',
                ),
              ],
            ),
          ),

          const _PrivacyDivider(),

          Container(
            key: _PrivacyNavigation.usageKey,
            child: const _PrivacySection(
              number: '04',
              title: 'How we use information',
              children: [
                _PrivacyParagraph(
                  'GiftPay may use information for purposes reasonably necessary to operate the platform, provide services, process transactions, protect users and comply with applicable requirements.',
                ),
                _PrivacyBullet('To create, maintain and secure your account.'),
                _PrivacyBullet(
                  'To provide the products and services you request.',
                ),
                _PrivacyBullet('To process, verify and support transactions.'),
                _PrivacyBullet(
                  'To respond to support requests and communicate with you.',
                ),
                _PrivacyBullet(
                  'To detect, prevent and investigate fraud, abuse and security incidents.',
                ),
                _PrivacyBullet(
                  'To improve GiftPay products, services, functionality and user experience.',
                ),
                _PrivacyBullet(
                  'To comply with legal, regulatory, contractual and security obligations.',
                ),
              ],
            ),
          ),

          const _PrivacyDivider(),

          Container(
            key: _PrivacyNavigation.sharingKey,
            child: const _PrivacySection(
              number: '05',
              title: 'Information sharing',
              children: [
                _PrivacyParagraph(
                  'GiftPay does not treat your personal information as publicly available information. Information may be shared with appropriate parties where reasonably necessary to provide services, process transactions, protect the platform or satisfy applicable legal requirements.',
                ),
                _PrivacyBullet(
                  'Payment processors and financial service providers involved in a transaction.',
                ),
                _PrivacyBullet(
                  'Service providers that help GiftPay operate, maintain or secure its platform.',
                ),
                _PrivacyBullet(
                  'Identity verification or compliance providers where verification is required.',
                ),
                _PrivacyBullet(
                  'Government authorities, regulators or law enforcement where disclosure is required or legally permitted.',
                ),
                _PrivacyBullet(
                  'Professional advisers or other authorized parties where reasonably necessary to protect GiftPay rights or interests.',
                ),
              ],
            ),
          ),

          const _PrivacyDivider(),

          Container(
            key: _PrivacyNavigation.paymentsKey,
            child: const _PrivacySection(
              number: '06',
              title: 'Payments and transaction information',
              children: [
                _PrivacyParagraph(
                  'GiftPay may process information associated with payments and transactions in order to provide the requested service, verify transaction status, maintain records and assist with transaction-related enquiries.',
                ),
                _PrivacyParagraph(
                  'Payment information may be processed through third-party payment providers or financial institutions. Those providers may have their own privacy practices and terms that apply to information processed through their systems.',
                ),
                _PrivacyParagraph(
                  'GiftPay users should review transaction details carefully before confirming a payment and should avoid sharing confidential authentication information with other persons.',
                ),
              ],
            ),
          ),

          const _PrivacyDivider(),

          Container(
            key: _PrivacyNavigation.retentionKey,
            child: const _PrivacySection(
              number: '07',
              title: 'Data retention',
              children: [
                _PrivacyParagraph(
                  'GiftPay may retain information for as long as reasonably necessary to provide services, maintain transaction records, resolve disputes, protect the platform, meet contractual requirements and comply with applicable legal or regulatory obligations.',
                ),
                _PrivacyParagraph(
                  'Retention periods may vary depending on the type of information, the purpose for which it was collected and applicable requirements.',
                ),
              ],
            ),
          ),

          const _PrivacyDivider(),

          Container(
            key: _PrivacyNavigation.securityKey,
            child: const _PrivacySection(
              number: '08',
              title: 'Security',
              children: [
                _PrivacyParagraph(
                  'GiftPay takes reasonable measures designed to protect information against unauthorized access, misuse, alteration, disclosure or loss.',
                ),
                _PrivacyBullet(
                  'Access to information may be limited based on operational requirements.',
                ),
                _PrivacyBullet(
                  'Security controls may be used to protect accounts and transactions.',
                ),
                _PrivacyBullet(
                  'Monitoring and security procedures may be used to detect suspicious activity.',
                ),
                _PrivacyBullet(
                  'Users are responsible for protecting their passwords, PINs and authentication credentials.',
                ),
                _PrivacyParagraph(
                  'No method of transmission or storage can be guaranteed to be completely secure. Users should contact GiftPay promptly if they suspect unauthorized access or fraudulent activity involving their account.',
                ),
              ],
            ),
          ),

          const _PrivacyDivider(),

          Container(
            key: _PrivacyNavigation.rightsKey,
            child: const _PrivacySection(
              number: '09',
              title: 'Your privacy rights',
              children: [
                _PrivacyParagraph(
                  'Depending on your location and applicable law, you may have rights relating to personal information held by GiftPay. These may include rights to request access, correction, deletion or other appropriate handling of your information.',
                ),
                _PrivacyParagraph(
                  'Requests may be subject to identity verification, applicable legal requirements and legitimate exceptions. GiftPay may also need to retain certain information where required for legal, regulatory, security or transaction-record purposes.',
                ),
              ],
            ),
          ),

          const _PrivacyDivider(),

          Container(
            key: _PrivacyNavigation.cookiesKey,
            child: const _PrivacySection(
              number: '10',
              title: 'Cookies and similar technologies',
              children: [
                _PrivacyParagraph(
                  'GiftPay may use cookies, local storage, analytics technologies or similar mechanisms to support website functionality, remember preferences, understand usage and improve the user experience.',
                ),
                _PrivacyParagraph(
                  'Depending on your browser or device settings, you may be able to control or restrict certain cookies and similar technologies. Disabling some technologies may affect the availability or functionality of parts of the GiftPay platform.',
                ),
              ],
            ),
          ),

          const _PrivacyDivider(),

          Container(
            key: _PrivacyNavigation.childrenKey,
            child: const _PrivacySection(
              number: '11',
              title: 'Children and privacy',
              children: [
                _PrivacyParagraph(
                  'GiftPay services are not intended to encourage children to provide personal information without appropriate authorization. Where applicable, GiftPay may take reasonable steps to address information that it becomes aware has been submitted by a child in circumstances where collection was not appropriate.',
                ),
              ],
            ),
          ),

          const _PrivacyDivider(),

          Container(
            key: _PrivacyNavigation.changesKey,
            child: const _PrivacySection(
              number: '12',
              title: 'Changes to this Privacy Policy',
              children: [
                _PrivacyParagraph(
                  'GiftPay may update this Privacy Policy from time to time to reflect changes in its services, technology, security practices, legal requirements or business operations.',
                ),
                _PrivacyParagraph(
                  'The updated version will be made available through appropriate GiftPay channels. The effective or last-updated date will be displayed with the applicable version of the policy.',
                ),
              ],
            ),
          ),

          const _PrivacyDivider(),

          Container(
            key: _PrivacyNavigation.contactKey,
            child: const _PrivacySection(
              number: '13',
              title: 'Contact GiftPay',
              children: [
                _PrivacyParagraph(
                  'If you have questions, concerns or requests relating to this Privacy Policy or the handling of your personal information, please contact GiftPay through the official support channels provided on the GiftPay platform.',
                ),
                _PrivacyParagraph(
                  'When contacting support about a privacy request, provide enough information for GiftPay to understand and verify your request. Never send your password, PIN, authentication code or other confidential account credentials.',
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
                Icon(Icons.privacy_tip_rounded, size: 21, color: blue),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Important: This Privacy Policy is intended as a public-facing GiftPay privacy framework. It should be reviewed and finalized by qualified privacy or legal counsel to ensure that it accurately reflects GiftPay’s actual data practices, jurisdictions, service providers and applicable privacy laws before publication as the definitive policy.',
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
   PRIVACY COMPONENTS
================================================================ */

class _PrivacySection extends StatelessWidget {
  final String number;
  final String title;
  final Widget? child;
  final List<Widget>? children;

  const _PrivacySection({
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

class _PrivacyParagraph extends StatelessWidget {
  final String text;

  const _PrivacyParagraph(this.text);

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

class _PrivacyBullet extends StatelessWidget {
  final String text;

  const _PrivacyBullet(this.text);

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

class _PrivacyDivider extends StatelessWidget {
  const _PrivacyDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 30),
      child: Divider(height: 1, color: Color(0xFFE8ECF2)),
    );
  }
}
