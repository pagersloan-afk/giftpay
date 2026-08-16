import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class GiftTechHelpCenterScreen extends StatelessWidget {
  const GiftTechHelpCenterScreen({super.key});

  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _navy = Color(0xFF273D68);
  static const Color _accent = Color(0xFF75A1FF);

  @override
  Widget build(BuildContext context) {
    return GiftTechPageTemplate(
      title: "Help Center",
      description:
          "Find answers, guides, troubleshooting steps, and support resources for GiftPay, GiftPOS, utilities, digital payments, and other Gift Technology services.",
      eyebrow: "GIFT TECHNOLOGY / SUPPORT",
      icon: Icons.support_agent_rounded,
      metaLabel: "SUPPORT",
      metaValue: "Customer Assistance",
      secondaryMetaLabel: "EMAIL",
      secondaryMetaValue: "support@gifttechnologyltd.com",
      child: const _HelpCenterContent(),
    );
  }
}

class _HelpCenterContent extends StatelessWidget {
  const _HelpCenterContent();

  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _navy = Color(0xFF273D68);
  static const Color _accent = Color(0xFF75A1FF);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 720;
    final horizontal = isMobile
        ? 20.0
        : width < 1100
        ? 34.0
        : 56.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSupportHero(isMobile),
          const SizedBox(height: 22),

          _buildSectionHeading(
            "GET HELP",
            "Find the right support for what you need.",
            "Choose a product or service below to find the most relevant information, troubleshooting guidance, and support resources.",
          ),
          const SizedBox(height: 14),

          _buildProductGrid(isMobile),
          const SizedBox(height: 22),

          _buildCommonIssuesPanel(isMobile),
          const SizedBox(height: 22),

          _buildAccountSecurityPanel(isMobile),
          const SizedBox(height: 22),

          _buildTransactionSupportPanel(isMobile),
          const SizedBox(height: 22),

          _buildContactPanel(isMobile),
          const SizedBox(height: 22),

          _buildCompanyFooter(),
        ],
      ),
    );
  }

  Widget _buildSupportHero(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 22 : 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _navy.withOpacity(.65),
            _blue.withOpacity(.16),
            Colors.white.withOpacity(.025),
          ],
        ),
        border: Border.all(color: _accent.withOpacity(.11)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.16),
            blurRadius: 35,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSupportOrb(),
                const SizedBox(height: 18),
                _buildHeroCopy(),
                const SizedBox(height: 18),
                _buildSupportStatus(),
              ],
            )
          : Row(
              children: [
                _buildSupportOrb(),
                const SizedBox(width: 20),
                Expanded(child: _buildHeroCopy()),
                const SizedBox(width: 24),
                _buildSupportStatus(),
              ],
            ),
    );
  }

  Widget _buildSupportOrb() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_accent.withOpacity(.25), _blue.withOpacity(.08)],
        ),
        border: Border.all(color: _accent.withOpacity(.20)),
        boxShadow: [
          BoxShadow(
            color: _blue.withOpacity(.20),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(Icons.support_agent_rounded, color: _accent, size: 34),
    );
  }

  Widget _buildHeroCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "CUSTOMER SUPPORT",
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.7,
            color: _accent,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "We're here to help you move forward.",
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 21,
            fontWeight: FontWeight.w800,
            height: 1.15,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          "Whether you are using GiftPay, GiftPOS, utilities, or our business platforms, the Help Center gives you a clear path to answers and support.",
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 12.5,
            height: 1.62,
            color: Colors.white.withOpacity(.52),
          ),
        ),
      ],
    );
  }

  Widget _buildSupportStatus() {
    return Container(
      constraints: const BoxConstraints(minWidth: 190),
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(.045),
        border: Border.all(color: Colors.white.withOpacity(.09)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "SUPPORT CHANNEL",
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: _accent,
            ),
          ),
          SizedBox(height: 7),
          Text(
            "support@gifttechnologyltd.com",
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 5),
          Text(
            "Gift Technology Ltd",
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 10,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeading(
    String eyebrow,
    String title,
    String description,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _eyebrow(eyebrow),
        const SizedBox(height: 7),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          description,
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 12.5,
            height: 1.58,
            color: Colors.white.withOpacity(.48),
          ),
        ),
      ],
    );
  }

  Widget _buildProductGrid(bool isMobile) {
    const products = [
      (
        Icons.account_balance_wallet_rounded,
        "GiftPay Wallet",
        "Wallet funding, withdrawals, transfers, KYC, security PIN, 2FA, and transaction history.",
      ),
      (
        Icons.point_of_sale_rounded,
        "GiftPOS",
        "Payment acceptance, receipts, transactions, settlements, terminals, staff accounts, and reversals.",
      ),
      (
        Icons.bolt_rounded,
        "Utilities",
        "Airtime, data, electricity tokens, cable TV, and supported internet subscriptions.",
      ),
      (
        Icons.card_giftcard_rounded,
        "GiftCard Marketplace",
        "Information and assistance relating to digital gift card purchases and delivery.",
      ),
      (
        Icons.business_center_rounded,
        "Business Services",
        "Business dashboards, payouts, payment operations, and enterprise services.",
      ),
      (
        Icons.api_rounded,
        "GiftPay API",
        "API transactions, integration information, transaction lookup, vending, and wallet operations.",
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: 138,
      ),
      itemBuilder: (context, index) {
        final item = products[index];

        return _SupportTile(
          icon: item.$1,
          title: item.$2,
          description: item.$3,
        );
      },
    );
  }

  Widget _buildCommonIssuesPanel(bool isMobile) {
    const issues = [
      (
        Icons.lock_outline_rounded,
        "Can't access your account",
        "Check your login details and authentication method. Never share your password, PIN, OTP, or authentication codes with anyone.",
      ),
      (
        Icons.payments_outlined,
        "Payment or transaction issue",
        "Keep your transaction reference, amount, date, and service details available when contacting support.",
      ),
      (
        Icons.bolt_outlined,
        "Utility purchase problem",
        "For airtime, data, electricity, or other utility purchases, confirm whether the transaction was successful before attempting another purchase.",
      ),
      (
        Icons.devices_other_rounded,
        "GiftPOS issue",
        "For POS-related issues, keep the terminal details and transaction reference available for faster investigation.",
      ),
    ];

    return _contentPanel(
      eyebrow: "TROUBLESHOOTING",
      title: "Common issues, clearly explained.",
      description:
          "Before contacting support, these simple checks can help resolve common account, payment, utility, and POS issues.",
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: issues.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isMobile ? 1 : 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 150,
        ),
        itemBuilder: (context, index) {
          final item = issues[index];

          return _SupportTile(
            icon: item.$1,
            title: item.$2,
            description: item.$3,
          );
        },
      ),
    );
  }

  Widget _buildAccountSecurityPanel(bool isMobile) {
    const securityItems = [
      (
        Icons.verified_user_outlined,
        "Protect your credentials",
        "Keep passwords, security PINs, OTPs, and authentication credentials private.",
      ),
      (
        Icons.phonelink_lock_outlined,
        "Use trusted devices",
        "Only access your Gift Technology accounts from devices and networks you trust.",
      ),
      (
        Icons.fact_check_outlined,
        "Complete verification",
        "Wallet services may require KYC verification before relevant features can be used.",
      ),
    ];

    return _contentPanel(
      eyebrow: "ACCOUNT SECURITY",
      title: "Your security comes first.",
      description:
          "Gift Technology uses security controls across its platforms, but protecting your account credentials remains an important part of keeping your account secure.",
      child: Column(
        children: [
          for (int i = 0; i < securityItems.length; i++) ...[
            _SecurityRow(
              icon: securityItems[i].$1,
              title: securityItems[i].$2,
              description: securityItems[i].$3,
            ),
            if (i != securityItems.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _buildTransactionSupportPanel(bool isMobile) {
    const tracking = [
      "Airtime purchase status",
      "Data purchase status",
      "Electricity token generation",
      "Gift card delivery",
      "Wallet transfer status",
      "POS transaction status",
      "Utility payment status",
      "Business dashboard payouts",
      "GiftPay API transaction logs",
    ];

    return _contentPanel(
      eyebrow: "TRANSACTION SUPPORT",
      title: "Have your transaction details ready.",
      description:
          "When you need assistance with a transaction, providing the relevant reference and service details helps our team investigate the issue efficiently.",
      child: Wrap(
        spacing: 9,
        runSpacing: 9,
        children: [for (final item in tracking) _TrackingChip(label: item)],
      ),
    );
  }

  Widget _buildContactPanel(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 22 : 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _blue.withOpacity(.18),
            _navy.withOpacity(.35),
            Colors.white.withOpacity(.025),
          ],
        ),
        border: Border.all(color: _accent.withOpacity(.10)),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _contactIcon(),
                const SizedBox(height: 18),
                _contactCopy(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _contactIcon(),
                const SizedBox(width: 18),
                Expanded(child: _contactCopy()),
              ],
            ),
    );
  }

  Widget _contactIcon() {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: _accent.withOpacity(.10),
        border: Border.all(color: _accent.withOpacity(.10)),
      ),
      child: const Icon(Icons.mail_outline_rounded, color: _accent, size: 25),
    );
  }

  Widget _contactCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _eyebrow("CONTACT SUPPORT"),
        const SizedBox(height: 7),
        const Text(
          "Need direct assistance?",
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          "Contact Gift Technology Ltd through our official support channel and include enough information for us to understand the issue.",
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 11.5,
            height: 1.58,
            color: Colors.white.withOpacity(.45),
          ),
        ),
        const SizedBox(height: 14),
        SelectableText(
          "support@gifttechnologyltd.com",
          style: const TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: _accent,
          ),
        ),
        const SizedBox(height: 7),
        SelectableText(
          "+234 901 085 3849",
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 11,
            color: Colors.white.withOpacity(.55),
          ),
        ),
      ],
    );
  }

  Widget _buildCompanyFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withOpacity(.025),
        border: Border.all(color: Colors.white.withOpacity(.055)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _eyebrow("GIFT TECHNOLOGY LTD"),
          const SizedBox(height: 8),
          const Text(
            "Secure digital platforms for Africa.",
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Gift Technology Ltd builds secure digital platforms that power payments, utilities, e-voting, entertainment, and business operations across Africa.",
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 11.5,
              height: 1.58,
              color: Colors.white.withOpacity(.42),
            ),
          ),
          const SizedBox(height: 17),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _MiniBadge(label: "Port Harcourt"),
              _MiniBadge(label: "Rivers State"),
              _MiniBadge(label: "Nigeria"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _contentPanel({
    required String eyebrow,
    required String title,
    required String description,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withOpacity(.035),
        border: Border.all(color: Colors.white.withOpacity(.065)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.12),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _eyebrow(eyebrow),
          const SizedBox(height: 7),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 19,
              fontWeight: FontWeight.w800,
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
              color: Colors.white.withOpacity(.44),
            ),
          ),
          const SizedBox(height: 17),
          child,
        ],
      ),
    );
  }

  Widget _eyebrow(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'SegoeUI',
        fontSize: 9,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.65,
        color: _accent,
      ),
    );
  }
}

class _SupportTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _SupportTile({
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
        color: Colors.white.withOpacity(.028),
        border: Border.all(color: Colors.white.withOpacity(.055)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: const Color(0xFF4A6BB8).withOpacity(.10),
              border: Border.all(
                color: const Color(0xFF75A1FF).withOpacity(.08),
              ),
            ),
            child: Icon(icon, color: const Color(0xFF75A1FF), size: 20),
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
                    fontSize: 10.5,
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

class _SecurityRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _SecurityRow({
    required this.icon,
    required this.title,
    required this.description,
  });

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
          Icon(icon, color: const Color(0xFF75A1FF), size: 21),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 10,
                    height: 1.48,
                    color: Colors.white.withOpacity(.40),
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

class _TrackingChip extends StatelessWidget {
  final String label;

  const _TrackingChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white.withOpacity(.04),
        border: Border.all(color: Colors.white.withOpacity(.065)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            size: 13,
            color: Color(0xFF75A1FF),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final String label;

  const _MiniBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white.withOpacity(.045),
        border: Border.all(color: Colors.white.withOpacity(.07)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'SegoeUI',
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: Colors.white70,
        ),
      ),
    );
  }
}
