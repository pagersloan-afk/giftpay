import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class GiftCardsCategoriesSection extends StatelessWidget {
  const GiftCardsCategoriesSection({super.key});

  static const Color navy = Color(0xFF273D68);
  static const Color blue = Color(0xFF4A6BB8);
  static const Color lightBlue = Color(0xFF75A1FF);
  static const Color surface = Color(0xFFF8FAFE);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final bool mobile = width < 700;
    final bool tablet = width >= 700 && width < 1100;

    final categories = <_GiftCardCategory>[
      const _GiftCardCategory(
        title: 'Airtime & Data',
        description: 'Top up mobile services and stay connected instantly.',
        imagePath: 'assets/icons/catalog-airtime.png',
        route: '/giftcards/airtime',
        icon: Icons.phone_android_rounded,
      ),
      const _GiftCardCategory(
        title: 'Shopping',
        description:
            'Digital value for everyday shopping and lifestyle brands.',
        imagePath: 'assets/icons/catalog-shopping.png',
        route: '/giftcards/shopping',
        icon: Icons.shopping_bag_rounded,
      ),
      const _GiftCardCategory(
        title: 'Entertainment',
        description: 'Give access to streaming, music and digital experiences.',
        imagePath: 'assets/icons/catalog-entertainment.png',
        route: '/giftcards/entertainment',
        icon: Icons.movie_creation_rounded,
      ),
      const _GiftCardCategory(
        title: 'Gaming',
        description: 'Power gaming accounts, platforms and digital purchases.',
        imagePath: 'assets/icons/catalog-gaming.png',
        route: '/giftcards/gaming',
        icon: Icons.sports_esports_rounded,
      ),
    ];

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
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(mobile ? 20 : 28),
        border: Border.all(color: const Color(0xFFE5EAF3)),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.07),
            blurRadius: 35,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading(
            eyebrow: 'GIFT CARDS',
            title: 'Choose your category',
            description:
                'Explore digital gift cards across the experiences people use every day.',
            mobile: mobile,
          ),
          SizedBox(height: mobile ? 22 : 30),
          _buildGrid(context, categories, mobile: mobile, tablet: tablet),
        ],
      ),
    );
  }

  Widget _buildGrid(
    BuildContext context,
    List<_GiftCardCategory> categories, {
    required bool mobile,
    required bool tablet,
  }) {
    if (mobile) {
      return Column(
        children: [
          for (int i = 0; i < categories.length; i++) ...[
            _CategoryCard(category: categories[i]),
            if (i != categories.length - 1) const SizedBox(height: 14),
          ],
        ],
      );
    }

    final int columns = tablet ? 2 : 4;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double spacing = tablet ? 16 : 20;
        final double cardWidth =
            (constraints.maxWidth - ((columns - 1) * spacing)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: categories.map((category) {
            return SizedBox(
              width: cardWidth,
              child: _CategoryCard(category: category),
            );
          }).toList(),
        );
      },
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String description;
  final bool mobile;

  const _SectionHeading({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.mobile,
  });

  static const Color navy = Color(0xFF273D68);
  static const Color blue = Color(0xFF4A6BB8);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 4,
              decoration: BoxDecoration(
                color: blue,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              eyebrow,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: mobile ? 11 : 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                color: blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: mobile ? 24 : 30,
            height: 1.15,
            fontWeight: FontWeight.w800,
            color: navy,
          ),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Text(
            description,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: mobile ? 13 : 15,
              height: 1.55,
              color: const Color(0xFF687386),
            ),
          ),
        ),
      ],
    );
  }
}

class _GiftCardCategory {
  final String title;
  final String description;
  final String imagePath;
  final String route;
  final IconData icon;

  const _GiftCardCategory({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.route,
    required this.icon,
  });
}

class _CategoryCard extends StatefulWidget {
  final _GiftCardCategory category;

  const _CategoryCard({required this.category});

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _hovered = false;

  static const Color navy = Color(0xFF273D68);
  static const Color blue = Color(0xFF4A6BB8);
  static const Color lightBlue = Color(0xFF75A1FF);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final bool mobile = width < 700;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(
          0,
          _hovered && !mobile ? -5 : 0,
          0,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _hovered
                ? lightBlue.withOpacity(0.55)
                : const Color(0xFFE5EAF3),
          ),
          boxShadow: [
            BoxShadow(
              color: navy.withOpacity(_hovered ? 0.12 : 0.055),
              blurRadius: _hovered ? 28 : 18,
              offset: Offset(0, _hovered ? 12 : 7),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.pushNamed(context, widget.category.route),
          child: Padding(
            padding: EdgeInsets.all(mobile ? 18 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: blue.withOpacity(0.09),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(widget.category.icon, color: blue, size: 22),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_outward_rounded,
                      size: 19,
                      color: _hovered ? blue : const Color(0xFF9AA4B5),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: mobile ? 105 : 125,
                  width: double.infinity,
                  child: Image.asset(
                    widget.category.imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        widget.category.icon,
                        size: 58,
                        color: blue.withOpacity(0.45),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.category.title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: navy,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  widget.category.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    height: 1.5,
                    color: Color(0xFF687386),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, widget.category.route),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GiftPayTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: const Text(
                      'Explore category',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
