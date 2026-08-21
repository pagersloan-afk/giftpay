import 'dart:ui';

import 'package:flutter/material.dart';

/// Final GiftPay conversion section.
///
/// Purpose:
/// - Give visitors one clear final reason to start using GiftPay.
/// - Reinforce the broader GiftPay ecosystem without making unsupported claims.
/// - Provide primary and secondary conversion actions.
/// - Maintain the luxury GiftPay visual language.
/// - Responsive across desktop, tablet, and mobile.
///
/// Navigation:
/// Update the routes in `_handlePrimaryAction` and `_handleSecondaryAction`
/// if your application uses different route names.
class FinalCtaSection extends StatelessWidget {
  const FinalCtaSection({super.key});

  static const Color _navy = Color(0xFF273D68);
  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _highlight = Color(0xFF7EA4FF);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 760;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 20 : 64,
        isMobile ? 70 : 105,
        isMobile ? 20 : 64,
        isMobile ? 80 : 115,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1420),
          child: _buildPanel(context, isMobile),
        ),
      ),
    );
  }

  Widget _buildPanel(BuildContext context, bool isMobile) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(isMobile ? 28 : 36),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          constraints: const BoxConstraints(minHeight: 390),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isMobile ? 28 : 36),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF314B7D), Color(0xFF273D68), Color(0xFF111C31)],
            ),
            border: Border.all(color: Colors.white.withOpacity(.12)),
            boxShadow: [
              BoxShadow(
                color: _blue.withOpacity(.18),
                blurRadius: 65,
                spreadRadius: -8,
                offset: const Offset(0, 25),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(.22),
                blurRadius: 45,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: _CtaGlowPainter()),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(isMobile ? 25 : 48),
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildContent(context, isMobile),
                          const SizedBox(height: 34),
                          _buildVisual(isMobile),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            flex: 6,
                            child: _buildContent(context, isMobile),
                          ),
                          const SizedBox(width: 50),
                          Expanded(flex: 4, child: _buildVisual(isMobile)),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('GET STARTED'),

        const SizedBox(height: 18),

        Text(
          'Ready to make more\nof your everyday?',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: isMobile ? 34 : 51,
            height: 1.02,
            fontWeight: FontWeight.w800,
            letterSpacing: isMobile ? -1.2 : -2.3,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 16),

        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Text(
            'Start with the services you need today and discover more of '
            'the GiftPay ecosystem as it grows.',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: isMobile ? 14 : 16,
              height: 1.65,
              fontWeight: FontWeight.w300,
              color: Colors.white.withOpacity(.58),
            ),
          ),
        ),

        const SizedBox(height: 27),

        _buildActions(context, isMobile),

        const SizedBox(height: 22),

        Row(
          children: [
            Icon(
              Icons.verified_user_outlined,
              size: 14,
              color: _highlight.withOpacity(.75),
            ),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                'Explore GiftPay and choose the services that fit your needs.',
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 10.5,
                  height: 1.4,
                  color: Colors.white.withOpacity(.34),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, bool isMobile) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _primaryButton(
            context,
            label: 'Get started with GiftPay',
            onTap: () => _handlePrimaryAction(context),
          ),
          const SizedBox(height: 11),
          _secondaryButton(
            context,
            label: 'Explore GiftPay',
            onTap: () => _handleSecondaryAction(context),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _primaryButton(
          context,
          label: 'Get started with GiftPay',
          onTap: () => _handlePrimaryAction(context),
        ),
        const SizedBox(width: 12),
        _secondaryButton(
          context,
          label: 'Explore GiftPay',
          onTap: () => _handleSecondaryAction(context),
        ),
      ],
    );
  }

  Widget _primaryButton(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF7EA4FF), Color(0xFF4A6BB8)],
            ),
            boxShadow: [
              BoxShadow(
                color: _highlight.withOpacity(.20),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Get started with GiftPay',
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(.15),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _secondaryButton(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white.withOpacity(.055),
            border: Border.all(color: Colors.white.withOpacity(.11)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(.82),
                ),
              ),
              const SizedBox(width: 9),
              Icon(
                Icons.arrow_forward_rounded,
                size: 15,
                color: _highlight.withOpacity(.85),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisual(bool isMobile) {
    return SizedBox(
      height: isMobile ? 190 : 285,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: isMobile ? 175 : 245,
            height: isMobile ? 175 : 245,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(.055)),
            ),
          ),

          Container(
            width: isMobile ? 130 : 185,
            height: isMobile ? 130 : 185,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _highlight.withOpacity(.10)),
            ),
          ),

          Container(
            width: isMobile ? 82 : 106,
            height: isMobile ? 82 : 106,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isMobile ? 25 : 31),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white.withOpacity(.13), _blue.withOpacity(.18)],
              ),
              border: Border.all(color: _highlight.withOpacity(.20)),
              boxShadow: [
                BoxShadow(
                  color: _blue.withOpacity(.28),
                  blurRadius: 45,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              size: isMobile ? 34 : 44,
              color: _highlight,
            ),
          ),

          _visualNode(
            icon: Icons.payments_outlined,
            alignment: const Alignment(-.88, -.48),
          ),

          _visualNode(
            icon: Icons.bolt_outlined,
            alignment: const Alignment(.87, -.45),
          ),

          _visualNode(
            icon: Icons.flight_takeoff_rounded,
            alignment: const Alignment(-.72, .70),
          ),

          _visualNode(
            icon: Icons.card_giftcard_outlined,
            alignment: const Alignment(.72, .70),
          ),
        ],
      ),
    );
  }

  Widget _visualNode({required IconData icon, required Alignment alignment}) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withOpacity(.045),
          border: Border.all(color: Colors.white.withOpacity(.09)),
          boxShadow: [BoxShadow(color: _blue.withOpacity(.10), blurRadius: 20)],
        ),
        child: Icon(icon, size: 19, color: Colors.white.withOpacity(.72)),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: _highlight,
          ),
        ),
        const SizedBox(width: 9),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            color: _highlight,
          ),
        ),
      ],
    );
  }

  void _handlePrimaryAction(BuildContext context) {
    // Keep this route aligned with your existing GiftPay onboarding route.
    //
    // If your current route is different, change only this line.
    Navigator.of(context).pushNamed('/giftpay');
  }

  void _handleSecondaryAction(BuildContext context) {
    // Returns the visitor to the top of the GiftPay experience.
    //
    // This avoids introducing another route that may not exist in the
    // existing application.
    final navigator = Navigator.of(context);

    if (navigator.canPop()) {
      navigator.pop();
    }
  }
}

class _CtaGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 65);

    paint.color = const Color(0xFF7EA4FF).withOpacity(.10);

    canvas.drawCircle(Offset(size.width * .82, size.height * .18), 120, paint);

    paint.color = const Color(0xFF4A6BB8).withOpacity(.12);

    canvas.drawCircle(Offset(size.width * .72, size.height * .78), 155, paint);

    paint.color = Colors.white.withOpacity(.025);

    canvas.drawCircle(Offset(size.width * .18, size.height * .82), 90, paint);
  }

  @override
  bool shouldRepaint(covariant _CtaGlowPainter oldDelegate) => false;
}
