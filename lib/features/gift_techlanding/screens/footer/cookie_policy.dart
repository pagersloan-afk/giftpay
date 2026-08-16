import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class CookiePolicyScreen extends StatelessWidget {
  const CookiePolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GiftTechPageTemplate(
      eyebrow: 'GIFT TECHNOLOGY / PRIVACY',
      title: 'Cookie\nPolicy',
      description:
          'How Gift Technology Ltd uses cookies and similar technologies to provide secure sessions, remember preferences, understand platform performance, and protect our services.',
      icon: Icons.cookie_outlined,
      metaLabel: 'POLICY',
      metaValue: 'Cookies & Tracking',
      secondaryMetaLabel: 'AD TRACKING',
      secondaryMetaValue: 'Not Used',
      child: const _CookiePolicyContent(),
    );
  }
}

class _CookiePolicyContent extends StatelessWidget {
  const _CookiePolicyContent();

  static const Color navy = Color(0xFF273D68);
  static const Color blue = Color(0xFF4A6BB8);
  static const Color accent = Color(0xFF7EA4FF);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 760;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroNotice(isMobile),
          const SizedBox(height: 20),
          _buildCookieOverview(isMobile),
          const SizedBox(height: 20),
          _buildCookieTypes(isMobile),
          const SizedBox(height: 20),
          _buildAuthenticationCookies(),
          const SizedBox(height: 20),
          _buildAnalyticsCookies(),
          const SizedBox(height: 20),
          _buildPreferenceCookies(),
          const SizedBox(height: 20),
          _buildSecurityCookies(),
          const SizedBox(height: 20),
          _buildNoAdvertisingCookies(),
          const SizedBox(height: 20),
          _buildThirdPartyAnalytics(isMobile),
          const SizedBox(height: 20),
          _buildCookieControl(),
          const SizedBox(height: 20),
          _buildContactSection(isMobile),
          const SizedBox(height: 20),
          _buildFinalNotice(),
        ],
      ),
    );
  }

  Widget _buildHeroNotice(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            navy.withOpacity(0.46),
            blue.withOpacity(0.14),
            Colors.white.withOpacity(0.025),
          ],
        ),
        border: Border.all(color: accent.withOpacity(0.13)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [accent.withOpacity(0.20), blue.withOpacity(0.07)],
              ),
              border: Border.all(color: accent.withOpacity(0.16)),
              boxShadow: [
                BoxShadow(color: blue.withOpacity(0.17), blurRadius: 22),
              ],
            ),
            child: const Icon(Icons.cookie_outlined, size: 24, color: accent),
          ),
          const SizedBox(width: 17),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TRANSPARENT BY DESIGN',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.65,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Cookies are used to make our services work better — not to follow you around the web.',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: isMobile ? 18 : 21,
                    fontWeight: FontWeight.w800,
                    height: 1.18,
                    color: Colors.white.withOpacity(0.96),
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  'Gift Technology Ltd uses cookies and similar technologies for authentication, analytics, preferences, and security. We do not use advertising cookies or ad-tracking cookies.',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: isMobile ? 12.5 : 13.5,
                    height: 1.65,
                    color: Colors.white.withOpacity(0.52),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCookieOverview(bool isMobile) {
    const items = [
      _CookieOverviewItem(
        icon: Icons.login_rounded,
        title: 'Authentication',
        text: 'Secure logged-in sessions.',
      ),
      _CookieOverviewItem(
        icon: Icons.analytics_outlined,
        title: 'Analytics',
        text: 'Platform usage and performance.',
      ),
      _CookieOverviewItem(
        icon: Icons.tune_rounded,
        title: 'Preferences',
        text: 'Language, theme and region.',
      ),
      _CookieOverviewItem(
        icon: Icons.security_rounded,
        title: 'Security',
        text: 'CSRF and fraud protection.',
      ),
    ];

    return _sectionPanel(
      eyebrow: 'AT A GLANCE',
      title: 'What cookies do on Gift Technology',
      description:
          'Cookies and similar technologies support the operation, security, personalization, and performance of our digital services.',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isMobile ? 1 : 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 92,
        ),
        itemBuilder: (context, index) {
          return _CookieOverviewCard(item: items[index]);
        },
      ),
    );
  }

  Widget _buildCookieTypes(bool isMobile) {
    const types = [
      _CookieType(
        number: '01',
        title: 'Authentication cookies',
        description:
            'Session tokens used to maintain secure sessions for logged-in users.',
        icon: Icons.login_rounded,
      ),
      _CookieType(
        number: '02',
        title: 'Analytics cookies',
        description:
            'Used with Google Analytics and Firebase Analytics to understand platform usage and performance.',
        icon: Icons.analytics_outlined,
      ),
      _CookieType(
        number: '03',
        title: 'Preference cookies',
        description:
            'Used to remember user preferences such as language, theme, and region.',
        icon: Icons.settings_outlined,
      ),
      _CookieType(
        number: '04',
        title: 'Security cookies',
        description:
            'Used for security functions including CSRF protection and fraud detection.',
        icon: Icons.shield_outlined,
      ),
    ];

    return _sectionPanel(
      eyebrow: '01 / COOKIE TYPES',
      title: 'The technologies we use',
      description:
          'Each category serves a defined operational purpose within the Gift Technology experience.',
      child: Column(
        children: [
          for (int i = 0; i < types.length; i++) ...[
            _CookieTypeCard(item: types[i]),
            if (i != types.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _buildAuthenticationCookies() {
    return _detailPanel(
      eyebrow: '02 / AUTHENTICATION',
      icon: Icons.lock_outline_rounded,
      title: 'Authentication cookies',
      description:
          'Authentication cookies support secure sessions for users who are logged in to Gift Technology services.',
      points: const [
        'Maintain secure logged-in sessions.',
        'Help keep authenticated users connected to the services they are using.',
        'Use session tokens associated with authenticated sessions.',
      ],
    );
  }

  Widget _buildAnalyticsCookies() {
    return _detailPanel(
      eyebrow: '03 / ANALYTICS',
      icon: Icons.insights_outlined,
      title: 'Analytics cookies',
      description:
          'Gift Technology uses analytics technologies to understand how its platforms are used and to improve performance.',
      points: const [
        'Google Analytics is used for usage analytics.',
        'Firebase Analytics is used for usage analytics.',
        'Analytics may help us understand screen views, clicks, and platform performance.',
        'Analytics information supports product and platform improvement.',
      ],
    );
  }

  Widget _buildPreferenceCookies() {
    return _detailPanel(
      eyebrow: '04 / PREFERENCES',
      icon: Icons.tune_rounded,
      title: 'Preference cookies',
      description:
          'Preference technologies help Gift Technology remember selected settings so that the experience remains consistent.',
      points: const [
        'Language preferences.',
        'Theme preferences.',
        'Regional preferences.',
      ],
    );
  }

  Widget _buildSecurityCookies() {
    return _detailPanel(
      eyebrow: '05 / SECURITY',
      icon: Icons.security_outlined,
      title: 'Security cookies',
      description:
          'Security-related technologies support the protection and integrity of Gift Technology services.',
      points: const [
        'CSRF token protection.',
        'Fraud detection support.',
        'Additional security functions required by the platform.',
      ],
    );
  }

  Widget _buildNoAdvertisingCookies() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(23),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white.withOpacity(0.035), blue.withOpacity(0.10)],
        ),
        border: Border.all(color: accent.withOpacity(0.13)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withOpacity(0.08),
              border: Border.all(color: accent.withOpacity(0.12)),
            ),
            child: const Icon(
              Icons.ads_click_outlined,
              color: accent,
              size: 22,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '06 / NO ADVERTISING COOKIES',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.55,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'We do not use advertising cookies.',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Gift Technology Ltd does not use ad-tracking cookies.',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 11.5,
                    height: 1.55,
                    color: Colors.white.withOpacity(0.47),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThirdPartyAnalytics(bool isMobile) {
    return _sectionPanel(
      eyebrow: '07 / ANALYTICS SERVICES',
      title: 'Analytics providers',
      description:
          'Analytics functionality is supported by the following services identified in our current platform configuration.',
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: isMobile ? 1 : 2,
        crossAxisSpacing: 13,
        mainAxisSpacing: 13,
        childAspectRatio: isMobile ? 4.2 : 3.2,
        children: const [
          _ProviderCard(
            icon: Icons.analytics_outlined,
            name: 'Google Analytics',
            description: 'Usage analytics and platform insights.',
          ),
          _ProviderCard(
            icon: Icons.insights_outlined,
            name: 'Firebase Analytics',
            description: 'Usage and performance analytics.',
          ),
        ],
      ),
    );
  }

  Widget _buildCookieControl() {
    return _sectionPanel(
      eyebrow: '08 / CONTROL',
      title: 'How cookies fit into your experience',
      description:
          'The cookies described in this policy serve operational, analytical, preference, or security purposes. They are not used by Gift Technology for advertising or ad tracking.',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          color: Colors.white.withOpacity(0.025),
          border: Border.all(color: Colors.white.withOpacity(0.055)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline_rounded, color: accent, size: 20),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                'Some cookies and similar technologies are necessary for secure authentication and platform functionality. Disabling certain technologies may affect how parts of the service operate.',
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 10.5,
                  height: 1.55,
                  color: Colors.white.withOpacity(0.43),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection(bool isMobile) {
    return _sectionPanel(
      eyebrow: '09 / CONTACT',
      title: 'Questions about cookies or privacy?',
      description:
          'For questions about how Gift Technology handles cookies, analytics, or related privacy matters, contact our support team.',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white.withOpacity(0.025),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _contactItem(
                    Icons.email_outlined,
                    'Email',
                    'support@gifttechnologyltd.com',
                  ),
                  const SizedBox(height: 14),
                  _contactItem(
                    Icons.phone_outlined,
                    'Phone',
                    '+234 901 085 3849',
                  ),
                  const SizedBox(height: 14),
                  _contactItem(
                    Icons.location_on_outlined,
                    'Office',
                    'Port Harcourt, Rivers, Nigeria',
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: _contactItem(
                      Icons.email_outlined,
                      'Email',
                      'support@gifttechnologyltd.com',
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _contactItem(
                      Icons.phone_outlined,
                      'Phone',
                      '+234 901 085 3849',
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _contactItem(
                      Icons.location_on_outlined,
                      'Office',
                      'Port Harcourt, Rivers, Nigeria',
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _contactItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 19, color: accent),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: Colors.white.withOpacity(0.34),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFinalNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.018),
        border: Border.all(color: Colors.white.withOpacity(0.045)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.verified_user_outlined, size: 19, color: accent),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              'Gift Technology Ltd uses cookies and similar technologies for authentication, analytics, preferences, and security. The company does not use advertising or ad-tracking cookies.',
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: 10.5,
                height: 1.55,
                color: Colors.white.withOpacity(0.40),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionPanel({
    required String eyebrow,
    required String title,
    required String description,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withOpacity(0.032),
        border: Border.all(color: Colors.white.withOpacity(0.065)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 26,
            offset: const Offset(0, 13),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: const TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.65,
              color: accent,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 19,
              fontWeight: FontWeight.w800,
              height: 1.2,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            description,
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 11.5,
              height: 1.58,
              color: Colors.white.withOpacity(0.45),
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _detailPanel({
    required String eyebrow,
    required IconData icon,
    required String title,
    required String description,
    required List<String> points,
  }) {
    return _sectionPanel(
      eyebrow: eyebrow,
      title: title,
      description: description,
      child: Column(
        children: [
          for (final point in points) ...[
            _BulletRow(icon: icon, text: point),
            if (point != points.last) const SizedBox(height: 9),
          ],
        ],
      ),
    );
  }
}

class _CookieOverviewItem {
  final IconData icon;
  final String title;
  final String text;

  const _CookieOverviewItem({
    required this.icon,
    required this.title,
    required this.text,
  });
}

class _CookieOverviewCard extends StatelessWidget {
  final _CookieOverviewItem item;

  const _CookieOverviewCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        color: Colors.white.withOpacity(0.025),
        border: Border.all(color: Colors.white.withOpacity(0.055)),
      ),
      child: Row(
        children: [
          Container(
            width: 41,
            height: 41,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFF4A6BB8).withOpacity(0.10),
            ),
            child: Icon(item.icon, size: 19, color: const Color(0xFF7EA4FF)),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.text,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 9.5,
                    color: Colors.white.withOpacity(0.40),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CookieType {
  final String number;
  final String title;
  final String description;
  final IconData icon;

  const _CookieType({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
  });
}

class _CookieTypeCard extends StatelessWidget {
  final _CookieType item;

  const _CookieTypeCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(0.024),
        border: Border.all(color: Colors.white.withOpacity(0.055)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4A6BB8).withOpacity(0.10),
              border: Border.all(
                color: const Color(0xFF7EA4FF).withOpacity(0.09),
              ),
            ),
            child: Text(
              item.number,
              style: const TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF7EA4FF),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              color: const Color(0xFF273D68).withOpacity(0.35),
            ),
            child: Icon(item.icon, size: 18, color: const Color(0xFF7EA4FF)),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  item.description,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 10,
                    height: 1.5,
                    color: Colors.white.withOpacity(0.41),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final IconData icon;
  final String name;
  final String description;

  const _ProviderCard({
    required this.icon,
    required this.name,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        color: Colors.white.withOpacity(0.024),
        border: Border.all(color: Colors.white.withOpacity(0.055)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFF4A6BB8).withOpacity(0.10),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF7EA4FF)),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 9.5,
                    height: 1.45,
                    color: Colors.white.withOpacity(0.40),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BulletRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withOpacity(0.018),
        border: Border.all(color: Colors.white.withOpacity(0.045)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: const Color(0xFF7EA4FF)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: 10.5,
                height: 1.5,
                color: Colors.white.withOpacity(0.46),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
