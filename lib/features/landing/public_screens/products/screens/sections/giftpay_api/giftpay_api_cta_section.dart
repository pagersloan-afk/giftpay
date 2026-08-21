import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class GiftPayApiCTASection extends StatelessWidget {
  const GiftPayApiCTASection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final bool mobile = width < 760;

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
          colors: [Color(0xFFEAF1FF), Color(0xFFF8FAFF)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD8E3F6)),
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
      children: [
        const Expanded(child: _CTAContent()),
        const SizedBox(width: 30),
        const _CTAButtons(),
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
      children: [_CTAContent(), SizedBox(height: 22), _CTAButtons()],
    );
  }
}

class _CTAContent extends StatelessWidget {
  const _CTAContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ready to build with GiftPay?',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 26,
            height: 1.15,
            fontWeight: FontWeight.w900,
            color: Color(0xFF273D68),
          ),
        ),
        SizedBox(height: 9),
        Text(
          'Explore the developer experience, review the integration '
          'documentation and start building your utility-powered product.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 14,
            height: 1.6,
            color: Color(0xFF687386),
          ),
        ),
      ],
    );
  }
}

class _CTAButtons extends StatelessWidget {
  const _CTAButtons();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final bool mobile = width < 760;

    if (mobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PrimaryButton(
            onPressed: () {
              Navigator.pushNamed(context, '/api-docs');
            },
          ),
          const SizedBox(height: 10),
          _SecondaryButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PrimaryButton(
          onPressed: () {
            Navigator.pushNamed(context, '/api-docs');
          },
        ),
        const SizedBox(width: 10),
        _SecondaryButton(
          onPressed: () {
            Navigator.pushNamed(context, '/login');
          },
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _PrimaryButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.menu_book_rounded, size: 18),
      label: const Text(
        'View API Documentation',
        style: TextStyle(
          fontFamily: 'SegoeUI',
          fontSize: 14,
          fontWeight: FontWeight.w900,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: GiftPayTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 15),
        minimumSize: const Size(0, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SecondaryButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.login_rounded, size: 17),
      label: const Text(
        'Access GiftPay',
        style: TextStyle(
          fontFamily: 'SegoeUI',
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF4A6BB8),
        side: const BorderSide(color: Color(0xFFC8D5ED)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        minimumSize: const Size(0, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
