import 'package:flutter/material.dart';
import 'package:utilityhub/features/gift_techlanding/screens/gifttech_page_template.dart';

class DataPrivacyScreen extends StatelessWidget {
  const DataPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GiftTechPageTemplate(
      title: 'Data & Privacy',
      description:
          'How Gift Technology Ltd collects, uses, protects, retains, and manages personal and transaction data across its digital platforms.',
      eyebrow: 'TRUST • PRIVACY • SECURITY',
      icon: Icons.privacy_tip_outlined,
      metaLabel: 'DATA PROTECTION',
      metaValue: 'Privacy & Security',
      secondaryMetaLabel: 'LAST REVIEW',
      secondaryMetaValue: 'August 2026',
      child: const _DataPrivacyContent(),
    );
  }
}

class _DataPrivacyContent extends StatelessWidget {
  const _DataPrivacyContent();

  static const Color primaryBlue = Color(0xFF4A6BB8);
  static const Color lightBlue = Color(0xFF75A1FF);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 720;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _privacyHero(isMobile),
          const SizedBox(height: 20),
          _introSection(),
          const SizedBox(height: 20),
          _dataCollectionSection(isMobile),
          const SizedBox(height: 20),
          _transactionDataSection(),
          const SizedBox(height: 20),
          _deviceAnalyticsSection(isMobile),
          const SizedBox(height: 20),
          _processorSection(isMobile),
          const SizedBox(height: 20),
          _retentionSection(isMobile),
          const SizedBox(height: 20),
          _securitySection(),
          const SizedBox(height: 20),
          _deletionSection(isMobile),
          const SizedBox(height: 20),
          _privacyPrinciples(isMobile),
          const SizedBox(height: 20),
          _contactSection(),
        ],
      ),
    );
  }

  Widget _privacyHero(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 22 : 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryBlue.withOpacity(.48),
            const Color(0xFF0A1427).withOpacity(.95),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(.09)),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(.14),
            blurRadius: 48,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17),
              color: lightBlue.withOpacity(.11),
              border: Border.all(color: lightBlue.withOpacity(.15)),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: lightBlue,
              size: 28,
            ),
          ),
          const SizedBox(width: 17),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your data deserves deliberate protection.',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Gift Technology Ltd uses personal, transaction, device, and operational information to provide secure digital services, support users, meet compliance requirements, and improve platform performance.',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 12,
                    height: 1.62,
                    color: Color.fromRGBO(255, 255, 255, .52),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _introSection() {
    return _sectionCard(
      eyebrow: 'OUR APPROACH',
      title: 'Privacy is part of the platform.',
      description:
          'Gift Technology Ltd designs its digital services around secure handling of information. The information collected depends on the service a user accesses and may include identity, contact, KYC, transaction, device, and usage information.',
      icon: Icons.lock_outline_rounded,
    );
  }

  Widget _dataCollectionSection(bool isMobile) {
    final items = [
      (
        Icons.badge_outlined,
        'Identity information',
        'Full name and date of birth.',
      ),
      (
        Icons.email_outlined,
        'Contact information',
        'Email address and phone number.',
      ),
      (
        Icons.home_outlined,
        'Residential information',
        'Residential address where required for KYC.',
      ),
      (
        Icons.verified_user_outlined,
        'KYC information',
        'BVN where required for KYC verification.',
      ),
    ];

    return _contentSection(
      eyebrow: '01 • INFORMATION WE COLLECT',
      title: 'Information provided by users',
      description:
          'The information collected by Gift Technology depends on the account, product, transaction, and verification requirements involved.',
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 1 : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 112,
          ),
          itemBuilder: (context, index) {
            final item = items[index];

            return _InfoTile(
              icon: item.$1,
              title: item.$2,
              description: item.$3,
            );
          },
        ),
      ],
    );
  }

  Widget _transactionDataSection() {
    return _contentSection(
      eyebrow: '02 • TRANSACTION INFORMATION',
      title: 'Understanding transaction activity',
      description:
          'Gift Technology may process transaction information necessary to operate, record, support, audit, and secure its services.',
      children: [
        _bulletList([
          'Airtime purchase history',
          'Data purchase history',
          'Electricity transactions',
          'Wallet transfers',
          'POS transactions',
          'Payment references',
          'Gateway responses',
          'Transaction timestamps',
        ]),
      ],
    );
  }

  Widget _deviceAnalyticsSection(bool isMobile) {
    final items = [
      (
        Icons.devices_outlined,
        'Device information',
        'Device model, operating system version, and IP address.',
      ),
      (
        Icons.analytics_outlined,
        'Usage analytics',
        'Screen views, clicks, and platform performance logs.',
      ),
      (
        Icons.payments_outlined,
        'Payment metadata',
        'Payment references, gateway responses, and transaction timestamps.',
      ),
    ];

    return _contentSection(
      eyebrow: '03 • PLATFORM INFORMATION',
      title: 'Device, analytics & payment data',
      description:
          'Technical and operational information helps Gift Technology maintain platform reliability, understand service usage, process transactions, and identify operational issues.',
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 1 : 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 150,
          ),
          itemBuilder: (context, index) {
            final item = items[index];

            return _InfoTile(
              icon: item.$1,
              title: item.$2,
              description: item.$3,
            );
          },
        ),
      ],
    );
  }

  Widget _processorSection(bool isMobile) {
    final processors = [
      (
        'Firebase',
        'Authentication and push notifications.',
        Icons.notifications_none_outlined,
      ),
      ('Supabase', 'Database and API services.', Icons.storage_outlined),
      (
        'Monnify',
        'Payment processing services.',
        Icons.account_balance_outlined,
      ),
      ('Paystack', 'Payment processing services.', Icons.credit_card_outlined),
      ('Flutterwave', 'Payment processing services.', Icons.payments_outlined),
      (
        'Google Analytics / Firebase Analytics',
        'Usage and platform analytics.',
        Icons.insights_outlined,
      ),
    ];

    return _contentSection(
      eyebrow: '04 • SERVICE PROVIDERS',
      title: 'Third-party processors',
      description:
          'Gift Technology uses selected technology and payment service providers to operate parts of its digital infrastructure.',
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: processors.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 1 : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 112,
          ),
          itemBuilder: (context, index) {
            final processor = processors[index];

            return _InfoTile(
              icon: processor.$3,
              title: processor.$1,
              description: processor.$2,
            );
          },
        ),
      ],
    );
  }

  Widget _retentionSection(bool isMobile) {
    final retention = [
      (
        'KYC data',
        'Retained while the account remains active, subject to applicable Nigerian financial requirements.',
      ),
      (
        'Transaction data',
        'Minimum retention period of 5 years for audit and compliance purposes.',
      ),
      ('Analytics data', 'Retained for approximately 12–24 months.'),
      ('Support tickets', 'Retained for approximately 12 months.'),
      (
        'Deleted accounts',
        'Personal information is anonymized within 30 days, subject to regulatory retention requirements.',
      ),
    ];

    return _contentSection(
      eyebrow: '05 • DATA RETENTION',
      title: 'Information is retained for a reason.',
      description:
          'Different categories of information have different retention periods based on operational, audit, compliance, and support requirements.',
      children: [
        ...retention.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _RetentionTile(title: item.$1, description: item.$2),
          ),
        ),
      ],
    );
  }

  Widget _securitySection() {
    return _sectionCard(
      eyebrow: '06 • SECURITY',
      title: 'Security-conscious digital infrastructure.',
      description:
          'Gift Technology uses security controls and operational safeguards across its platforms. Depending on the service, these include authentication, KYC verification, security PINs, two-factor authentication, device information, transaction monitoring, and fraud-detection mechanisms.',
      icon: Icons.security_outlined,
    );
  }

  Widget _deletionSection(bool isMobile) {
    final steps = [
      ('01', 'Request', 'The user requests account deletion.'),
      ('02', 'Verify', 'The user’s identity is verified.'),
      ('03', 'Clear wallet', 'The wallet must have a zero balance.'),
      ('04', 'Deactivate', 'The account is deactivated.'),
      (
        '05',
        'Anonymize',
        'Personal information is anonymized within 30 days, while regulatory transaction records remain where retention is required.',
      ),
    ];

    return _contentSection(
      eyebrow: '07 • ACCOUNT DELETION',
      title: 'A clear account deletion process.',
      description:
          'Users can request deletion of their account. Certain conditions and regulatory retention requirements apply.',
      children: [
        if (isMobile)
          Column(
            children: steps
                .map(
                  (step) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _StepTile(
                      number: step.$1,
                      title: step.$2,
                      description: step.$3,
                    ),
                  ),
                )
                .toList(),
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: steps
                .map(
                  (step) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _StepTile(
                        number: step.$1,
                        title: step.$2,
                        description: step.$3,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _privacyPrinciples(bool isMobile) {
    final principles = [
      (
        Icons.visibility_outlined,
        'Transparency',
        'We explain the categories of information used across our services.',
      ),
      (
        Icons.gavel_outlined,
        'Compliance',
        'Required regulatory and audit records are retained where applicable.',
      ),
      (
        Icons.lock_outline,
        'Protection',
        'Security controls are incorporated into the operation of our platforms.',
      ),
      (
        Icons.delete_outline,
        'Responsible deletion',
        'Personal information is anonymized after account deletion within the stated period, subject to regulatory requirements.',
      ),
    ];

    return _contentSection(
      eyebrow: '08 • PRIVACY PRINCIPLES',
      title: 'Designed around responsible data handling.',
      description:
          'Our privacy practices are intended to balance user privacy, platform security, operational requirements, and regulatory obligations.',
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: principles.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 1 : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 135,
          ),
          itemBuilder: (context, index) {
            final item = principles[index];

            return _InfoTile(
              icon: item.$1,
              title: item.$2,
              description: item.$3,
            );
          },
        ),
      ],
    );
  }

  Widget _contactSection() {
    return Container(
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(23),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryBlue.withOpacity(.24),
            const Color(0xFF0A1427).withOpacity(.88),
          ],
        ),
        border: Border.all(color: lightBlue.withOpacity(.10)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.mail_outline_rounded, color: lightBlue, size: 25),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PRIVACY QUESTIONS',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.6,
                    color: lightBlue,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Contact Gift Technology',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'support@gifttechnologyltd.com',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  '+234 901 085 3849  •  Plot 12, 6th Avenue, Rumuaghaolu Road, SARS Rd, Port Harcourt, Rivers, Nigeria.',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 10.5,
                    height: 1.5,
                    color: Color.fromRGBO(255, 255, 255, .42),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _contentSection({
    required String eyebrow,
    required String title,
    required String description,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(23),
        color: const Color(0xFF0B162A).withOpacity(.70),
        border: Border.all(color: Colors.white.withOpacity(.055)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: const TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.65,
              color: lightBlue,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            description,
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 11.2,
              height: 1.58,
              color: Colors.white.withOpacity(.44),
            ),
          ),
          if (children.isNotEmpty) ...[const SizedBox(height: 18), ...children],
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String eyebrow,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(23),
        color: const Color(0xFF0B162A).withOpacity(.72),
        border: Border.all(color: Colors.white.withOpacity(.055)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _iconTile(icon),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow,
                  style: const TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: lightBlue,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 11.1,
                    height: 1.58,
                    color: Colors.white.withOpacity(.43),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bulletList(List<String> items) {
    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: lightBlue,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontFamily: 'SegoeUI',
                        fontSize: 11,
                        height: 1.45,
                        color: Colors.white.withOpacity(.55),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _iconTile(IconData icon) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        color: primaryBlue.withOpacity(.11),
        border: Border.all(color: lightBlue.withOpacity(.10)),
      ),
      child: Icon(icon, size: 21, color: lightBlue),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(.025),
        border: Border.all(color: Colors.white.withOpacity(.055)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFF4A6BB8).withOpacity(.10),
            ),
            child: Icon(icon, color: const Color(0xFF75A1FF), size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 10.3,
                    height: 1.48,
                    color: Colors.white.withOpacity(.42),
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

class _RetentionTile extends StatelessWidget {
  final String title;
  final String description;

  const _RetentionTile({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(.025),
        border: Border.all(color: Colors.white.withOpacity(.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.schedule_outlined,
            color: Color(0xFF75A1FF),
            size: 19,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 10.8,
                  height: 1.5,
                  color: Colors.white.withOpacity(.45),
                ),
                children: [
                  TextSpan(
                    text: '$title  ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  final String number;
  final String title;
  final String description;

  const _StepTile({
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        color: Colors.white.withOpacity(.025),
        border: Border.all(color: Colors.white.withOpacity(.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: const TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Color(0xFF75A1FF),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            description,
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 10.2,
              height: 1.48,
              color: Colors.white.withOpacity(.42),
            ),
          ),
        ],
      ),
    );
  }
}
