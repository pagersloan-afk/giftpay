import 'package:flutter/material.dart';

import 'package:utilityhub/features/landing/widgets/landing_header.dart';
import 'package:utilityhub/features/landing/sections/landing_footer.dart';
import 'package:utilityhub/features/landing/widgets/landing_responsive_layout.dart';

import 'section/giftpay_help_hero.dart';
import 'section/giftpay_help_navigation.dart';
import 'section/giftpay_help_content.dart';

class GiftPayHelpPage extends StatefulWidget {
  const GiftPayHelpPage({super.key});

  @override
  State<GiftPayHelpPage> createState() => _GiftPayHelpPageState();
}

class _GiftPayHelpPageState extends State<GiftPayHelpPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;

    if (context == null) return;

    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < 700;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: const LandingHeader(),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Stack(
          children: [
            const Positioned.fill(
              child: IgnorePointer(child: _HelpBackground()),
            ),

            LandingResponsiveLayout(
              child: Column(
                children: [
                  SizedBox(height: mobile ? 16 : 24),

                  const GiftPayHelpHero(),

                  SizedBox(height: mobile ? 18 : 28),

                  GiftPayHelpNavigation(
                    mobile: mobile,
                    onSectionTap: _scrollToSection,
                  ),

                  SizedBox(height: mobile ? 18 : 28),

                  GiftPayHelpContent(onSectionTap: _scrollToSection),

                  SizedBox(height: mobile ? 32 : 48),

                  const LandingFooter(),

                  SizedBox(height: mobile ? 16 : 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpBackground extends StatelessWidget {
  const _HelpBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _HelpBackgroundPainter());
  }
}

class _HelpBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final navy = const Color(0xFF273D68);
    final blue = const Color(0xFF4A6BB8);

    final paintOne = Paint()
      ..color = blue.withOpacity(0.045)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);

    final paintTwo = Paint()
      ..color = navy.withOpacity(0.035)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 90);

    canvas.drawCircle(
      Offset(size.width * 0.08, size.height * 0.10),
      180,
      paintOne,
    );

    canvas.drawCircle(
      Offset(size.width * 0.92, size.height * 0.42),
      220,
      paintTwo,
    );

    canvas.drawCircle(
      Offset(size.width * 0.35, size.height * 0.86),
      170,
      paintOne,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
