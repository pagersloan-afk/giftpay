import 'package:flutter/material.dart';

class InfrastructureSection extends StatelessWidget {
  const InfrastructureSection({super.key});

  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _highlight = Color(0xFF7EA4FF);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 700;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 64,
        vertical: isMobile ? 75 : 110,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1420),
          child: Container(
            padding: EdgeInsets.all(isMobile ? 25 : 48),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _blue.withOpacity(0.09),
                  Colors.white.withOpacity(0.025),
                  Colors.transparent,
                ],
              ),
              border: Border.all(color: Colors.white.withOpacity(0.07)),
            ),
            child: isMobile ? _buildMobile() : _buildDesktop(),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktop() {
    return Row(
      children: [
        Expanded(flex: 5, child: _buildIntro()),

        const SizedBox(width: 70),

        Expanded(flex: 5, child: _buildCapabilities()),
      ],
    );
  }

  Widget _buildMobile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIntro(),

        const SizedBox(height: 42),

        _buildCapabilities(),
      ],
    );
  }

  Widget _buildIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('INFRASTRUCTURE'),

        const SizedBox(height: 20),

        const Text(
          'Technology beneath the experience.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 40,
            height: 1.02,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.7,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 20),

        Text(
          'The products people see are powered by systems designed for reliability, security and scale.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 15,
            height: 1.7,
            color: Colors.white.withOpacity(0.45),
          ),
        ),

        const SizedBox(height: 28),

        Row(
          children: [
            _stat('01', 'PAYMENTS'),
            _stat('02', 'APIs'),
            _stat('03', 'SECURITY'),
          ],
        ),
      ],
    );
  }

  Widget _buildCapabilities() {
    const items = [
      (
        Icons.account_balance_outlined,
        'Payment infrastructure',
        'Systems designed to support secure digital transactions.',
      ),
      (
        Icons.api_outlined,
        'Connected APIs',
        'Infrastructure that allows products and partners to connect.',
      ),
      (
        Icons.security_outlined,
        'Security by design',
        'Security considerations embedded throughout the technology stack.',
      ),
      (
        Icons.insights_outlined,
        'Built to scale',
        'Architecture designed to grow alongside users and businesses.',
      ),
    ];

    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 13),
              child: _capability(item.$1, item.$2, item.$3),
            ),
          )
          .toList(),
    );
  }

  Widget _capability(IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        color: Colors.white.withOpacity(0.025),
        border: Border.all(color: Colors.white.withOpacity(0.055)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: _blue.withOpacity(0.09),
            ),
            child: Icon(icon, size: 18, color: _highlight),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 10.5,
                    height: 1.45,
                    color: Colors.white.withOpacity(0.34),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String number, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: const TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _highlight,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 7.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: Colors.white.withOpacity(0.28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'SegoeUI',
        fontSize: 9,
        fontWeight: FontWeight.w800,
        letterSpacing: 2,
        color: _highlight,
      ),
    );
  }
}
