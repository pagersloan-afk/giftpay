import 'package:flutter/material.dart';

class GiftPayFaqNavigation extends StatelessWidget {
  final void Function(GlobalKey key) onSectionTap;
  final bool mobile;

  const GiftPayFaqNavigation({
    super.key,
    required this.onSectionTap,
    this.mobile = false,
  });

  static const Color navy = Color(0xFF273D68);
  static const Color blue = Color(0xFF4A6BB8);

  static final GlobalKey generalKey = GlobalKey();
  static final GlobalKey accountKey = GlobalKey();
  static final GlobalKey paymentsKey = GlobalKey();
  static final GlobalKey giftCardsKey = GlobalKey();
  static final GlobalKey airtimeKey = GlobalKey();
  static final GlobalKey billsKey = GlobalKey();
  static final GlobalKey flightsKey = GlobalKey();
  static final GlobalKey walletKey = GlobalKey();
  static final GlobalKey refundsKey = GlobalKey();
  static final GlobalKey securityKey = GlobalKey();
  static final GlobalKey troubleshootingKey = GlobalKey();
  static final GlobalKey contactKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final items = <_FaqNavigationItem>[
      _FaqNavigationItem(
        title: 'General questions',
        icon: Icons.help_outline_rounded,
        keyRef: generalKey,
      ),
      _FaqNavigationItem(
        title: 'Account & verification',
        icon: Icons.person_outline_rounded,
        keyRef: accountKey,
      ),
      _FaqNavigationItem(
        title: 'Payments',
        icon: Icons.payments_outlined,
        keyRef: paymentsKey,
      ),
      _FaqNavigationItem(
        title: 'Gift cards',
        icon: Icons.card_giftcard_outlined,
        keyRef: giftCardsKey,
      ),
      _FaqNavigationItem(
        title: 'Airtime & data',
        icon: Icons.phone_android_rounded,
        keyRef: airtimeKey,
      ),
      _FaqNavigationItem(
        title: 'Bills & utilities',
        icon: Icons.receipt_long_outlined,
        keyRef: billsKey,
      ),
      _FaqNavigationItem(
        title: 'Flights & travel',
        icon: Icons.flight_takeoff_rounded,
        keyRef: flightsKey,
      ),
      _FaqNavigationItem(
        title: 'Wallet',
        icon: Icons.account_balance_wallet_outlined,
        keyRef: walletKey,
      ),
      _FaqNavigationItem(
        title: 'Refunds & reversals',
        icon: Icons.currency_exchange_rounded,
        keyRef: refundsKey,
      ),
      _FaqNavigationItem(
        title: 'Security',
        icon: Icons.shield_outlined,
        keyRef: securityKey,
      ),
      _FaqNavigationItem(
        title: 'Troubleshooting',
        icon: Icons.build_outlined,
        keyRef: troubleshootingKey,
      ),
      _FaqNavigationItem(
        title: 'Contact support',
        icon: Icons.mail_outline_rounded,
        keyRef: contactKey,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(mobile ? 16 : 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(mobile ? 19 : 22),
        border: Border.all(color: const Color(0xFFE4E9F1)),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.055),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FAQ CATEGORIES',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: blue,
            ),
          ),
          const SizedBox(height: 13),
          if (mobile)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.map((item) {
                return InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => onSectionTap(item.keyRef),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FB),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0xFFE4E8F0)),
                    ),
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: navy,
                      ),
                    ),
                  ),
                );
              }).toList(),
            )
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: InkWell(
                  borderRadius: BorderRadius.circular(11),
                  onTap: () => onSectionTap(item.keyRef),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 9,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item.icon,
                          size: 17,
                          color: const Color(0xFF7C8798),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: navy,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FaqNavigationItem {
  final String title;
  final IconData icon;
  final GlobalKey keyRef;

  const _FaqNavigationItem({
    required this.title,
    required this.icon,
    required this.keyRef,
  });
}
