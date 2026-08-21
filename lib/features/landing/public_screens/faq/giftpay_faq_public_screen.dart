import 'package:flutter/material.dart';
import 'package:utilityhub/features/landing/public_screens/faq/sections/giftpay_faq_content.dart';
import 'package:utilityhub/features/landing/public_screens/faq/sections/giftpay_faq_navigation.dart';

class GiftPayFaqPublicScreen extends StatefulWidget {
  const GiftPayFaqPublicScreen({super.key});

  @override
  State<GiftPayFaqPublicScreen> createState() => _GiftPayFaqPublicScreenState();
}

class _GiftPayFaqPublicScreenState extends State<GiftPayFaqPublicScreen> {
  static const Color navy = Color(0xFF273D68);
  static const Color blue = Color(0xFF4A6BB8);
  static const Color lightBlue = Color(0xFF75A1FF);

  final ScrollController _scrollController = ScrollController();

  final GlobalKey _faqContentKey = GlobalKey();

  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    final shouldShow = _scrollController.offset > 500;

    if (shouldShow != _showBackToTop) {
      setState(() {
        _showBackToTop = shouldShow;
      });
    }
  }

  void _scrollToSection(GlobalKey key) {
    final targetContext = key.currentContext;

    if (targetContext == null) {
      return;
    }

    Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOutCubic,
      alignment: 0.08,
    );
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < 700;
    final tablet = width >= 700 && width < 1100;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: _FaqHero(mobile: mobile, tablet: tablet),
              ),

              SliverToBoxAdapter(child: SizedBox(height: mobile ? 20 : 30)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: mobile
                        ? 16
                        : tablet
                        ? 28
                        : 42,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1280),
                      child: _FaqLayout(
                        mobile: mobile,
                        tablet: tablet,
                        onSectionTap: _scrollToSection,
                        contentKey: _faqContentKey,
                      ),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: mobile ? 50 : 80)),

              SliverToBoxAdapter(child: _FaqFooter(mobile: mobile)),
            ],
          ),

          if (_showBackToTop)
            Positioned(
              right: mobile ? 16 : 28,
              bottom: mobile ? 18 : 28,
              child: _BackToTopButton(onTap: _scrollToTop),
            ),
        ],
      ),
    );
  }
}

class _FaqHero extends StatelessWidget {
  final bool mobile;
  final bool tablet;

  const _FaqHero({required this.mobile, required this.tablet});

  static const Color navy = Color(0xFF273D68);
  static const Color blue = Color(0xFF4A6BB8);
  static const Color lightBlue = Color(0xFF75A1FF);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        mobile
            ? 18
            : tablet
            ? 30
            : 50,
        mobile ? 42 : 58,
        mobile
            ? 18
            : tablet
            ? 30
            : 50,
        mobile ? 38 : 54,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFF5F8FF)],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              Container(
                width: mobile ? 58 : 68,
                height: mobile ? 58 : 68,
                decoration: BoxDecoration(
                  color: blue.withOpacity(0.09),
                  shape: BoxShape.circle,
                  border: Border.all(color: lightBlue.withOpacity(0.20)),
                  boxShadow: [
                    BoxShadow(
                      color: navy.withOpacity(0.06),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.help_outline_rounded,
                  size: mobile ? 28 : 32,
                  color: blue,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'GIFTpay FAQ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0,
                  color: blue,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Frequently asked questions',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: mobile
                      ? 30
                      : tablet
                      ? 38
                      : 46,
                  height: 1.08,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.0,
                  color: navy,
                ),
              ),

              const SizedBox(height: 14),

              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Text(
                  'Find quick answers about GiftPay, payments, '
                  'gift cards, airtime, bills, travel, your wallet '
                  'and other supported services.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: mobile ? 14 : 16,
                    height: 1.6,
                    color: const Color(0xFF687386),
                  ),
                ),
              ),

              const SizedBox(height: 26),

              _FaqSearchBox(mobile: mobile),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqSearchBox extends StatelessWidget {
  final bool mobile;

  const _FaqSearchBox({required this.mobile});

  static const Color navy = Color(0xFF273D68);
  static const Color blue = Color(0xFF4A6BB8);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 680),
      child: Container(
        height: mobile ? 52 : 58,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(mobile ? 15 : 17),
          border: Border.all(color: const Color(0xFFE0E6F0)),
          boxShadow: [
            BoxShadow(
              color: navy.withOpacity(0.07),
              blurRadius: 26,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: TextField(
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: navy,
          ),
          decoration: InputDecoration(
            hintText: 'Search frequently asked questions...',
            hintStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: Color(0xFF929BAA),
            ),
            prefixIcon: const Icon(Icons.search_rounded, color: blue, size: 22),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      ),
    );
  }
}

class _FaqLayout extends StatelessWidget {
  final bool mobile;
  final bool tablet;
  final void Function(GlobalKey key) onSectionTap;
  final GlobalKey contentKey;

  const _FaqLayout({
    required this.mobile,
    required this.tablet,
    required this.onSectionTap,
    required this.contentKey,
  });

  @override
  Widget build(BuildContext context) {
    if (mobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GiftPayFaqNavigation(mobile: true, onSectionTap: onSectionTap),

          const SizedBox(height: 20),

          GiftPayFaqContent(key: contentKey, onSectionTap: onSectionTap),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: tablet ? 235 : 270,
          child: GiftPayFaqNavigation(
            mobile: false,
            onSectionTap: onSectionTap,
          ),
        ),

        SizedBox(width: tablet ? 24 : 30),

        Expanded(
          child: GiftPayFaqContent(key: contentKey, onSectionTap: onSectionTap),
        ),
      ],
    );
  }
}

class _FaqFooter extends StatelessWidget {
  final bool mobile;

  const _FaqFooter({required this.mobile});

  static const Color navy = Color(0xFF273D68);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: mobile ? 20 : 50,
        vertical: mobile ? 32 : 42,
      ),
      decoration: const BoxDecoration(color: navy),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(
                'Still need help?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: mobile ? 21 : 25,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Our support team is available to help with '
                'account and transaction-specific questions.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: mobile ? 13 : 14,
                  height: 1.55,
                  color: Colors.white.withOpacity(0.72),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.support_agent_rounded, size: 19),
                  label: const Text(
                    'Contact GiftPay Support',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withOpacity(0.30)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackToTopButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackToTopButton({required this.onTap});

  static const Color navy = Color(0xFF273D68);
  static const Color blue = Color(0xFF4A6BB8);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Ink(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: navy,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: blue.withOpacity(0.20),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.keyboard_arrow_up_rounded,
            color: Colors.white,
            size: 25,
          ),
        ),
      ),
    );
  }
}
