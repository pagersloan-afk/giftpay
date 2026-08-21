import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class AirtimeCTASection extends StatelessWidget {
  const AirtimeCTASection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [GiftPayTheme.primaryBlue, const Color(0xFF273D68)],
        ),
        boxShadow: [
          BoxShadow(
            color: GiftPayTheme.primaryBlue.withOpacity(0.20),
            blurRadius: 35,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 700;

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _CTAContent(),
                const SizedBox(height: 28),
                _buildButton(context),
              ],
            );
          }

          return Row(
            children: [
              const Expanded(child: _CTAContent()),
              const SizedBox(width: 30),
              _buildButton(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, '/login');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: GiftPayTheme.primaryBlue,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Get Started',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(width: 9),
          Icon(Icons.arrow_forward_rounded, size: 19),
        ],
      ),
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
          'Ready to simplify airtime distribution?',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 27,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Bring your business airtime operations into one '
          'simple GiftPay experience.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 15,
            height: 1.55,
            color: Color(0xFFDCE6FF),
          ),
        ),
      ],
    );
  }
}
