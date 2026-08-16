import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class GiftPOSScreen extends StatelessWidget {
  const GiftPOSScreen({super.key});

  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _navy = Color(0xFF273D68);
  static const Color _accent = Color(0xFF75A1FF);

  @override
  Widget build(BuildContext context) {
    return GiftTechPageTemplate(
      title: 'GiftPOS',
      description:
          'A modern payment and business operations platform designed to help merchants accept payments, manage transactions, monitor settlements, and run everyday sales operations from one connected system.',
      eyebrow: 'GIFT TECHNOLOGY / BUSINESS PAYMENTS',
      icon: Icons.point_of_sale_rounded,
      metaLabel: 'PLATFORM',
      metaValue: 'Merchant POS',
      secondaryMetaLabel: 'PAYMENT METHODS',
      secondaryMetaValue: 'CARD • TRANSFER',
      child: const _GiftPOSContent(),
    );
  }
}

class _GiftPOSContent extends StatelessWidget {
  const _GiftPOSContent();

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
          _buildHeroPanel(context, isMobile),
          const SizedBox(height: 22),

          _buildSectionHeading(
            'PAYMENTS',
            'Accept payments without the operational friction.',
            'GiftPOS brings card and transfer payment acceptance together with transaction visibility and business controls.',
          ),
          const SizedBox(height: 14),

          _buildPaymentMethods(isMobile),
          const SizedBox(height: 22),

          _buildSectionHeading(
            'CORE CAPABILITIES',
            'Everything a merchant needs at the point of sale.',
            'Designed around the daily workflow of merchants, businesses, and teams managing physical payment operations.',
          ),
          const SizedBox(height: 14),

          _buildCapabilities(isMobile),
          const SizedBox(height: 22),

          _buildOperationsPanel(context, isMobile),
          const SizedBox(height: 22),

          _buildBusinessPanel(isMobile),
          const SizedBox(height: 22),

          _buildSettlementPanel(isMobile),
          const SizedBox(height: 22),

          _buildReversalPanel(),
          const SizedBox(height: 22),

          _buildClosingPanel(),
        ],
      ),
    );
  }

  Widget _buildHeroPanel(BuildContext context, bool isMobile) {
    return _GlassPanel(
      padding: EdgeInsets.all(isMobile ? 22 : 30),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIconOrb(),
                const SizedBox(height: 18),
                _buildHeroCopy(),
                const SizedBox(height: 18),
                _buildHeroBadge(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildIconOrb(),
                const SizedBox(width: 20),
                Expanded(child: _buildHeroCopy()),
                const SizedBox(width: 25),
                _buildHeroBadge(),
              ],
            ),
    );
  }

  Widget _buildIconOrb() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_accent.withOpacity(.24), _blue.withOpacity(.10)],
        ),
        border: Border.all(color: _accent.withOpacity(.20)),
        boxShadow: [
          BoxShadow(
            color: _blue.withOpacity(.18),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(Icons.point_of_sale_rounded, color: _accent, size: 32),
    );
  }

  Widget _buildHeroCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MERCHANT PAYMENT INFRASTRUCTURE',
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
          'A smarter way to run the point of sale.',
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
          'Accept payments, keep your transaction history organized, monitor settlements, and give your team the tools they need to operate efficiently.',
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

  Widget _buildHeroBadge() {
    return Container(
      constraints: const BoxConstraints(minWidth: 170),
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
            'PAYMENT ECOSYSTEM',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: _accent,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Card + Transfer',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Built for merchants',
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

  Widget _buildPaymentMethods(bool isMobile) {
    const methods = [
      (
        Icons.credit_card_rounded,
        'Card payments',
        'Accept card payments through supported payment infrastructure.',
      ),
      (
        Icons.account_balance_rounded,
        'Transfer payments',
        'Give customers a convenient bank-transfer payment option.',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: methods.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: 130,
      ),
      itemBuilder: (context, index) {
        final item = methods[index];

        return _FeatureTile(
          icon: item.$1,
          title: item.$2,
          description: item.$3,
        );
      },
    );
  }

  Widget _buildCapabilities(bool isMobile) {
    const capabilities = [
      (
        Icons.receipt_long_rounded,
        'Digital receipts',
        'Print receipts for completed customer transactions.',
      ),
      (
        Icons.history_rounded,
        'Transaction history',
        'Keep a clear record of payment activity and sales transactions.',
      ),
      (
        Icons.assessment_outlined,
        'Settlement reports',
        'Review settlement information to support business reconciliation.',
      ),
      (
        Icons.groups_2_outlined,
        'Staff accounts',
        'Support staff-based access for teams operating the business.',
      ),
      (
        Icons.devices_other_rounded,
        'Multi-terminal support',
        'Operate multiple POS terminals within a connected business environment.',
      ),
      (
        Icons.today_rounded,
        'Daily sales summary',
        'Review daily sales activity to understand business performance.',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: capabilities.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: 122,
      ),
      itemBuilder: (context, index) {
        final item = capabilities[index];

        return _FeatureTile(
          icon: item.$1,
          title: item.$2,
          description: item.$3,
        );
      },
    );
  }

  Widget _buildOperationsPanel(BuildContext context, bool isMobile) {
    return _GlassPanel(
      padding: EdgeInsets.all(isMobile ? 22 : 28),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPanelIcon(Icons.dashboard_customize_rounded),
                const SizedBox(height: 18),
                _buildOperationsCopy(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPanelIcon(Icons.dashboard_customize_rounded),
                const SizedBox(width: 20),
                Expanded(child: _buildOperationsCopy()),
              ],
            ),
    );
  }

  Widget _buildOperationsCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _eyebrow('BUSINESS OPERATIONS'),
        const SizedBox(height: 7),
        const Text(
          'More than a payment terminal.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'GiftPOS connects payment acceptance with the operational information merchants need after a transaction is completed. From transaction history to settlement reports and daily sales summaries, the platform is designed to make everyday payment operations easier to manage.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 12,
            height: 1.62,
            color: Colors.white.withOpacity(.47),
          ),
        ),
        const SizedBox(height: 17),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            _MiniBadge(label: 'Transactions'),
            _MiniBadge(label: 'Settlements'),
            _MiniBadge(label: 'Sales'),
            _MiniBadge(label: 'Staff'),
          ],
        ),
      ],
    );
  }

  Widget _buildBusinessPanel(bool isMobile) {
    const useCases = [
      (
        Icons.storefront_rounded,
        'Retail',
        'Support everyday customer payments and sales operations.',
      ),
      (
        Icons.business_center_rounded,
        'Businesses',
        'Centralize payment activity and operational reporting.',
      ),
      (
        Icons.groups_outlined,
        'Teams',
        'Give authorized staff structured access to POS operations.',
      ),
    ];

    return _contentPanel(
      eyebrow: 'BUILT FOR BUSINESS',
      title: 'Designed around real merchant workflows.',
      description:
          'GiftPOS is built to support businesses that need dependable payment acceptance alongside visibility into their day-to-day transactions.',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: useCases.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isMobile ? 1 : 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 132,
        ),
        itemBuilder: (context, index) {
          final item = useCases[index];

          return _FeatureTile(
            icon: item.$1,
            title: item.$2,
            description: item.$3,
          );
        },
      ),
    );
  }

  Widget _buildSettlementPanel(bool isMobile) {
    return _contentPanel(
      eyebrow: 'SETTLEMENT & REPORTING',
      title: 'Keep the numbers visible.',
      description:
          'Settlement reporting and transaction history help businesses reconcile payment activity and maintain a clearer view of their operations.',
      child: isMobile
          ? Column(
              children: const [
                _MetricRow(
                  icon: Icons.receipt_long_rounded,
                  title: 'Transaction history',
                  description: 'Review recorded payment activity.',
                ),
                SizedBox(height: 10),
                _MetricRow(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Settlement reports',
                  description: 'Monitor settlement information.',
                ),
                SizedBox(height: 10),
                _MetricRow(
                  icon: Icons.bar_chart_rounded,
                  title: 'Daily sales',
                  description: 'Review daily sales activity.',
                ),
              ],
            )
          : Row(
              children: const [
                Expanded(
                  child: _MetricRow(
                    icon: Icons.receipt_long_rounded,
                    title: 'Transaction history',
                    description: 'Review recorded payment activity.',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _MetricRow(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Settlement reports',
                    description: 'Monitor settlement information.',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _MetricRow(
                    icon: Icons.bar_chart_rounded,
                    title: 'Daily sales',
                    description: 'Review daily sales activity.',
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildReversalPanel() {
    return Container(
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _navy.withOpacity(.48),
            const Color(0xFF0A1427).withOpacity(.90),
          ],
        ),
        border: Border.all(color: _accent.withOpacity(.10)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: _blue.withOpacity(.12),
            ),
            child: const Icon(
              Icons.sync_problem_rounded,
              color: _accent,
              size: 22,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _eyebrow('TRANSACTION SUPPORT'),
                const SizedBox(height: 7),
                const Text(
                  'POS reversal support',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'GiftPOS supports POS reversal workflows in accordance with applicable banking and payment-network reversal processes.',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 11.5,
                    height: 1.58,
                    color: Colors.white.withOpacity(.44),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClosingPanel() {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_blue.withOpacity(.20), Colors.white.withOpacity(.025)],
        ),
        border: Border.all(color: Colors.white.withOpacity(.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _eyebrow('GIFT TECHNOLOGY'),
          const SizedBox(height: 8),
          const Text(
            'Payment infrastructure built for the way businesses operate.',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 19,
              fontWeight: FontWeight.w800,
              height: 1.25,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            'GiftPOS forms part of the Gift Technology ecosystem alongside GiftPay Wallet, utilities, and API infrastructure.',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 11.5,
              height: 1.6,
              color: Colors.white.withOpacity(.45),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _accent,
                ),
              ),
              const SizedBox(width: 9),
              Text(
                'Gift Technology Ltd • Port Harcourt, Nigeria',
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 10,
                  color: Colors.white.withOpacity(.40),
                ),
              ),
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
    return _GlassPanel(
      padding: const EdgeInsets.all(22),
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

  Widget _buildPanelIcon(IconData icon) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: _blue.withOpacity(.11),
        border: Border.all(color: _accent.withOpacity(.10)),
      ),
      child: Icon(icon, color: _accent, size: 25),
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

class _GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _GlassPanel({required this.child, required this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withOpacity(.035),
        border: Border.all(color: Colors.white.withOpacity(.065)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.14),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureTile({
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
                color: const Color(0xFF75A1FF).withOpacity(.07),
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

class _MetricRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _MetricRow({
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
                    fontSize: 9.8,
                    color: Colors.white.withOpacity(.38),
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
