import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class GiftPayWalletCTASection extends StatelessWidget {
  const GiftPayWalletCTASection({super.key});

  static const Color navy = Color(0xFF273D68);
  static const Color blue = Color(0xFF4A6BB8);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final bool mobile = width < 700;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: mobile ? 22 : 42,
        vertical: mobile ? 28 : 34,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEEF3FF), Color(0xFFF8FAFF)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDCE5F7)),
      ),
      child: mobile ? const _MobileCTA() : const _DesktopCTA(),
    );
  }
}

class _DesktopCTA extends StatelessWidget {
  const _DesktopCTA();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        Expanded(child: _CTAContent()),
        SizedBox(width: 32),
        _CTAButton(),
      ],
    );
  }
}

class _MobileCTA extends StatelessWidget {
  const _MobileCTA();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_CTAContent(), SizedBox(height: 24), _CTAButton()],
    );
  }
}

class _CTAContent extends StatelessWidget {
  const _CTAContent();

  static const Color navy = Color(0xFF273D68);

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ready to make payments simpler?',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 25,
            height: 1.2,
            fontWeight: FontWeight.w800,
            color: navy,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Create your GiftPay account and keep your supported '
          'digital payments together in one convenient wallet.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 14,
            height: 1.55,
            color: Color(0xFF687386),
          ),
        ),
      ],
    );
  }
}

class _CTAButton extends StatelessWidget {
  const _CTAButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.pushNamed(context, '/login');
      },
      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
      label: const Text(
        'Open GiftPay',
        style: TextStyle(
          fontFamily: 'SegoeUI',
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: GiftPayTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}
