import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class GiftPayWalletScreen extends StatelessWidget {
  const GiftPayWalletScreen({super.key});

  static const Color _navy = Color(0xFF273D68);
  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _lightBlue = Color(0xFF7EA4FF);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 760;

    return GiftTechPageTemplate(
      title: 'GiftPay Wallet',
      description:
          'A connected digital wallet for funding, transfers, withdrawals, everyday payments, utilities, and secure account management.',
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          isMobile ? 16 : 28,
          8,
          isMobile ? 16 : 28,
          36,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _hero(isMobile),
            const SizedBox(height: 22),
            _sectionLabel('LIVE WALLET CAPABILITIES'),
            const SizedBox(height: 12),
            _capabilityGrid(isMobile),
            const SizedBox(height: 22),
            _fundingSection(isMobile),
            const SizedBox(height: 22),
            _securitySection(isMobile),
            const SizedBox(height: 22),
            _merchantSection(isMobile),
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
          colors: [Color(0xFF273D68), Color(0xFF314F8A), Color(0xFF101A2D)],
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
              children: [
                _walletIcon(),
                const SizedBox(height: 20),
                _heroCopy(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _walletIcon(),
                const SizedBox(width: 22),
                Expanded(child: _heroCopy()),
                const SizedBox(width: 24),
                _liveBadge(),
              ],
            ),
    );
  }

  Widget _walletIcon() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(.08),
        border: Border.all(color: Colors.white.withOpacity(.14)),
        boxShadow: [
          BoxShadow(color: _lightBlue.withOpacity(.22), blurRadius: 30),
        ],
      ),
      child: const Icon(
        Icons.account_balance_wallet_outlined,
        size: 32,
        color: Colors.white,
      ),
    );
  }

  Widget _heroCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GIFTPAY / DIGITAL WALLET',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.9,
            color: Colors.white.withOpacity(.64),
          ),
        ),
        const SizedBox(height: 9),
        const Text(
          'Your money.\nYour everyday wallet.',
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
          'Fund your wallet, move money, pay for essential services, '
          'and manage your transactions from one connected GiftPay experience.',
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

  Widget _liveBadge() {
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
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _lightBlue,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'LIVE CAPABILITIES',
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

  Widget _capabilityGrid(bool isMobile) {
    const capabilities = [
      _Capability(
        Icons.add_card_outlined,
        'Fund wallet',
        'Add money through bank transfer, card, or USSD.',
      ),
      _Capability(
        Icons.account_balance_outlined,
        'Withdraw to bank',
        'Move available wallet funds to a bank account.',
      ),
      _Capability(
        Icons.swap_horiz_rounded,
        'Transfer money',
        'Transfer funds to other GiftPay users.',
      ),
      _Capability(
        Icons.phone_android_outlined,
        'Buy airtime',
        'Purchase airtime across supported Nigerian networks.',
      ),
      _Capability(
        Icons.network_cell_outlined,
        'Buy data',
        'Purchase mobile data bundles through GiftPay.',
      ),
      _Capability(
        Icons.bolt_outlined,
        'Pay utilities',
        'Buy electricity tokens and pay supported utility services.',
      ),
      _Capability(
        Icons.receipt_long_outlined,
        'Transaction history',
        'Review wallet activity and transaction records.',
      ),
      _Capability(
        Icons.notifications_none_rounded,
        'Notifications',
        'Receive account and transaction notifications.',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: capabilities.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        mainAxisExtent: isMobile ? 122 : 132,
      ),
      itemBuilder: (_, index) =>
          _CapabilityCard(capability: capabilities[index]),
    );
  }

  Widget _fundingSection(bool isMobile) {
    const methods = [
      _FundingMethod(
        Icons.account_balance_outlined,
        'Bank transfer',
        'Fund the wallet through supported bank transfer channels.',
      ),
      _FundingMethod(
        Icons.credit_card_outlined,
        'Card',
        'Use a supported payment card to fund your wallet.',
      ),
      _FundingMethod(
        Icons.dialpad_rounded,
        'USSD',
        'Use supported USSD funding options for wallet deposits.',
      ),
    ];

    return _panel(
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _panelIcon(Icons.payments_outlined),
                const SizedBox(height: 16),
                _fundingCopy(),
                const SizedBox(height: 18),
                ...methods.map(
                  (method) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _FundingRow(method: method),
                  ),
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _panelIcon(Icons.payments_outlined),
                const SizedBox(width: 18),
                Expanded(child: _fundingCopy()),
                const SizedBox(width: 24),
                SizedBox(
                  width: 330,
                  child: Column(
                    children: methods
                        .map(
                          (method) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _FundingRow(method: method),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _fundingCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('FUNDING & MOVEMENT'),
        const SizedBox(height: 8),
        const Text(
          'Move money the way that works for you.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'GiftPay supports wallet funding through bank transfer, card, '
          'and USSD, alongside withdrawals and transfers within the available service.',
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

  Widget _securitySection(bool isMobile) {
    const security = [
      _SecurityFeature(
        Icons.verified_user_outlined,
        'KYC verification',
        'Identity verification is available for wallet users as required by the service.',
      ),
      _SecurityFeature(
        Icons.pin_outlined,
        'Security PIN',
        'A dedicated security PIN provides an additional account control.',
      ),
      _SecurityFeature(
        Icons.phonelink_lock_outlined,
        '2FA',
        'Two-factor authentication adds another layer of account protection.',
      ),
      _SecurityFeature(
        Icons.notifications_active_outlined,
        'Notifications',
        'Stay informed about wallet and transaction activity.',
      ),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.white.withOpacity(.035),
        border: Border.all(color: Colors.white.withOpacity(.075)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('SECURITY & ACCOUNT CONTROL'),
          const SizedBox(height: 8),
          const Text(
            'Designed around control.',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'GiftPay includes KYC verification, a security PIN, 2FA, '
            'and transaction notifications as part of the live wallet experience.',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 12.8,
              height: 1.55,
              color: Colors.white.withOpacity(.50),
            ),
          ),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: security.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 1 : 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 108,
            ),
            itemBuilder: (_, index) => _SecurityCard(feature: security[index]),
          ),
        ],
      ),
    );
  }

  Widget _merchantSection(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_navy.withOpacity(.80), _blue.withOpacity(.12)],
        ),
        border: Border.all(color: _lightBlue.withOpacity(.11)),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _merchantIcon(),
                const SizedBox(height: 16),
                _merchantCopy(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _merchantIcon(),
                const SizedBox(width: 18),
                Expanded(child: _merchantCopy()),
              ],
            ),
    );
  }

  Widget _merchantIcon() {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _blue.withOpacity(.13),
        border: Border.all(color: _lightBlue.withOpacity(.15)),
      ),
      child: const Icon(Icons.storefront_outlined, color: _lightBlue, size: 25),
    );
  }

  Widget _merchantCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('FOR BUSINESSES'),
        const SizedBox(height: 7),
        const Text(
          'A wallet experience that connects with business operations.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'GiftPay also provides a business dashboard for merchants, '
          'bringing wallet activity and business operations into the wider GiftPay ecosystem.',
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
        color: Colors.white.withOpacity(.035),
        border: Border.all(color: Colors.white.withOpacity(.075)),
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
        _sectionLabel('WALLET SUPPORT'),
        const SizedBox(height: 8),
        const Text(
          'Need help with your wallet?',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Contact Gift Technology support for account, wallet, '
          'payment, or transaction-related assistance.',
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

  Widget _panel({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_blue.withOpacity(.11), Colors.white.withOpacity(.035)],
        ),
        border: Border.all(color: _lightBlue.withOpacity(.10)),
      ),
      child: child,
    );
  }

  Widget _panelIcon(IconData icon) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _blue.withOpacity(.12),
        border: Border.all(color: _lightBlue.withOpacity(.16)),
      ),
      child: Icon(icon, color: _lightBlue, size: 25),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'SegoeUI',
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.8,
        color: _lightBlue,
      ),
    );
  }
}

class _Capability {
  final IconData icon;
  final String title;
  final String description;

  const _Capability(this.icon, this.title, this.description);
}

class _CapabilityCard extends StatefulWidget {
  final _Capability capability;

  const _CapabilityCard({required this.capability});

  @override
  State<_CapabilityCard> createState() => _CapabilityCardState();
}

class _CapabilityCardState extends State<_CapabilityCard> {
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
              color: _blue.withOpacity(_hovered ? .12 : .035),
              blurRadius: _hovered ? 27 : 18,
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
              child: Icon(widget.capability.icon, size: 21, color: _lightBlue),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.capability.title,
                    style: const TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.capability.description,
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

class _FundingMethod {
  final IconData icon;
  final String title;
  final String description;

  const _FundingMethod(this.icon, this.title, this.description);
}

class _FundingRow extends StatelessWidget {
  final _FundingMethod method;

  const _FundingRow({required this.method});

  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _lightBlue = Color(0xFF7EA4FF);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(.035),
        border: Border.all(color: Colors.white.withOpacity(.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _blue.withOpacity(.10),
            ),
            child: Icon(method.icon, size: 17, color: _lightBlue),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  method.title,
                  style: const TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  method.description,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 10.7,
                    height: 1.4,
                    color: Colors.white.withOpacity(.46),
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

class _SecurityFeature {
  final IconData icon;
  final String title;
  final String description;

  const _SecurityFeature(this.icon, this.title, this.description);
}

class _SecurityCard extends StatelessWidget {
  final _SecurityFeature feature;

  const _SecurityCard({required this.feature});

  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _lightBlue = Color(0xFF7EA4FF);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        color: _blue.withOpacity(.055),
        border: Border.all(color: Colors.white.withOpacity(.06)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              color: _blue.withOpacity(.11),
            ),
            child: Icon(feature.icon, size: 18, color: _lightBlue),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: const TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 12.8,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feature.description,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 10.8,
                    height: 1.4,
                    color: Colors.white.withOpacity(.46),
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
