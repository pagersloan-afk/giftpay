import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

/// Premium Terms of Sale screen for Gift Technology Ltd.
///
/// The supplied source describes this page as covering:
/// "the terms governing purchases, subscriptions, and transactions."
///
/// The screen therefore focuses on a high-end commerce/legal presentation
/// without inventing fees, refund rules, billing cycles, warranties, or
/// regulatory obligations that are not present in the supplied source.
class TermsOfSaleScreen extends StatelessWidget {
  const TermsOfSaleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GiftTechPageTemplate(
      title: 'Terms of Sale',
      description:
          'Understand the terms governing purchases, subscriptions, and transactions.',
      child: const _TermsOfSaleContent(),
    );
  }
}

class _TermsOfSaleContent extends StatelessWidget {
  const _TermsOfSaleContent();

  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _electricBlue = Color(0xFF5D8FFF);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 700;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 28,
        vertical: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCommerceBanner(isMobile),
          const SizedBox(height: 20),
          _buildSaleCards(isMobile),
          const SizedBox(height: 20),
          _buildTransactionPanel(isMobile),
        ],
      ),
    );
  }

  Widget _buildCommerceBanner(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.085),
            _blue.withOpacity(0.055),
            Colors.white.withOpacity(0.025),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.11)),
        boxShadow: [
          BoxShadow(
            color: _blue.withOpacity(0.09),
            blurRadius: 40,
            spreadRadius: 2,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildCommerceOrb(),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GIFT TECHNOLOGY / COMMERCE',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                    color: _electricBlue.withOpacity(0.95),
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  'Terms of Sale',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: isMobile ? 24 : 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.7,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  'A clear framework for purchases, subscriptions, and transactions across the Gift Technology ecosystem.',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: isMobile ? 13 : 14,
                    height: 1.55,
                    color: Colors.white.withOpacity(0.60),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommerceOrb() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white.withOpacity(0.13), _blue.withOpacity(0.13)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: [BoxShadow(color: _blue.withOpacity(0.15), blurRadius: 25)],
      ),
      child: const Icon(
        Icons.shopping_bag_outlined,
        color: _electricBlue,
        size: 25,
      ),
    );
  }

  Widget _buildSaleCards(bool isMobile) {
    const cards = [
      (
        number: '01',
        title: 'Purchases',
        text:
            'Terms and information relevant to purchases made through Gift Technology platforms.',
        icon: Icons.shopping_cart_outlined,
      ),
      (
        number: '02',
        title: 'Subscriptions',
        text:
            'A dedicated place for the conditions applicable to subscription-based services.',
        icon: Icons.autorenew_rounded,
      ),
      (
        number: '03',
        title: 'Transactions',
        text:
            'The framework governing transactions carried out through supported platforms.',
        icon: Icons.swap_horiz_rounded,
      ),
      (
        number: '04',
        title: 'Customer Information',
        text:
            'Important information to review before completing a purchase or transaction.',
        icon: Icons.receipt_long_outlined,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: isMobile ? 142 : 154,
      ),
      itemBuilder: (context, index) {
        final card = cards[index];

        return _SaleCard(
          number: card.number,
          title: card.title,
          text: card.text,
          icon: card.icon,
        );
      },
    );
  }

  Widget _buildTransactionPanel(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withOpacity(0.045),
        border: Border.all(color: Colors.white.withOpacity(0.085)),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTransactionIcon(),
                const SizedBox(height: 16),
                _buildTransactionCopy(),
              ],
            )
          : Row(
              children: [
                _buildTransactionIcon(),
                const SizedBox(width: 18),
                Expanded(child: _buildTransactionCopy()),
                const SizedBox(width: 20),
                _buildArrow(),
              ],
            ),
    );
  }

  Widget _buildTransactionIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _blue.withOpacity(0.10),
        border: Border.all(color: _blue.withOpacity(0.18)),
      ),
      child: const Icon(
        Icons.verified_outlined,
        color: _electricBlue,
        size: 21,
      ),
    );
  }

  Widget _buildTransactionCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Before you transact',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Review the applicable Terms of Sale carefully before completing a purchase, '
          'starting a subscription, or proceeding with a transaction.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 13,
            height: 1.55,
            color: Colors.white.withOpacity(0.55),
          ),
        ),
      ],
    );
  }

  Widget _buildArrow() {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _blue.withOpacity(0.08),
        border: Border.all(color: _blue.withOpacity(0.13)),
      ),
      child: const Icon(
        Icons.arrow_forward_rounded,
        color: _electricBlue,
        size: 18,
      ),
    );
  }
}

class _SaleCard extends StatefulWidget {
  final String number;
  final String title;
  final String text;
  final IconData icon;

  const _SaleCard({
    required this.number,
    required this.title,
    required this.text,
    required this.icon,
  });

  @override
  State<_SaleCard> createState() => _SaleCardState();
}

class _SaleCardState extends State<_SaleCard> {
  bool _hovered = false;

  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _electricBlue = Color(0xFF5D8FFF);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(_hovered ? 0.085 : 0.065),
              Colors.white.withOpacity(0.025),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(_hovered ? 0.15 : 0.085),
          ),
          boxShadow: [
            BoxShadow(
              color: _blue.withOpacity(_hovered ? 0.14 : 0.055),
              blurRadius: _hovered ? 30 : 20,
              offset: const Offset(0, 12),
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
                borderRadius: BorderRadius.circular(14),
                color: _blue.withOpacity(0.10),
                border: Border.all(color: _blue.withOpacity(0.16)),
              ),
              child: Icon(widget.icon, size: 20, color: _electricBlue),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.number,
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: _electricBlue.withOpacity(0.75),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 12.5,
                      height: 1.45,
                      color: Colors.white.withOpacity(0.50),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
