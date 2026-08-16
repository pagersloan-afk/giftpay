import 'dart:ui';

import 'package:flutter/material.dart';

class ProductsSection extends StatefulWidget {
  const ProductsSection({super.key});

  @override
  State<ProductsSection> createState() => _ProductsSectionState();
}

class _ProductsSectionState extends State<ProductsSection> {
  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _highlight = Color(0xFF7EA4FF);

  int _activeIndex = 0;

  final List<_Product> _products = const [
    _Product(
      name: 'GiftPay',
      category: 'DIGITAL PAYMENTS',
      description:
          'A digital payments experience designed around everyday transactions, access and convenience.',
      icon: Icons.account_balance_wallet_outlined,
      route: '/giftpay',
    ),
    _Product(
      name: 'GiftPOS',
      category: 'BUSINESS COMMERCE',
      description:
          'Technology designed to help businesses accept payments and operate more efficiently.',
      icon: Icons.point_of_sale_outlined,
      route: '/giftpos',
    ),
    _Product(
      name: 'Utilities Hub',
      category: 'ESSENTIAL SERVICES',
      description:
          'A connected platform for accessing and managing essential digital utility services.',
      icon: Icons.bolt_outlined,
      route: '/utilities-hub',
    ),
    _Product(
      name: 'GiftCard Marketplace',
      category: 'DIGITAL COMMERCE',
      description:
          'A digital marketplace connecting users with convenient gift card experiences.',
      icon: Icons.card_giftcard_outlined,
      route: '/giftcard-marketplace',
    ),
    _Product(
      name: 'Corporate Data',
      category: 'CONNECTIVITY',
      description:
          'Digital connectivity solutions designed for businesses and modern organizations.',
      icon: Icons.cell_tower_outlined,
      route: '/corporate-data',
    ),
    _Product(
      name: 'Airtime Distribution',
      category: 'DISTRIBUTION',
      description:
          'Infrastructure supporting efficient digital airtime distribution across connected channels.',
      icon: Icons.phone_android_outlined,
      route: '/airtime-distribution',
    ),
  ];

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(isMobile),

              const SizedBox(height: 48),

              if (isMobile) _buildMobileProducts() else _buildDesktopProducts(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _sectionLabel('PRODUCTS'),

              const SizedBox(height: 18),

              Text(
                'Technology with purpose.',
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: isMobile ? 34 : 52,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  letterSpacing: isMobile ? -1.1 : -2.2,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Digital products built for real-world scale.',
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: isMobile ? 16 : 21,
                  fontWeight: FontWeight.w300,
                  color: _highlight.withOpacity(0.82),
                ),
              ),
            ],
          ),
        ),

        if (!isMobile)
          Text(
            'EXPLORE',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.8,
              color: Colors.white.withOpacity(0.25),
            ),
          ),
      ],
    );
  }

  Widget _buildDesktopProducts() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 330,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              _products.length,
              (index) => _buildProductSelector(index),
            ),
          ),
        ),

        const SizedBox(width: 22),

        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: _buildFeaturedProduct(
              _products[_activeIndex],
              key: ValueKey(_activeIndex),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileProducts() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        _products.length,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildMobileProductCard(_products[index], index),
        ),
      ),
    );
  }

  Widget _buildProductSelector(int index) {
    final product = _products[index];
    final selected = _activeIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() => _activeIndex = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: selected
              ? Colors.white.withOpacity(0.055)
              : Colors.transparent,
          border: Border.all(
            color: selected ? _highlight.withOpacity(0.13) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: _blue.withOpacity(selected ? 0.14 : 0.055),
              ),
              child: Icon(
                product.icon,
                size: 18,
                color: selected ? _highlight : Colors.white.withOpacity(0.42),
              ),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Text(
                product.name,
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected
                      ? Colors.white
                      : Colors.white.withOpacity(0.48),
                ),
              ),
            ),

            if (selected)
              const Icon(
                Icons.arrow_forward_rounded,
                size: 15,
                color: _highlight,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedProduct(_Product product, {required Key key}) {
    return ClipRRect(
      key: key,
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 410,
          padding: const EdgeInsets.all(42),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.065),
                Colors.white.withOpacity(0.025),
                _blue.withOpacity(0.055),
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.085)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(19),
                      gradient: LinearGradient(
                        colors: [
                          _blue.withOpacity(0.28),
                          _blue.withOpacity(0.08),
                        ],
                      ),
                      border: Border.all(color: _highlight.withOpacity(0.12)),
                    ),
                    child: Icon(product.icon, color: _highlight, size: 27),
                  ),

                  const Spacer(),

                  Text(
                    '0${_activeIndex + 1}',
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: Colors.white.withOpacity(0.20),
                    ),
                  ),
                ],
              ),

              // -------------------------------------------------------------
              // IMPORTANT:
              // Do NOT use Spacer() here.
              //
              // This section lives inside a SingleChildScrollView, so the
              // vertical constraint is unbounded. A Spacer would therefore
              // request infinite remaining height and cause the RenderFlex
              // exception.
              // -------------------------------------------------------------
              const SizedBox(height: 72),

              Text(
                product.category,
                style: const TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: _highlight,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                product.name,
                style: const TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.7,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 14),

              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Text(
                  product.description,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 14,
                    height: 1.7,
                    color: Colors.white.withOpacity(0.45),
                  ),
                ),
              ),

              const SizedBox(height: 26),

              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(product.route);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Explore product',
                      style: TextStyle(
                        fontFamily: 'SegoeUI',
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(width: 9),

                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: _highlight.withOpacity(0.9),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileProductCard(_Product product, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(product.route);
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.028),
          border: Border.all(color: Colors.white.withOpacity(0.065)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: _blue.withOpacity(0.09),
              ),
              child: Icon(product.icon, size: 19, color: _highlight),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.category,
                    style: const TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 7.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: _highlight,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    product.name,
                    style: const TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: Colors.white.withOpacity(0.25),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
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
}

class _Product {
  final String name;
  final String category;
  final String description;
  final IconData icon;
  final String route;

  const _Product({
    required this.name,
    required this.category,
    required this.description,
    required this.icon,
    required this.route,
  });
}
