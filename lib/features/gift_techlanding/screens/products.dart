import 'package:flutter/material.dart';

import 'gifttech_dedicated_page_template.dart';

class GiftTechProductsScreen extends StatelessWidget {
  const GiftTechProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GiftTechDedicatedPageTemplate(
      title: 'Products',
      eyebrow: 'DIGITAL PRODUCTS',
      icon: Icons.grid_view_rounded,
      description:
          'A connected suite of payment, wallet, utility, commerce, and business technologies built for individuals, merchants, developers, and organizations.',
      metaLabel: 'ECOSYSTEM',
      metaValue: 'Gift Technology',
      secondaryMetaLabel: 'PRODUCTS',
      secondaryMetaValue: 'Payments • Wallet • Utilities',
      child: const _ProductsContent(),
    );
  }
}

class _ProductsContent extends StatelessWidget {
  const _ProductsContent();

  @override
  Widget build(BuildContext context) {
    const products = [
      (
        'GiftPay Wallet',
        'Digital wallet services for funding, transfers, withdrawals, utilities, transactions, KYC, and secure account management.',
        Icons.account_balance_wallet_outlined,
      ),
      (
        'GiftPOS',
        'Merchant payment infrastructure with card and transfer acceptance, receipts, transaction history, settlements, staff accounts, and reversal support.',
        Icons.point_of_sale_outlined,
      ),
      (
        'Utilities Hub',
        'A unified destination for electricity, airtime, data, cable TV, and internet subscription services.',
        Icons.bolt_rounded,
      ),
      (
        'GiftCard Marketplace',
        'Digital gift card experiences designed around secure delivery, redemption, and digital commerce.',
        Icons.card_giftcard_rounded,
      ),
      (
        'GiftPay API',
        'REST infrastructure for wallet operations, airtime vending, data vending, electricity vending, and transaction lookup.',
        Icons.api_rounded,
      ),
      (
        'Business Infrastructure',
        'Digital tools supporting merchants, distributors, agents, businesses, and enterprise operations.',
        Icons.business_outlined,
      ),
    ];

    final mobile = MediaQuery.sizeOf(context).width < 720;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: products.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: mobile ? 1 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          mainAxisExtent: 215,
        ),
        itemBuilder: (context, index) {
          final product = products[index];

          return _ProductCard(
            title: product.$1,
            description: product.$2,
            icon: product.$3,
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatefulWidget {
  const _ProductCard({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.identity()..translate(0.0, _hovered ? -3.0 : 0.0),
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: _hovered
              ? Colors.white.withOpacity(0.055)
              : Colors.white.withOpacity(0.032),
          border: Border.all(
            color: _hovered
                ? const Color(0xFF75A1FF).withOpacity(0.18)
                : Colors.white.withOpacity(0.065),
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: const Color(0xFF4A6BB8).withOpacity(0.12),
                    blurRadius: 30,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: const Color(0xFF4A6BB8).withOpacity(0.13),
              ),
              child: Icon(
                widget.icon,
                color: const Color(0xFF75A1FF),
                size: 22,
              ),
            ),
            const SizedBox(height: 17),
            Text(
              widget.title,
              style: const TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                widget.description,
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 12.5,
                  height: 1.6,
                  color: Colors.white.withOpacity(0.49),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
