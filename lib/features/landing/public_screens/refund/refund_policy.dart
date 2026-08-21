import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:utilityhub/features/landing/widgets/landing_header.dart';
import 'package:utilityhub/features/landing/sections/landing_footer.dart';
import 'package:utilityhub/features/landing/widgets/landing_responsive_layout.dart';

class GiftPayRefundPolicyPage extends StatefulWidget {
  const GiftPayRefundPolicyPage({super.key});

  @override
  State<GiftPayRefundPolicyPage> createState() =>
      _GiftPayRefundPolicyPageState();
}

class _GiftPayRefundPolicyPageState extends State<GiftPayRefundPolicyPage>
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
                    painter: _RefundBackgroundPainter(
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

                      const _RefundHeroSection(),

                      SizedBox(height: mobile ? 18 : 26),

                      const _RefundNoticeBanner(),

                      SizedBox(height: mobile ? 18 : 26),

                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (mobile) {
                            return _MobileRefundContent(
                              onSectionTap: _scrollToSection,
                            );
                          }

                          return _DesktopRefundContent(
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

class _RefundBackgroundPainter extends CustomPainter {
  final double progress;

  const _RefundBackgroundPainter(this.progress);

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
  bool shouldRepaint(covariant _RefundBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/* ================================================================
   HERO
================================================================ */

class _RefundHeroSection extends StatelessWidget {
  const _RefundHeroSection();

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
                ? const _MobileRefundHero()
                : const _DesktopRefundHero(),
          ),
        ],
      ),
    );
  }
}

class _DesktopRefundHero extends StatelessWidget {
  const _DesktopRefundHero();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(flex: 7, child: _RefundHeroCopy()),
        SizedBox(width: 50),
        Expanded(flex: 3, child: Center(child: _RefundDocumentVisual())),
      ],
    );
  }
}

class _MobileRefundHero extends StatelessWidget {
  const _MobileRefundHero();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RefundHeroCopy(),
        SizedBox(height: 30),
        Center(child: _RefundDocumentVisual()),
      ],
    );
  }
}

class _RefundHeroCopy extends StatelessWidget {
  const _RefundHeroCopy();

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
            'GIFTPAY POLICY',
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
          'Refund Policy',
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
          'Understand when refunds, reversals and transaction corrections may apply to GiftPay services.',
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
            _PolicyPill(
              icon: Icons.currency_exchange_rounded,
              label: 'Refund guidance',
            ),
            _PolicyPill(
              icon: Icons.verified_user_rounded,
              label: 'Transaction support',
            ),
            _PolicyPill(
              icon: Icons.support_agent_rounded,
              label: 'Customer assistance',
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
   REFUND DOCUMENT VISUAL
================================================================ */

class _RefundDocumentVisual extends StatelessWidget {
  const _RefundDocumentVisual();

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
                    Icons.currency_exchange_rounded,
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
              'REFUND POLICY',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: Color(0xFF7B8596),
              ),
            ),
            const SizedBox(height: 20),
            _RefundDocumentLine(width: mobile ? 145 : 170),
            const SizedBox(height: 9),
            _RefundDocumentLine(width: mobile ? 170 : 205),
            const SizedBox(height: 9),
            _RefundDocumentLine(width: mobile ? 125 : 155),
            const SizedBox(height: 9),
            _RefundDocumentLine(width: mobile ? 155 : 185),
            const Spacer(),
            Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: blue, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Official GiftPay policy',
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

class _RefundDocumentLine extends StatelessWidget {
  final double width;

  const _RefundDocumentLine({required this.width});

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

class _PolicyPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PolicyPill({required this.icon, required this.label});

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
   NOTICE BANNER
================================================================ */

class _RefundNoticeBanner extends StatelessWidget {
  const _RefundNoticeBanner();

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
              'Refund eligibility may depend on the service purchased, transaction status, payment method and the applicable third-party provider rules. Always check the transaction status before submitting a duplicate payment or refund request.',
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

class _DesktopRefundContent extends StatelessWidget {
  final void Function(GlobalKey key) onSectionTap;

  const _DesktopRefundContent({required this.onSectionTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 245,
          child: _RefundNavigation(onSectionTap: onSectionTap),
        ),
        const SizedBox(width: 24),
        const Expanded(child: _RefundDocument()),
      ],
    );
  }
}

/* ================================================================
   MOBILE CONTENT
================================================================ */

class _MobileRefundContent extends StatelessWidget {
  final void Function(GlobalKey key) onSectionTap;

  const _MobileRefundContent({required this.onSectionTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _RefundNavigation(onSectionTap: onSectionTap, mobile: true),
        const SizedBox(height: 18),
        const _RefundDocument(),
      ],
    );
  }
}

/* ================================================================
   NAVIGATION
================================================================ */

class _RefundNavigation extends StatelessWidget {
  final void Function(GlobalKey key) onSectionTap;
  final bool mobile;

  const _RefundNavigation({required this.onSectionTap, this.mobile = false});

  static const navy = Color(0xFF273D68);
  static const blue = Color(0xFF4A6BB8);

  static final GlobalKey overviewKey = GlobalKey();
  static final GlobalKey eligibilityKey = GlobalKey();
  static final GlobalKey eligibleKey = GlobalKey();
  static final GlobalKey nonEligibleKey = GlobalKey();
  static final GlobalKey failedKey = GlobalKey();
  static final GlobalKey duplicateKey = GlobalKey();
  static final GlobalKey giftCardKey = GlobalKey();
  static final GlobalKey walletKey = GlobalKey();
  static final GlobalKey timingKey = GlobalKey();
  static final GlobalKey requestsKey = GlobalKey();
  static final GlobalKey exceptionsKey = GlobalKey();
  static final GlobalKey contactKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final items = <_RefundNavigationItem>[
      _RefundNavigationItem(
        title: 'Overview',
        icon: Icons.description_outlined,
        keyRef: overviewKey,
      ),
      _RefundNavigationItem(
        title: 'Refund eligibility',
        icon: Icons.rule_folder_outlined,
        keyRef: eligibilityKey,
      ),
      _RefundNavigationItem(
        title: 'Eligible transactions',
        icon: Icons.check_circle_outline_rounded,
        keyRef: eligibleKey,
      ),
      _RefundNavigationItem(
        title: 'Non-refundable transactions',
        icon: Icons.cancel_outlined,
        keyRef: nonEligibleKey,
      ),
      _RefundNavigationItem(
        title: 'Failed transactions',
        icon: Icons.error_outline_rounded,
        keyRef: failedKey,
      ),
      _RefundNavigationItem(
        title: 'Duplicate payments',
        icon: Icons.copy_outlined,
        keyRef: duplicateKey,
      ),
      _RefundNavigationItem(
        title: 'Gift cards',
        icon: Icons.card_giftcard_outlined,
        keyRef: giftCardKey,
      ),
      _RefundNavigationItem(
        title: 'Wallet refunds',
        icon: Icons.account_balance_wallet_outlined,
        keyRef: walletKey,
      ),
      _RefundNavigationItem(
        title: 'Refund timing',
        icon: Icons.schedule_outlined,
        keyRef: timingKey,
      ),
      _RefundNavigationItem(
        title: 'Requesting a refund',
        icon: Icons.assignment_outlined,
        keyRef: requestsKey,
      ),
      _RefundNavigationItem(
        title: 'Exceptions',
        icon: Icons.warning_amber_outlined,
        keyRef: exceptionsKey,
      ),
      _RefundNavigationItem(
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

class _RefundNavigationItem {
  final String title;
  final IconData icon;
  final GlobalKey keyRef;

  const _RefundNavigationItem({
    required this.title,
    required this.icon,
    required this.keyRef,
  });
}

/* ================================================================
   REFUND DOCUMENT
================================================================ */

class _RefundDocument extends StatelessWidget {
  const _RefundDocument();

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
            key: _RefundNavigation.overviewKey,
            child: const _RefundSection(
              number: '01',
              title: 'Refund policy overview',
              child: _RefundParagraph(
                'This Refund Policy explains how GiftPay handles refund, reversal and transaction correction requests relating to services purchased through the GiftPay platform. Refund availability may vary depending on the service, transaction status, payment method and applicable third-party provider rules.',
              ),
            ),
          ),

          const _RefundDivider(),

          Container(
            key: _RefundNavigation.eligibilityKey,
            child: const _RefundSection(
              number: '02',
              title: 'General refund eligibility',
              children: [
                _RefundParagraph(
                  'A refund may be considered where a transaction could not be completed, a service was not delivered, a payment was processed incorrectly or another circumstance reasonably supports the return of funds.',
                ),
                _RefundParagraph(
                  'Refund eligibility is determined based on the facts of the transaction and the rules applicable to the specific service involved.',
                ),
                _RefundBullet(
                  'The transaction must be identifiable through a valid transaction reference or account record.',
                ),
                _RefundBullet(
                  'GiftPay may review the transaction status before approving a refund.',
                ),
                _RefundBullet(
                  'Additional information may be requested to investigate a refund claim.',
                ),
              ],
            ),
          ),

          const _RefundDivider(),

          Container(
            key: _RefundNavigation.eligibleKey,
            child: const _RefundSection(
              number: '03',
              title: 'Transactions that may qualify for a refund',
              children: [
                _RefundParagraph(
                  'Depending on the service and transaction circumstances, the following situations may qualify for review:',
                ),
                _RefundBullet(
                  'A payment was successfully processed but the purchased service was not delivered.',
                ),
                _RefundBullet(
                  'A transaction failed after funds were deducted from the customer.',
                ),
                _RefundBullet(
                  'A transaction was processed incorrectly due to a confirmed system or processing error.',
                ),
                _RefundBullet(
                  'A duplicate transaction was successfully identified and verified.',
                ),
                _RefundBullet(
                  'A third-party provider confirms that the transaction could not be fulfilled and funds should be returned.',
                ),
              ],
            ),
          ),

          const _RefundDivider(),

          Container(
            key: _RefundNavigation.nonEligibleKey,
            child: const _RefundSection(
              number: '04',
              title: 'Transactions that may not be refundable',
              children: [
                _RefundParagraph(
                  'Some transactions may not qualify for a refund after successful fulfillment, particularly where the service has already been delivered or redeemed.',
                ),
                _RefundBullet(
                  'Services that have already been successfully consumed or redeemed.',
                ),
                _RefundBullet(
                  'Transactions completed using incorrect information supplied by the customer, where correction or reversal is not technically or commercially possible.',
                ),
                _RefundBullet(
                  'Transactions that are outside the applicable refund period.',
                ),
                _RefundBullet(
                  'Transactions restricted by the applicable service provider or issuer terms.',
                ),
                _RefundBullet(
                  'Refund requests associated with fraudulent, abusive or unauthorized activity where the customer cannot establish a legitimate claim.',
                ),
              ],
            ),
          ),

          const _RefundDivider(),

          Container(
            key: _RefundNavigation.failedKey,
            child: const _RefundSection(
              number: '05',
              title: 'Failed transactions',
              children: [
                _RefundParagraph(
                  'If a transaction fails but your account or payment method was charged, do not immediately repeat the transaction. First check the transaction status in your GiftPay account.',
                ),
                _RefundParagraph(
                  'Where a failed transaction is confirmed and funds were deducted, GiftPay may initiate or facilitate a reversal in accordance with the applicable payment and service-provider process.',
                ),
              ],
            ),
          ),

          const _RefundDivider(),

          Container(
            key: _RefundNavigation.duplicateKey,
            child: const _RefundSection(
              number: '06',
              title: 'Duplicate payments',
              children: [
                _RefundParagraph(
                  'If you believe you have paid for the same service more than once, contact GiftPay support as soon as possible with the relevant transaction references.',
                ),
                _RefundParagraph(
                  'GiftPay may compare the transactions and determine whether one or more duplicate payments qualify for reversal or refund.',
                ),
                _RefundBullet(
                  'Do not intentionally submit multiple payments for the same service while waiting for a transaction to complete.',
                ),
                _RefundBullet(
                  'Keep all relevant transaction references when reporting a duplicate payment.',
                ),
              ],
            ),
          ),

          const _RefundDivider(),

          Container(
            key: _RefundNavigation.giftCardKey,
            child: const _RefundSection(
              number: '07',
              title: 'Gift card refunds',
              children: [
                _RefundParagraph(
                  'Gift card purchases may be subject to additional restrictions because digital gift cards can be delivered, activated or redeemed electronically.',
                ),
                _RefundParagraph(
                  'A refund request for a gift card may depend on whether the gift card has been delivered, activated, redeemed or otherwise used.',
                ),
                _RefundBullet(
                  'Keep the gift card transaction reference and delivery information.',
                ),
                _RefundBullet(
                  'Do not share a gift card code publicly when requesting support.',
                ),
                _RefundBullet(
                  'Refund eligibility may also depend on the applicable gift card issuer or brand terms.',
                ),
              ],
            ),
          ),

          const _RefundDivider(),

          Container(
            key: _RefundNavigation.walletKey,
            child: const _RefundSection(
              number: '08',
              title: 'Wallet and account balance refunds',
              children: [
                _RefundParagraph(
                  'Where GiftPay wallet functionality is available, refunds or reversals may be credited back to the applicable wallet balance or returned through another supported method.',
                ),
                _RefundParagraph(
                  'The method used for a refund may depend on the original transaction, payment method, account status and applicable processing requirements.',
                ),
              ],
            ),
          ),

          const _RefundDivider(),

          Container(
            key: _RefundNavigation.timingKey,
            child: const _RefundSection(
              number: '09',
              title: 'Refund processing times',
              children: [
                _RefundParagraph(
                  'Refund and reversal timing can vary depending on the transaction type, payment method, financial institution, service provider and other parties involved in processing the transaction.',
                ),
                _RefundParagraph(
                  'A refund may therefore not appear immediately after approval. Customers should allow reasonable processing time before submitting another request concerning the same transaction.',
                ),
              ],
            ),
          ),

          const _RefundDivider(),

          Container(
            key: _RefundNavigation.requestsKey,
            child: const _RefundSection(
              number: '10',
              title: 'How to request a refund',
              children: [
                _RefundParagraph(
                  'To request a refund or transaction review, contact GiftPay through an official support channel and provide enough information for the transaction to be identified.',
                ),
                _RefundParagraph('Where available, provide:'),
                _RefundBullet(
                  'Your GiftPay account email or other applicable account identifier.',
                ),
                _RefundBullet('The transaction reference or receipt number.'),
                _RefundBullet('The service or product involved.'),
                _RefundBullet('The date and amount of the transaction.'),
                _RefundBullet(
                  'A clear description of what happened and why you believe a refund is required.',
                ),
                _RefundBullet(
                  'Relevant supporting information requested by GiftPay support.',
                ),
              ],
            ),
          ),

          const _RefundDivider(),

          Container(
            key: _RefundNavigation.exceptionsKey,
            child: const _RefundSection(
              number: '11',
              title: 'Exceptions and third-party services',
              children: [
                _RefundParagraph(
                  'Certain GiftPay services are provided, fulfilled or supported by third-party providers. In those cases, refund eligibility may be governed partly by the provider’s own terms, cancellation rules, fulfillment policies or processing requirements.',
                ),
                _RefundParagraph(
                  'GiftPay may assist with communicating or investigating a refund request, but the final outcome may depend on the applicable third-party provider where GiftPay does not control the underlying service.',
                ),
              ],
            ),
          ),

          const _RefundDivider(),

          Container(
            key: _RefundNavigation.contactKey,
            child: const _RefundSection(
              number: '12',
              title: 'Contact GiftPay',
              children: [
                _RefundParagraph(
                  'If you have questions about a refund, reversal or transaction issue, contact GiftPay through the official support channels provided on the GiftPay platform.',
                ),
                _RefundParagraph(
                  'When contacting support, never provide your password, PIN, authentication code or other confidential account credentials.',
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
                Icon(Icons.info_outline_rounded, size: 21, color: blue),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Important: Refund eligibility can vary by service and jurisdiction. This public-facing Refund Policy should be reviewed and finalized by qualified legal counsel and aligned with the specific terms of GiftPay and its service providers before publication as the definitive company policy.',
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
   REFUND COMPONENTS
================================================================ */

class _RefundSection extends StatelessWidget {
  final String number;
  final String title;
  final Widget? child;
  final List<Widget>? children;

  const _RefundSection({
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

class _RefundParagraph extends StatelessWidget {
  final String text;

  const _RefundParagraph(this.text);

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

class _RefundBullet extends StatelessWidget {
  final String text;

  const _RefundBullet(this.text);

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

class _RefundDivider extends StatelessWidget {
  const _RefundDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 30),
      child: Divider(height: 1, color: Color(0xFFE8ECF2)),
    );
  }
}
