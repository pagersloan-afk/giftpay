import 'dart:ui';

import 'package:flutter/material.dart';

class ContactHeroSection extends StatelessWidget {
  const ContactHeroSection({super.key});

  static const Color _navy = Color(0xFF273D68);
  static const Color _blue = Color(0xFF4A6BB8);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final bool isMobile = width < 760;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 22 : 48,
        vertical: isMobile ? 55 : 78,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_navy, _blue, Color(0xFF6D8DD1)],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(isMobile ? 26 : 44),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white.withOpacity(0.18)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 40,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: isMobile
                    ? const _MobileHeroContent()
                    : const _DesktopHeroContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopHeroContent extends StatelessWidget {
  const _DesktopHeroContent();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.12),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
          ),
          child: const Icon(
            Icons.support_agent_rounded,
            color: Colors.white,
            size: 34,
          ),
        ),

        const SizedBox(width: 26),

        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Eyebrow(),

              SizedBox(height: 12),

              Text(
                'Let’s talk.',
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 58,
                  height: 1.0,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -2,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: 16),

              Text(
                'Whether you need support, want to explore a partnership, '
                'or simply want to learn more about GiftPay, our team is ready to help.',
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 17,
                  height: 1.65,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MobileHeroContent extends StatelessWidget {
  const _MobileHeroContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Eyebrow(),

        SizedBox(height: 16),

        Icon(Icons.support_agent_rounded, color: Colors.white, size: 42),

        SizedBox(height: 20),

        Text(
          'Let’s talk.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 42,
            height: 1.0,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.4,
            color: Colors.white,
          ),
        ),

        SizedBox(height: 16),

        Text(
          'Whether you need support, want to explore a partnership, '
          'or simply want to learn more about GiftPay, our team is ready to help.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 15,
            height: 1.6,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 9),
        const Text(
          'GIFT TECHNOLOGY / CONTACT',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
