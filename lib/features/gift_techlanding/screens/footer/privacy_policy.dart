import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GiftTechPageTemplate(
      eyebrow: 'GIFT TECHNOLOGY / PRIVACY',
      title: 'Privacy\nPolicy',
      description:
          'How Gift Technology Ltd collects, uses, stores, protects, and manages personal information across the Gift Technology ecosystem.',
      icon: Icons.privacy_tip_outlined,
      metaLabel: 'POLICY',
      metaValue: 'Privacy & Data',
      secondaryMetaLabel: 'CONTACT',
      secondaryMetaValue: 'support@gifttechnologyltd.com',
      child: const _PrivacyPolicyContent(),
    );
  }
}

class _PrivacyPolicyContent extends StatelessWidget {
  const _PrivacyPolicyContent();

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
          _buildPrivacyIntroduction(isMobile),
          const SizedBox(height: 20),

          _buildQuickOverview(isMobile),
          const SizedBox(height: 20),

          _buildInformationCollection(isMobile),
          const SizedBox(height: 20),

          _buildInformationUse(isMobile),
          const SizedBox(height: 20),

          _buildRetention(isMobile),
          const SizedBox(height: 20),

          _buildThirdPartyProcessors(isMobile),
          const SizedBox(height: 20),

          _buildCookies(isMobile),
          const SizedBox(height: 20),

          _buildAccountDeletion(isMobile),
          const SizedBox(height: 20),

          _buildSecuritySection(isMobile),
          const SizedBox(height: 20),

          _buildContactSection(isMobile),
          const SizedBox(height: 20),

          _buildFinalNotice(),
        ],
      ),
    );
  }

  Widget _buildPrivacyIntroduction(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            navy.withOpacity(0.42),
            blue.withOpacity(0.12),
            Colors.white.withOpacity(0.025),
          ],
        ),
        border: Border.all(color: accent.withOpacity(0.13)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [accent.withOpacity(0.20), blue.withOpacity(0.07)],
              ),
              border: Border.all(color: accent.withOpacity(0.16)),
              boxShadow: [
                BoxShadow(color: blue.withOpacity(0.16), blurRadius: 22),
              ],
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              size: 23,
              color: accent,
            ),
          ),
          const SizedBox(width: 17),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'YOUR DATA. OUR RESPONSIBILITY.',
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
                  'Privacy is built into the way we operate.',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: isMobile ? 18 : 21,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    color: Colors.white.withOpacity(0.96),
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  'Gift Technology Ltd handles personal information across payments, utilities, wallet services, business operations, and other digital experiences with security, operational integrity, and responsible data handling in mind.',
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

  Widget _buildQuickOverview(bool isMobile) {
    const items = [
      _OverviewItem(
        icon: Icons.person_outline_rounded,
        title: 'Personal Data',
        text: 'Account and KYC information.',
      ),
      _OverviewItem(
        icon: Icons.receipt_long_outlined,
        title: 'Transactions',
        text: 'Payment and service activity.',
      ),
      _OverviewItem(
        icon: Icons.devices_other_rounded,
        title: 'Device Data',
        text: 'Device and platform information.',
      ),
      _OverviewItem(
        icon: Icons.analytics_outlined,
        title: 'Analytics',
        text: 'Usage and performance information.',
      ),
    ];

    return _sectionPanel(
      eyebrow: 'AT A GLANCE',
      title: 'What this policy covers',
      description:
          'This policy explains the principal categories of information Gift Technology collects and how that information is managed across its digital ecosystem.',
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
          return _OverviewCard(item: items[index]);
        },
      ),
    );
  }

  Widget _buildInformationCollection(bool isMobile) {
    const items = [
      _DataItem(
        icon: Icons.badge_outlined,
        title: 'Identity & Contact',
        description:
            'Full name, email address, phone number, and date of birth.',
      ),
      _DataItem(
        icon: Icons.home_work_outlined,
        title: 'Residential Information',
        description:
            'Residential address information required for applicable KYC processes.',
      ),
      _DataItem(
        icon: Icons.verified_user_outlined,
        title: 'KYC Information',
        description:
            'BVN may be collected when required for identity verification and KYC.',
      ),
      _DataItem(
        icon: Icons.account_balance_wallet_outlined,
        title: 'Transaction History',
        description:
            'Airtime, data, electricity, wallet transfers, POS transactions, and related transaction activity.',
      ),
      _DataItem(
        icon: Icons.devices_outlined,
        title: 'Device Information',
        description:
            'Device model, operating system version, IP address, and related technical information.',
      ),
      _DataItem(
        icon: Icons.insights_outlined,
        title: 'Usage Analytics',
        description:
            'Screen views, clicks, performance logs, and other platform usage analytics.',
      ),
      _DataItem(
        icon: Icons.payment_outlined,
        title: 'Payment Metadata',
        description:
            'Payment references, gateway responses, timestamps, and related payment metadata.',
      ),
    ];

    return _sectionPanel(
      eyebrow: '01 / INFORMATION',
      title: 'Information we collect',
      description:
          'The information collected depends on the products, services, transactions, and verification processes you use.',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isMobile ? 1 : 2,
          crossAxisSpacing: 13,
          mainAxisSpacing: 13,
          mainAxisExtent: 128,
        ),
        itemBuilder: (context, index) {
          return _DataCard(item: items[index]);
        },
      ),
    );
  }

  Widget _buildInformationUse(bool isMobile) {
    const items = <_DataItem>[
      _DataItem(
        icon: Icons.settings_suggest_outlined,
        title: 'Operate our services',
        description:
            'Information is used to provide and maintain Gift Technology products and services.',
      ),
      _DataItem(
        icon: Icons.account_balance_wallet_outlined,
        title: 'Process transactions',
        description:
            'Transaction and payment information supports wallet, utility, payment, and business activity.',
      ),
      _DataItem(
        icon: Icons.verified_outlined,
        title: 'Complete KYC',
        description:
            'Applicable identity information is used for verification and KYC requirements.',
      ),
      _DataItem(
        icon: Icons.support_agent_outlined,
        title: 'Provide support',
        description:
            'Information helps us investigate requests, resolve service issues, and respond to support tickets.',
      ),
      _DataItem(
        icon: Icons.speed_outlined,
        title: 'Improve performance',
        description:
            'Usage analytics and performance information help us understand and improve our platforms.',
      ),
      _DataItem(
        icon: Icons.security_outlined,
        title: 'Protect our ecosystem',
        description:
            'Technical and security information supports platform security, fraud detection, and service protection.',
      ),
    ];

    return _sectionPanel(
      eyebrow: '02 / USE',
      title: 'How we use information',
      description:
          'Information is used to deliver services, process activity, maintain secure systems, support customers, and improve the Gift Technology experience.',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isMobile ? 1 : 2,
          crossAxisSpacing: 13,
          mainAxisSpacing: 13,
          mainAxisExtent: 126,
        ),
        itemBuilder: (context, index) {
          return _DataCard(item: items[index]);
        },
      ),
    );
  }

  Widget _buildRetention(bool isMobile) {
    const items = [
      _RetentionItem(
        period: 'ACTIVE',
        title: 'KYC information',
        description:
            'Retained for as long as the account remains active, as required by applicable Nigerian financial regulations.',
        icon: Icons.verified_user_outlined,
      ),
      _RetentionItem(
        period: '5+ YEARS',
        title: 'Transaction data',
        description:
            'Transaction information is retained for a minimum of five years for audit and compliance purposes.',
        icon: Icons.receipt_long_outlined,
      ),
      _RetentionItem(
        period: '12–24 MONTHS',
        title: 'Analytics data',
        description:
            'Usage and analytics information is retained for approximately 12 to 24 months.',
        icon: Icons.analytics_outlined,
      ),
      _RetentionItem(
        period: '12 MONTHS',
        title: 'Support tickets',
        description:
            'Support ticket information is retained for approximately 12 months.',
        icon: Icons.support_agent_outlined,
      ),
      _RetentionItem(
        period: '30 DAYS',
        title: 'Deleted accounts',
        description:
            'Personal data associated with deleted accounts is anonymized within 30 days, while required regulatory transaction data is retained.',
        icon: Icons.delete_sweep_outlined,
      ),
    ];

    return _sectionPanel(
      eyebrow: '03 / RETENTION',
      title: 'How long information is retained',
      description:
          'Retention periods vary according to the type of information and the operational, audit, compliance, and regulatory requirements that apply to it.',
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _RetentionCard(item: items[i]),
            if (i != items.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _buildThirdPartyProcessors(bool isMobile) {
    const processors = [
      _ProcessorItem(
        name: 'Firebase',
        purpose: 'Authentication and push notifications.',
        icon: Icons.fingerprint_rounded,
      ),
      _ProcessorItem(
        name: 'Supabase',
        purpose: 'Database and API services.',
        icon: Icons.storage_outlined,
      ),
      _ProcessorItem(
        name: 'Monnify',
        purpose: 'Payment processing.',
        icon: Icons.payments_outlined,
      ),
      _ProcessorItem(
        name: 'Paystack',
        purpose: 'Payment processing.',
        icon: Icons.credit_card_outlined,
      ),
      _ProcessorItem(
        name: 'Flutterwave',
        purpose: 'Payment processing.',
        icon: Icons.account_balance_outlined,
      ),
      _ProcessorItem(
        name: 'Google Analytics / Firebase Analytics',
        purpose: 'Usage analytics and platform insights.',
        icon: Icons.bar_chart_outlined,
      ),
    ];

    return _sectionPanel(
      eyebrow: '04 / PROCESSORS',
      title: 'Third-party technology providers',
      description:
          'Gift Technology uses selected technology and payment service providers to support authentication, infrastructure, payments, notifications, and analytics.',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: processors.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isMobile ? 1 : 2,
          crossAxisSpacing: 13,
          mainAxisSpacing: 13,
          mainAxisExtent: 105,
        ),
        itemBuilder: (context, index) {
          return _ProcessorCard(item: processors[index]);
        },
      ),
    );
  }

  Widget _buildCookies(bool isMobile) {
    const cookies = [
      _CookieItem(
        icon: Icons.login_rounded,
        title: 'Authentication',
        description: 'Session tokens help maintain secure logged-in sessions.',
      ),
      _CookieItem(
        icon: Icons.analytics_outlined,
        title: 'Analytics',
        description:
            'Google Analytics and Firebase Analytics help understand usage and performance.',
      ),
      _CookieItem(
        icon: Icons.tune_rounded,
        title: 'Preferences',
        description:
            'Preference technologies may remember language, theme, and region settings.',
      ),
      _CookieItem(
        icon: Icons.security_rounded,
        title: 'Security',
        description:
            'Security technologies support CSRF protection and fraud detection.',
      ),
    ];

    return _sectionPanel(
      eyebrow: '05 / COOKIES',
      title: 'Cookies and similar technologies',
      description:
          'Our website and digital services may use cookies or similar technologies for authentication, analytics, preferences, and security.',
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cookies.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 1 : 2,
              crossAxisSpacing: 13,
              mainAxisSpacing: 13,
              mainAxisExtent: 112,
            ),
            itemBuilder: (context, index) {
              return _CookieCard(item: cookies[index]);
            },
          ),
          const SizedBox(height: 13),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: accent.withOpacity(0.055),
              border: Border.all(color: accent.withOpacity(0.08)),
            ),
            child: Row(
              children: [
                const Icon(Icons.ads_click_outlined, size: 18, color: accent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Gift Technology Ltd does not use advertising cookies or ad-tracking cookies.',
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 11,
                      height: 1.5,
                      color: Colors.white.withOpacity(0.58),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountDeletion(bool isMobile) {
    const steps = [
      _DeletionStep(
        number: '01',
        title: 'Request deletion',
        description:
            'The user requests that their Gift Technology account be deleted.',
      ),
      _DeletionStep(
        number: '02',
        title: 'Identity verification',
        description:
            'Identity is verified before the deletion process proceeds.',
      ),
      _DeletionStep(
        number: '03',
        title: 'Wallet balance',
        description:
            'The wallet must have a zero balance before account deactivation.',
      ),
      _DeletionStep(
        number: '04',
        title: 'Account deactivation',
        description:
            'The account is deactivated as part of the deletion process.',
      ),
      _DeletionStep(
        number: '05',
        title: 'Data anonymization',
        description:
            'Personal information is anonymized within 30 days, subject to required regulatory retention.',
      ),
    ];

    return _sectionPanel(
      eyebrow: '06 / ACCOUNT CONTROL',
      title: 'Account deletion',
      description:
          'Gift Technology provides a defined process for users who want to deactivate their accounts and request removal or anonymization of personal information.',
      child: Column(
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            _DeletionCard(step: steps[i]),
            if (i != steps.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Container(
                  width: 1,
                  height: 10,
                  color: accent.withOpacity(0.12),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildSecuritySection(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            blue.withOpacity(0.17),
            navy.withOpacity(0.35),
            Colors.white.withOpacity(0.025),
          ],
        ),
        border: Border.all(color: accent.withOpacity(0.10)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: accent.withOpacity(0.08),
              border: Border.all(color: accent.withOpacity(0.10)),
            ),
            child: const Icon(Icons.shield_outlined, color: accent, size: 23),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SECURITY & RESPONSIBLE HANDLING',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.55,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'We treat personal information as an important part of our platform security model.',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Gift Technology uses authentication, security controls, infrastructure services, payment providers, and monitoring technologies to support the safe operation of its platforms.',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 11.5,
                    height: 1.58,
                    color: Colors.white.withOpacity(0.46),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(bool isMobile) {
    return _sectionPanel(
      eyebrow: '07 / CONTACT',
      title: 'Privacy questions or account requests?',
      description:
          'For questions about your personal information, account deletion, or privacy-related requests, contact Gift Technology Ltd through the official support channel.',
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
          const Icon(Icons.info_outline_rounded, size: 19, color: accent),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              'This privacy screen reflects the data practices and retention information supplied for Gift Technology Ltd. The company may retain transaction information where required for audit, compliance, or regulatory purposes.',
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
}

class _OverviewItem {
  final IconData icon;
  final String title;
  final String text;

  const _OverviewItem({
    required this.icon,
    required this.title,
    required this.text,
  });
}

class _OverviewCard extends StatelessWidget {
  final _OverviewItem item;

  const _OverviewCard({required this.item});

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

class _DataItem {
  final IconData icon;
  final String title;
  final String description;

  const _DataItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _DataCard extends StatelessWidget {
  final _DataItem item;

  const _DataCard({required this.item});

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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFF4A6BB8).withOpacity(0.10),
              border: Border.all(
                color: const Color(0xFF7EA4FF).withOpacity(0.08),
              ),
            ),
            child: Icon(item.icon, color: const Color(0xFF7EA4FF), size: 19),
          ),
          const SizedBox(width: 12),
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
                const SizedBox(height: 6),
                Text(
                  item.description,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 10.2,
                    height: 1.5,
                    color: Colors.white.withOpacity(0.42),
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

class _RetentionItem {
  final String period;
  final String title;
  final String description;
  final IconData icon;

  const _RetentionItem({
    required this.period,
    required this.title,
    required this.description,
    required this.icon,
  });
}

class _RetentionCard extends StatelessWidget {
  final _RetentionItem item;

  const _RetentionCard({required this.item});

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: const Color(0xFF4A6BB8).withOpacity(0.10),
            ),
            child: Icon(item.icon, size: 20, color: const Color(0xFF7EA4FF)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontFamily: 'SegoeUI',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color(0xFF7EA4FF).withOpacity(0.07),
                      ),
                      child: Text(
                        item.period,
                        style: const TextStyle(
                          fontFamily: 'SegoeUI',
                          fontSize: 7.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: Color(0xFF7EA4FF),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
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

class _ProcessorItem {
  final String name;
  final String purpose;
  final IconData icon;

  const _ProcessorItem({
    required this.name,
    required this.purpose,
    required this.icon,
  });
}

class _ProcessorCard extends StatelessWidget {
  final _ProcessorItem item;

  const _ProcessorCard({required this.item});

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
            child: Icon(item.icon, size: 18, color: const Color(0xFF7EA4FF)),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.purpose,
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

class _CookieItem {
  final IconData icon;
  final String title;
  final String description;

  const _CookieItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _CookieCard extends StatelessWidget {
  final _CookieItem item;

  const _CookieCard({required this.item});

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.icon, size: 20, color: const Color(0xFF7EA4FF)),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
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
                const SizedBox(height: 5),
                Text(
                  item.description,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 9.8,
                    height: 1.48,
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

class _DeletionStep {
  final String number;
  final String title;
  final String description;

  const _DeletionStep({
    required this.number,
    required this.title,
    required this.description,
  });
}

class _DeletionCard extends StatelessWidget {
  final _DeletionStep step;

  const _DeletionCard({required this.step});

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4A6BB8).withOpacity(0.18),
                  const Color(0xFF273D68).withOpacity(0.10),
                ],
              ),
              border: Border.all(
                color: const Color(0xFF7EA4FF).withOpacity(0.10),
              ),
            ),
            child: Text(
              step.number,
              style: const TextStyle(
                fontFamily: 'SegoeUI',
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: Color(0xFF7EA4FF),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: const TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  step.description,
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
