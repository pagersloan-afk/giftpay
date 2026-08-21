import 'package:flutter/material.dart';

class BulkCTASection extends StatelessWidget {
  const BulkCTASection({super.key});

  static const Color navy = Color(0xFF273D68);
  static const Color blue = Color(0xFF4A6BB8);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final bool mobile = width < 700;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: mobile ? 22 : 44,
        vertical: mobile ? 30 : 40,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEEF3FF), Color(0xFFF8FAFF)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDCE5F7)),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.06),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
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
      children: [
        const Expanded(child: _CTAContent()),
        const SizedBox(width: 35),
        const _CTAButton(),
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
          'Ready to simplify utility payments?',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 25,
            height: 1.2,
            fontWeight: FontWeight.w800,
            color: navy,
          ),
        ),
        SizedBox(height: 11),
        Text(
          'Create your GiftPay account and manage your '
          'digital utility needs from one secure platform.',
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

  static const Color navy = Color(0xFF273D68);
  static const Color blue = Color(0xFF4A6BB8);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pushNamed(context, '/login');
        },
        icon: const Icon(Icons.arrow_forward_rounded, size: 19),
        label: const Text(
          'Get Started with GiftPay',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: blue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}
