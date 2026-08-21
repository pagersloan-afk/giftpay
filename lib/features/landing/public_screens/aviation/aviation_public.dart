import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';
import 'package:utilityhub/core/widgets/giftpay_background.dart';

class PublicAviationPage extends StatefulWidget {
  const PublicAviationPage({super.key});

  @override
  State<PublicAviationPage> createState() => _PublicAviationPageState();
}

class _PublicAviationPageState extends State<PublicAviationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  static const Color navy = Color(0xFF273D68);
  static const Color blue = Color(0xFF4A6BB8);
  static const Color lightBlue = Color(0xFF75A1FF);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startSearch() {
    Navigator.of(context).pushNamed('/aviation/search');
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mobile = width < 700;

    return GiftPayBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: navy),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: const Text(
            'GiftPay Flights',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontWeight: FontWeight.w800,
              color: navy,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/login');
                },
                child: const Text(
                  'Sign in',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    color: navy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),

        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: mobile ? 18 : 32,
            vertical: mobile ? 18 : 32,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Column(
                    children: [
                      _buildHero(context, mobile),
                      const SizedBox(height: 28),
                      _buildSearchCard(context, mobile),
                      const SizedBox(height: 32),
                      _buildBenefits(mobile),
                      const SizedBox(height: 36),
                      _buildFooterCta(context, mobile),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context, bool mobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(mobile ? 24 : 46),
      decoration: BoxDecoration(
        color: navy.withOpacity(0.96),
        borderRadius: BorderRadius.circular(mobile ? 24 : 34),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.20),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: mobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroCopy(mobile),
                const SizedBox(height: 30),
                _buildPlaneVisual(mobile),
              ],
            )
          : Row(
              children: [
                Expanded(flex: 6, child: _buildHeroCopy(mobile)),
                const SizedBox(width: 30),
                Expanded(flex: 4, child: _buildPlaneVisual(mobile)),
              ],
            ),
    );
  }

  Widget _buildHeroCopy(bool mobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: const Text(
            'GIFTPAY AVIATION',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: 18),

        Text(
          'Your next journey\nstarts here.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: mobile ? 34 : 52,
            height: 1.05,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 16),

        Text(
          'Search flights, compare available options, and plan your next trip with GiftPay.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: mobile ? 15 : 18,
            height: 1.55,
            color: Colors.white.withOpacity(0.80),
          ),
        ),

        const SizedBox(height: 24),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: const [
            _TrustPill(
              icon: Icons.flight_takeoff_rounded,
              label: 'Flight search',
            ),
            _TrustPill(
              icon: Icons.compare_arrows_rounded,
              label: 'Compare options',
            ),
            _TrustPill(icon: Icons.lock_rounded, label: 'Secure booking'),
          ],
        ),
      ],
    );
  }

  Widget _buildPlaneVisual(bool mobile) {
    return Container(
      height: mobile ? 190 : 260,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [blue.withOpacity(0.30), lightBlue.withOpacity(0.08)],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -45,
            right: -45,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: lightBlue.withOpacity(0.10),
              ),
            ),
          ),
          Positioned(
            bottom: -55,
            left: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Center(
            child: Transform.rotate(
              angle: -0.18,
              child: Icon(
                Icons.flight_rounded,
                size: mobile ? 92 : 125,
                color: Colors.white.withOpacity(0.92),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchCard(BuildContext context, bool mobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(mobile ? 20 : 28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(mobile ? 22 : 28),
        border: Border.all(color: const Color(0xFFE4E9F2)),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Find your flight',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: navy,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            'Search available flights and continue when you find the right option.',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 14,
              height: 1.5,
              color: navy.withOpacity(0.62),
            ),
          ),

          const SizedBox(height: 22),

          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 650) {
                return Column(
                  children: [
                    _buildSearchOption(
                      icon: Icons.flight_takeoff_rounded,
                      label: 'From',
                      value: 'Lagos (LOS)',
                    ),
                    const SizedBox(height: 12),
                    _buildSearchOption(
                      icon: Icons.flight_land_rounded,
                      label: 'To',
                      value: 'Abuja (ABV)',
                    ),
                    const SizedBox(height: 12),
                    _buildSearchOption(
                      icon: Icons.calendar_month_rounded,
                      label: 'Departure',
                      value: 'Select date',
                    ),
                    const SizedBox(height: 18),
                    _buildSearchButton(context),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _buildSearchOption(
                      icon: Icons.flight_takeoff_rounded,
                      label: 'From',
                      value: 'Lagos (LOS)',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSearchOption(
                      icon: Icons.flight_land_rounded,
                      label: 'To',
                      value: 'Abuja (ABV)',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSearchOption(
                      icon: Icons.calendar_month_rounded,
                      label: 'Departure',
                      value: 'Select date',
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(height: 62, child: _buildSearchButton(context)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchOption({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE1E6EF)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: blue.withOpacity(0.10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 19, color: blue),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: navy.withOpacity(0.48),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: navy,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _startSearch,
      icon: const Icon(Icons.search_rounded, size: 19),
      label: const Text(
        'Search flights',
        style: TextStyle(fontFamily: 'SegoeUI', fontWeight: FontWeight.w800),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: blue,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  Widget _buildBenefits(bool mobile) {
    final benefits = [
      (
        Icons.search_rounded,
        'Search',
        'Explore available flight options from supported routes.',
      ),
      (
        Icons.compare_rounded,
        'Compare',
        'Review flight options before choosing your journey.',
      ),
      (
        Icons.verified_user_rounded,
        'Book securely',
        'Authenticated users can continue through GiftPay checkout.',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 650;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: benefits.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: twoColumns ? 3 : 1,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            mainAxisExtent: 150,
          ),
          itemBuilder: (context, index) {
            final item = benefits[index];

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.94),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE3E8F1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(item.$1, color: blue, size: 25),
                  const SizedBox(height: 12),
                  Text(
                    item.$2,
                    style: const TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: navy,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.$3,
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 12.5,
                      height: 1.45,
                      color: navy.withOpacity(0.58),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFooterCta(BuildContext context, bool mobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(mobile ? 22 : 30),
      decoration: BoxDecoration(
        color: navy,
        borderRadius: BorderRadius.circular(24),
      ),
      child: mobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ctaCopy(),
                const SizedBox(height: 18),
                _ctaButton(context),
              ],
            )
          : Row(
              children: [
                Expanded(child: _ctaCopy()),
                const SizedBox(width: 20),
                _ctaButton(context),
              ],
            ),
    );
  }

  Widget _ctaCopy() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ready to take off?',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 7),
        Text(
          'Search flights or sign in to continue with your booking.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 14,
            height: 1.5,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _ctaButton(BuildContext context) {
    return ElevatedButton(
      onPressed: _startSearch,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: navy,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: const Text(
        'Explore flights',
        style: TextStyle(fontFamily: 'SegoeUI', fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _TrustPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TrustPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.09),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.13)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
