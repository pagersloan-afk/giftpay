import 'package:flutter/material.dart';

class GiftCardsFeaturedBrandsSection extends StatelessWidget {
  const GiftCardsFeaturedBrandsSection({super.key});

  static const Color navy = Color(0xFF273D68);
  static const Color blue = Color(0xFF4A6BB8);
  static const Color lightBlue = Color(0xFF75A1FF);

  static const List<_Brand> brands = <_Brand>[
    _Brand(name: 'Apple', assetPath: 'assets/brands/apple.png'),
    _Brand(name: 'Netflix', assetPath: 'assets/brands/netflix.png'),
    _Brand(name: 'Spotify', assetPath: 'assets/brands/spotify.png'),
    _Brand(name: 'Amazon', assetPath: 'assets/brands/amazon.png'),
    _Brand(name: 'PlayStation', assetPath: 'assets/brands/playstation.png'),
    _Brand(name: 'Xbox', assetPath: 'assets/brands/xbox.png'),
  ];

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;

    final bool mobile = width < 700;
    final bool tablet = width >= 700 && width < 1100;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: mobile
            ? 16
            : tablet
            ? 24
            : 32,
        vertical: mobile ? 28 : 38,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(mobile ? 20 : 28),
        border: Border.all(color: const Color(0xFFE5EAF3)),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.06),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 4,
                          decoration: BoxDecoration(
                            color: blue,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'POPULAR BRANDS',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: mobile ? 11 : 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.3,
                            color: blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Featured brands',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: mobile ? 24 : 30,
                        fontWeight: FontWeight.w800,
                        color: navy,
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'Popular digital brands available through GiftPay.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        height: 1.5,
                        color: Color(0xFF687386),
                      ),
                    ),
                  ],
                ),
              ),
              if (!mobile) ...[
                const SizedBox(width: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: blue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.verified_rounded, size: 16, color: blue),
                      SizedBox(width: 6),
                      Text(
                        'Digital delivery',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: navy,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: mobile ? 22 : 30),
          LayoutBuilder(
            builder: (context, constraints) {
              final int columns = mobile
                  ? 2
                  : tablet
                  ? 3
                  : 6;

              final double spacing = mobile ? 12 : 16;

              final double cardWidth =
                  (constraints.maxWidth - ((columns - 1) * spacing)) / columns;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: brands.map((brand) {
                  return SizedBox(
                    width: cardWidth,
                    child: _BrandCard(brand: brand),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Brand {
  final String name;
  final String assetPath;

  const _Brand({required this.name, required this.assetPath});
}

class _BrandCard extends StatefulWidget {
  final _Brand brand;

  const _BrandCard({required this.brand});

  @override
  State<_BrandCard> createState() => _BrandCardState();
}

class _BrandCardState extends State<_BrandCard> {
  static const Color navy = Color(0xFF273D68);
  static const Color blue = Color(0xFF4A6BB8);
  static const Color lightBlue = Color(0xFF75A1FF);

  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (!_hovered) {
          setState(() {
            _hovered = true;
          });
        }
      },
      onExit: (_) {
        if (_hovered) {
          setState(() {
            _hovered = false;
          });
        }
      },
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _hovered
                ? lightBlue.withValues(alpha: 0.45)
                : const Color(0xFFE7EBF2),
          ),
          boxShadow: [
            BoxShadow(
              color: navy.withValues(alpha: _hovered ? 0.10 : 0.045),
              blurRadius: _hovered ? 22 : 14,
              offset: Offset(0, _hovered ? 9 : 5),
            ),
          ],
        ),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1.25,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  widget.brand.assetPath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.card_giftcard_rounded,
                      size: 42,
                      color: blue.withValues(alpha: 0.45),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.brand.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: navy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
