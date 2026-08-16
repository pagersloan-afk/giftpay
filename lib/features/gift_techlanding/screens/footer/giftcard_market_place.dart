import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class GiftCardMarketplaceScreen extends StatelessWidget {
  const GiftCardMarketplaceScreen({super.key});

  static const Color _navy = Color(0xFF273D68);
  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _lightBlue = Color(0xFF7EA4FF);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 760;

    return GiftTechPageTemplate(
      title: 'GiftCard Marketplace',
      description:
          'A digital marketplace experience for gift cards, built around convenient delivery and clear transaction handling.',
      eyebrow: 'GIFTPAY • DIGITAL COMMERCE',
      icon: Icons.card_giftcard_rounded,
      metaLabel: 'PRODUCT',
      metaValue: 'GiftCard Marketplace',
      secondaryMetaLabel: 'EXPERIENCE',
      secondaryMetaValue: 'Digital Gift Cards',
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          isMobile ? 16 : 28,
          0,
          isMobile ? 16 : 28,
          30,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _hero(isMobile),
            const SizedBox(height: 22),
            _sectionLabel('MARKETPLACE EXPERIENCE'),
            const SizedBox(height: 12),
            _experienceGrid(isMobile),
            const SizedBox(height: 22),
            _deliverySection(isMobile),
            const SizedBox(height: 22),
            _policySection(isMobile),
            const SizedBox(height: 22),
            _supportSection(isMobile),
          ],
        ),
      ),
    );
  }

  Widget _hero(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 24 : 34),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF273D68), Color(0xFF3A5E9F), Color(0xFF0C1425)],
        ),
        border: Border.all(color: Colors.white.withOpacity(.12)),
        boxShadow: [
          BoxShadow(
            color: _blue.withOpacity(.20),
            blurRadius: 42,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_giftOrb(), const SizedBox(height: 20), _heroCopy()],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _giftOrb(),
                const SizedBox(width: 22),
                Expanded(child: _heroCopy()),
                const SizedBox(width: 24),
                _digitalBadge(),
              ],
            ),
    );
  }

  Widget _giftOrb() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(.075),
        border: Border.all(color: Colors.white.withOpacity(.14)),
        boxShadow: [
          BoxShadow(color: _lightBlue.withOpacity(.20), blurRadius: 32),
        ],
      ),
      child: const Icon(
        Icons.card_giftcard_rounded,
        color: Colors.white,
        size: 34,
      ),
    );
  }

  Widget _heroCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GIFTCARD MARKETPLACE',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.9,
            color: Colors.white.withOpacity(.62),
          ),
        ),
        const SizedBox(height: 9),
        const Text(
          'Give value.\nMake it memorable.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 30,
            height: 1.08,
            fontWeight: FontWeight.w800,
            letterSpacing: -.8,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 11),
        Text(
          'A polished digital experience for gift-card transactions, '
          'with delivery and transaction rules clearly presented from the start.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 13.5,
            height: 1.6,
            color: Colors.white.withOpacity(.62),
          ),
        ),
      ],
    );
  }

  Widget _digitalBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white.withOpacity(.07),
        border: Border.all(color: Colors.white.withOpacity(.13)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt_rounded, size: 15, color: _lightBlue),
          const SizedBox(width: 7),
          Text(
            'DIGITAL DELIVERY',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.25,
              color: Colors.white.withOpacity(.72),
            ),
          ),
        ],
      ),
    );
  }

  Widget _experienceGrid(bool isMobile) {
    const items = [
      _MarketplaceFeature(
        Icons.shopping_bag_outlined,
        'Buy gift cards',
        'Access gift-card purchasing through the GiftPay digital experience.',
      ),
      _MarketplaceFeature(
        Icons.sell_outlined,
        'Sell gift cards',
        'A marketplace experience designed to support gift-card selling.',
      ),
      _MarketplaceFeature(
        Icons.redeem_outlined,
        'Redeem',
        'Use gift cards through the supported redemption experience.',
      ),
      _MarketplaceFeature(
        Icons.mark_email_read_outlined,
        'Digital delivery',
        'Gift cards are delivered digitally once the transaction is completed.',
      ),
      _MarketplaceFeature(
        Icons.receipt_long_outlined,
        'Clear transactions',
        'Keep gift-card activity connected to the wider GiftPay transaction experience.',
      ),
      _MarketplaceFeature(
        Icons.devices_outlined,
        'Digital-first',
        'Designed for a clean, modern experience across supported devices.',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        mainAxisExtent: isMobile ? 118 : 128,
      ),
      itemBuilder: (_, index) => _MarketplaceCard(feature: items[index]),
    );
  }

  Widget _deliverySection(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_blue.withOpacity(.12), Colors.white.withOpacity(.035)],
        ),
        border: Border.all(color: _lightBlue.withOpacity(.10)),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _featureOrb(Icons.local_shipping_outlined),
                const SizedBox(height: 16),
                _deliveryCopy(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _featureOrb(Icons.local_shipping_outlined),
                const SizedBox(width: 18),
                Expanded(child: _deliveryCopy()),
              ],
            ),
    );
  }

  Widget _deliveryCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('DIGITAL DELIVERY'),
        const SizedBox(height: 8),
        const Text(
          'A simple path from purchase to delivery.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Gift cards are treated as digital products. Once a gift card '
          'has been delivered, it is non-refundable under Gift Technology’s '
          'digital product rules.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 12.8,
            height: 1.55,
            color: Colors.white.withOpacity(.51),
          ),
        ),
      ],
    );
  }

  Widget _policySection(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.white.withOpacity(.035),
        border: Border.all(color: Colors.white.withOpacity(.075)),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _policyIcon(),
                const SizedBox(height: 16),
                _policyCopy(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _policyIcon(),
                const SizedBox(width: 18),
                Expanded(child: _policyCopy()),
              ],
            ),
    );
  }

  Widget _policyIcon() {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _blue.withOpacity(.11),
        border: Border.all(color: _lightBlue.withOpacity(.15)),
      ),
      child: const Icon(Icons.verified_outlined, color: _lightBlue, size: 25),
    );
  }

  Widget _policyCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('IMPORTANT PURCHASE RULE'),
        const SizedBox(height: 8),
        const Text(
          'Please review before completing a gift-card transaction.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          'Gift cards are non-refundable once delivered. If a transaction '
          'fails before delivery, eligible refund requests are handled under '
          'Gift Technology’s Returns and Refund Policy.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 12.5,
            height: 1.55,
            color: Colors.white.withOpacity(.50),
          ),
        ),
      ],
    );
  }

  Widget _supportSection(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF101A2D), Color(0xFF1D2E50)],
        ),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _supportTitle(),
                const SizedBox(height: 18),
                _supportDetails(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _supportTitle()),
                const SizedBox(width: 30),
                SizedBox(width: 340, child: _supportDetails()),
              ],
            ),
    );
  }

  Widget _supportTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('GIFTCARD SUPPORT'),
        const SizedBox(height: 8),
        const Text(
          'Need help with a gift-card transaction?',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Gift Technology support can assist with eligible transaction '
          'issues and digital-service failures.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 13,
            height: 1.55,
            color: Colors.white.withOpacity(.50),
          ),
        ),
      ],
    );
  }

  Widget _supportDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _contact(Icons.mail_outline_rounded, 'support@gifttechnologyltd.com'),
        const SizedBox(height: 12),
        _contact(Icons.phone_outlined, '+234 901 085 3849'),
        const SizedBox(height: 12),
        _contact(Icons.location_on_outlined, 'Port Harcourt, Rivers, Nigeria'),
      ],
    );
  }

  Widget _contact(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: _lightBlue),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 12.5,
              height: 1.45,
              color: Colors.white.withOpacity(.58),
            ),
          ),
        ),
      ],
    );
  }

  Widget _featureOrb(IconData icon) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _blue.withOpacity(.12),
        border: Border.all(color: _lightBlue.withOpacity(.15)),
      ),
      child: Icon(icon, color: _lightBlue, size: 25),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'SegoeUI',
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.8,
        color: _lightBlue,
      ),
    );
  }
}

class _MarketplaceFeature {
  final IconData icon;
  final String title;
  final String description;

  const _MarketplaceFeature(this.icon, this.title, this.description);
}

class _MarketplaceCard extends StatefulWidget {
  final _MarketplaceFeature feature;

  const _MarketplaceCard({required this.feature});

  @override
  State<_MarketplaceCard> createState() => _MarketplaceCardState();
}

class _MarketplaceCardState extends State<_MarketplaceCard> {
  bool _hovered = false;

  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _lightBlue = Color(0xFF7EA4FF);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 190),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(21),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(_hovered ? .08 : .05),
              Colors.white.withOpacity(.018),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(_hovered ? .14 : .07),
          ),
          boxShadow: [
            BoxShadow(
              color: _blue.withOpacity(_hovered ? .13 : .035),
              blurRadius: _hovered ? 28 : 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                color: _blue.withOpacity(.11),
                border: Border.all(color: _lightBlue.withOpacity(.14)),
              ),
              child: Icon(widget.feature.icon, size: 21, color: _lightBlue),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.feature.title,
                    style: const TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.feature.description,
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 11.7,
                      height: 1.45,
                      color: Colors.white.withOpacity(.49),
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
