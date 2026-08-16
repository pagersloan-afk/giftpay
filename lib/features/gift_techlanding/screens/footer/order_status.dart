import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class OrderStatusScreen extends StatelessWidget {
  const OrderStatusScreen({super.key});

  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _navy = Color(0xFF273D68);
  static const Color _accent = Color(0xFF75A1FF);

  @override
  Widget build(BuildContext context) {
    return GiftTechPageTemplate(
      title: "Order Status",
      description:
          "Track Gift Technology transactions and service activity across airtime, data, electricity, gift cards, wallet transfers, POS payments, utilities, and business services.",
      eyebrow: "GIFT TECHNOLOGY / TRANSACTION TRACKING",
      icon: Icons.receipt_long_rounded,
      metaLabel: "TRACKING",
      metaValue: "Transaction Status",
      secondaryMetaLabel: "SUPPORT",
      secondaryMetaValue: "support@gifttechnologyltd.com",
      child: const _OrderStatusContent(),
    );
  }
}

class _OrderStatusContent extends StatelessWidget {
  const _OrderStatusContent();

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
          _buildHero(isMobile),
          const SizedBox(height: 22),

          _sectionHeading(
            "TRACK YOUR ACTIVITY",
            "Know what is happening with your transaction.",
            "Gift Technology services provide status information across supported purchases, transfers, payments, and business operations.",
          ),
          const SizedBox(height: 14),

          _buildTrackingGrid(isMobile),
          const SizedBox(height: 22),

          _buildStatusGuide(isMobile),
          const SizedBox(height: 22),

          _buildDigitalServicesPanel(isMobile),
          const SizedBox(height: 22),

          _buildPaymentsPanel(isMobile),
          const SizedBox(height: 22),

          _buildBusinessPanel(isMobile),
          const SizedBox(height: 22),

          _buildSupportPanel(),
          const SizedBox(height: 22),

          _buildSecurityNotice(),
        ],
      ),
    );
  }

  Widget _buildHero(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 22 : 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _navy.withOpacity(.68),
            _blue.withOpacity(.15),
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
                _buildStatusOrb(),
                const SizedBox(height: 18),
                _buildHeroCopy(),
                const SizedBox(height: 18),
                _buildTrackingBadge(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildStatusOrb(),
                const SizedBox(width: 20),
                Expanded(child: _buildHeroCopy()),
                const SizedBox(width: 24),
                _buildTrackingBadge(),
              ],
            ),
    );
  }

  Widget _buildStatusOrb() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_accent.withOpacity(.24), _blue.withOpacity(.08)],
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
      child: const Icon(Icons.receipt_long_rounded, color: _accent, size: 32),
    );
  }

  Widget _buildHeroCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "TRANSACTION VISIBILITY",
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
          "Stay informed from purchase to completion.",
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
          "Order Status brings the important details of your Gift Technology activity into one clear support destination.",
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

  Widget _buildTrackingBadge() {
    return Container(
      constraints: const BoxConstraints(minWidth: 180),
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
            "SUPPORTED ACTIVITY",
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
            "Payments • Utilities",
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 5),
          Text(
            "Wallet • POS • API",
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

  Widget _buildTrackingGrid(bool isMobile) {
    const items = [
      (
        Icons.phone_android_rounded,
        "Airtime",
        "Track airtime purchase status and delivery.",
      ),
      (
        Icons.data_usage_rounded,
        "Data",
        "Check the status of supported data purchases.",
      ),
      (
        Icons.bolt_rounded,
        "Electricity",
        "Track electricity token generation.",
      ),
      (
        Icons.card_giftcard_rounded,
        "Gift Cards",
        "Follow gift card delivery status.",
      ),
      (
        Icons.account_balance_wallet_rounded,
        "Wallet Transfers",
        "Monitor transfers between GiftPay users.",
      ),
      (
        Icons.point_of_sale_rounded,
        "POS Transactions",
        "Review GiftPOS transaction activity.",
      ),
      (
        Icons.receipt_long_outlined,
        "Utility Payments",
        "Track supported utility payment activity.",
      ),
      (
        Icons.business_center_outlined,
        "Business Payouts",
        "Monitor business dashboard payout activity.",
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: 122,
      ),
      itemBuilder: (context, index) {
        final item = items[index];

        return _LuxuryTile(icon: item.$1, title: item.$2, description: item.$3);
      },
    );
  }

  Widget _buildStatusGuide(bool isMobile) {
    const statuses = [
      (
        Icons.schedule_rounded,
        "Processing",
        "The request has been received and is being processed.",
      ),
      (
        Icons.check_circle_outline_rounded,
        "Completed",
        "The service or transaction has been successfully completed.",
      ),
      (
        Icons.error_outline_rounded,
        "Attention required",
        "The transaction may require investigation or additional action.",
      ),
    ];

    return _contentPanel(
      eyebrow: "STATUS GUIDE",
      title: "Understand your transaction status.",
      description:
          "Status information helps you distinguish between activity that is still being processed, completed successfully, or requires further attention.",
      child: Column(
        children: [
          for (int i = 0; i < statuses.length; i++) ...[
            _StatusRow(
              icon: statuses[i].$1,
              title: statuses[i].$2,
              description: statuses[i].$3,
            ),
            if (i != statuses.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _buildDigitalServicesPanel(bool isMobile) {
    const services = [
      (
        Icons.phone_iphone_rounded,
        "Airtime & Data",
        "MTN, Airtel, Glo, and 9mobile purchases.",
      ),
      (
        Icons.bolt_outlined,
        "Electricity Tokens",
        "Supported electricity token generation and status.",
      ),
      (
        Icons.live_tv_outlined,
        "Cable TV",
        "DSTV, GOTV, and Startimes service activity.",
      ),
      (
        Icons.wifi_rounded,
        "Internet",
        "Supported Spectranet and Smile subscriptions.",
      ),
    ];

    return _contentPanel(
      eyebrow: "DIGITAL SERVICES",
      title: "Track the services you use every day.",
      description:
          "Order Status covers the digital services available through the Gift Technology ecosystem.",
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: services.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isMobile ? 1 : 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 116,
        ),
        itemBuilder: (context, index) {
          final item = services[index];

          return _LuxuryTile(
            icon: item.$1,
            title: item.$2,
            description: item.$3,
          );
        },
      ),
    );
  }

  Widget _buildPaymentsPanel(bool isMobile) {
    return _contentPanel(
      eyebrow: "PAYMENT ACTIVITY",
      title: "Keep your payment information organized.",
      description:
          "For payment-related issues, keep your transaction reference, amount, service, and transaction date available when contacting support.",
      child: Wrap(
        spacing: 9,
        runSpacing: 9,
        children: const [
          _TrackingChip(
            icon: Icons.account_balance_wallet_outlined,
            label: "Wallet",
          ),
          _TrackingChip(
            icon: Icons.credit_card_rounded,
            label: "Card payments",
          ),
          _TrackingChip(
            icon: Icons.account_balance_rounded,
            label: "Bank transfers",
          ),
          _TrackingChip(
            icon: Icons.point_of_sale_rounded,
            label: "POS payments",
          ),
          _TrackingChip(
            icon: Icons.receipt_long_outlined,
            label: "Utility payments",
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessPanel(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 22 : 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _blue.withOpacity(.17),
            _navy.withOpacity(.40),
            Colors.white.withOpacity(.025),
          ],
        ),
        border: Border.all(color: _accent.withOpacity(.10)),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBusinessIcon(),
                const SizedBox(height: 17),
                _buildBusinessCopy(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildBusinessIcon(),
                const SizedBox(width: 18),
                Expanded(child: _buildBusinessCopy()),
              ],
            ),
    );
  }

  Widget _buildBusinessIcon() {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: _accent.withOpacity(.10),
        border: Border.all(color: _accent.withOpacity(.09)),
      ),
      child: const Icon(
        Icons.business_center_rounded,
        color: _accent,
        size: 25,
      ),
    );
  }

  Widget _buildBusinessCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _eyebrow("BUSINESS OPERATIONS"),
        const SizedBox(height: 7),
        const Text(
          "Business activity stays visible.",
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          "Business users can track dashboard payouts and relevant payment activity through the Gift Technology business ecosystem.",
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 11.5,
            height: 1.58,
            color: Colors.white.withOpacity(.45),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            _MiniBadge(label: "Payouts"),
            _MiniBadge(label: "Transactions"),
            _MiniBadge(label: "Dashboard"),
          ],
        ),
      ],
    );
  }

  Widget _buildSupportPanel() {
    return _contentPanel(
      eyebrow: "NEED ASSISTANCE?",
      title: "Our support team can help investigate transaction issues.",
      description:
          "If your transaction does not complete as expected, contact Gift Technology support with the relevant transaction details.",
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          color: Colors.white.withOpacity(.025),
          border: Border.all(color: Colors.white.withOpacity(.055)),
        ),
        child: Row(
          children: [
            const Icon(Icons.mail_outline_rounded, color: _accent, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Official support channel",
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    "support@gifttechnologyltd.com",
                    style: const TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: _accent,
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

  Widget _buildSecurityNotice() {
    return Container(
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withOpacity(.025),
        border: Border.all(color: Colors.white.withOpacity(.055)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, color: _accent, size: 23),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _eyebrow("SECURITY REMINDER"),
                const SizedBox(height: 7),
                const Text(
                  "Never share sensitive account credentials.",
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Gift Technology will not require you to publicly disclose your password, security PIN, OTP, or other authentication credentials when requesting support.",
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 10.5,
                    height: 1.55,
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

  Widget _sectionHeading(String eyebrow, String title, String description) {
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

class _LuxuryTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _LuxuryTile({
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

class _StatusRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _StatusRow({
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
          Icon(icon, color: const Color(0xFF75A1FF), size: 22),
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
  final IconData icon;
  final String label;

  const _TrackingChip({required this.icon, required this.label});

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
          Icon(icon, size: 13, color: const Color(0xFF75A1FF)),
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
