import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class AirtimeDistributionScreen extends StatelessWidget {
  const AirtimeDistributionScreen({super.key});

  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _lightBlue = Color(0xFF7EA4FF);

  @override
  Widget build(BuildContext context) {
    return GiftTechPageTemplate(
      eyebrow: 'GIFT TECHNOLOGY / DIGITAL DISTRIBUTION',
      title: 'Airtime\nDistribution',
      description:
          'A streamlined airtime distribution service for individuals, agents, resellers, and businesses across Nigeria.',
      icon: Icons.phone_android_rounded,
      metaLabel: 'SERVICE',
      metaValue: 'Airtime Distribution',
      secondaryMetaLabel: 'NETWORKS',
      secondaryMetaValue: 'MTN • Airtel • Glo • 9mobile',
      child: const _AirtimeDistributionContent(),
    );
  }
}

class _AirtimeDistributionContent extends StatelessWidget {
  const _AirtimeDistributionContent();

  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _lightBlue = Color(0xFF7EA4FF);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 760;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _networkHero(isMobile),
          const SizedBox(height: 20),
          _sectionLabel('NETWORK COVERAGE'),
          const SizedBox(height: 12),
          _networkGrid(isMobile),
          const SizedBox(height: 20),
          _distributionSection(isMobile),
          const SizedBox(height: 20),
          _useCases(isMobile),
          const SizedBox(height: 20),
          _processSection(isMobile),
          const SizedBox(height: 20),
          _transactionSection(isMobile),
          const SizedBox(height: 20),
          _supportSection(isMobile),
        ],
      ),
    );
  }

  Widget _networkHero(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(27),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF273D68), Color(0xFF355792), Color(0xFF101A2D)],
        ),
        border: Border.all(color: Colors.white.withOpacity(.11)),
        boxShadow: [
          BoxShadow(
            color: _blue.withOpacity(.17),
            blurRadius: 36,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _airtimeIcon(),
                const SizedBox(height: 18),
                _heroCopy(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _airtimeIcon(),
                const SizedBox(width: 20),
                Expanded(child: _heroCopy()),
                const SizedBox(width: 22),
                _coverageBadge(),
              ],
            ),
    );
  }

  Widget _airtimeIcon() {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(.075),
        border: Border.all(color: Colors.white.withOpacity(.14)),
        boxShadow: [
          BoxShadow(color: _lightBlue.withOpacity(.18), blurRadius: 30),
        ],
      ),
      child: const Icon(
        Icons.phone_android_rounded,
        color: Colors.white,
        size: 32,
      ),
    );
  }

  Widget _heroCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CONNECTED DIGITAL DISTRIBUTION',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
            color: Colors.white.withOpacity(.62),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Airtime distribution built around simple, reliable delivery.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 22,
            height: 1.18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -.3,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          'Gift Technology provides airtime vending across Nigeria’s four '
          'major mobile networks, supporting everyday top-ups and business '
          'distribution through its digital platform.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 12.8,
            height: 1.6,
            color: Colors.white.withOpacity(.60),
          ),
        ),
      ],
    );
  }

  Widget _coverageBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white.withOpacity(.07),
        border: Border.all(color: Colors.white.withOpacity(.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.signal_cellular_alt_rounded,
            size: 15,
            color: _lightBlue,
          ),
          const SizedBox(width: 7),
          Text(
            '4 NETWORKS',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Colors.white.withOpacity(.70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _networkGrid(bool isMobile) {
    const networks = [
      _Network('MTN', 'Airtime top-up', Icons.network_cell_rounded),
      _Network('Airtel', 'Airtime top-up', Icons.network_cell_rounded),
      _Network('Glo', 'Airtime top-up', Icons.network_cell_rounded),
      _Network('9mobile', 'Airtime top-up', Icons.network_cell_rounded),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: networks.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: isMobile ? 92 : 104,
      ),
      itemBuilder: (_, index) => _NetworkCard(network: networks[index]),
    );
  }

  Widget _distributionSection(bool isMobile) {
    return _ContentPanel(
      isMobile: isMobile,
      icon: Icons.hub_outlined,
      label: 'DISTRIBUTION',
      title: 'One service layer for everyday airtime needs.',
      body:
          'The airtime service is designed to simplify distribution across '
          'supported networks. Individuals can use it for personal top-ups, '
          'while agents, resellers, and businesses can use the platform as '
          'part of their digital distribution operations.',
    );
  }

  Widget _useCases(bool isMobile) {
    const items = [
      _UseCase(
        Icons.person_outline_rounded,
        'Personal top-ups',
        'Recharge supported Nigerian mobile numbers through the Gift Technology ecosystem.',
      ),
      _UseCase(
        Icons.storefront_outlined,
        'Agents & resellers',
        'Support airtime distribution as part of a digital retail or resale operation.',
      ),
      _UseCase(
        Icons.business_outlined,
        'Business distribution',
        'Distribute airtime to customers, teams, beneficiaries, or other recipients.',
      ),
      _UseCase(
        Icons.api_outlined,
        'Digital platforms',
        'Airtime vending is part of the services available through the GiftPay API ecosystem.',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('BUILT FOR DIFFERENT NEEDS'),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 1 : 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            mainAxisExtent: isMobile ? 116 : 126,
          ),
          itemBuilder: (_, index) => _UseCaseCard(useCase: items[index]),
        ),
      ],
    );
  }

  Widget _processSection(bool isMobile) {
    const steps = [
      _Step('01', 'Select a network', 'Choose MTN, Airtel, Glo, or 9mobile.'),
      _Step(
        '02',
        'Provide recipient details',
        'Enter the mobile number and the required airtime amount.',
      ),
      _Step(
        '03',
        'Confirm the transaction',
        'Review the transaction details before submitting the purchase.',
      ),
      _Step(
        '04',
        'Track the outcome',
        'Transaction records provide visibility into completed and pending activity.',
      ),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_blue.withOpacity(.10), Colors.white.withOpacity(.028)],
        ),
        border: Border.all(color: _lightBlue.withOpacity(.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('HOW IT WORKS'),
          const SizedBox(height: 8),
          const Text(
            'A simple distribution flow.',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 17),
          ...List.generate(
            steps.length,
            (index) => Padding(
              padding: EdgeInsets.only(
                bottom: index == steps.length - 1 ? 0 : 13,
              ),
              child: _StepRow(step: steps[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _transactionSection(bool isMobile) {
    return _ContentPanel(
      isMobile: isMobile,
      icon: Icons.receipt_long_outlined,
      label: 'TRANSACTION VISIBILITY',
      title: 'Designed around traceable transactions.',
      body:
          'Airtime purchases form part of the transaction history available '
          'within GiftPay. Payment metadata and transaction records help users '
          'and business operators keep track of activity and investigate '
          'service issues when necessary.',
    );
  }

  Widget _supportSection(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF101A2D), Color(0xFF1D2E50)],
        ),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _supportCopy(),
                const SizedBox(height: 18),
                _contactCard(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _supportCopy()),
                const SizedBox(width: 28),
                SizedBox(width: 330, child: _contactCard()),
              ],
            ),
    );
  }

  Widget _supportCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('SUPPORT'),
        const SizedBox(height: 8),
        const Text(
          'Need help with an airtime transaction?',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'If airtime was purchased but not delivered, or you need help '
          'understanding a transaction, contact Gift Technology support with '
          'your transaction details and payment reference where available.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 12.7,
            height: 1.58,
            color: Colors.white.withOpacity(.50),
          ),
        ),
      ],
    );
  }

  Widget _contactCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        color: Colors.white.withOpacity(.045),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _contactRow(Icons.email_outlined, 'support@gifttechnologyltd.com'),
          const SizedBox(height: 12),
          _contactRow(Icons.phone_outlined, '+234 901 085 3849'),
          const SizedBox(height: 12),
          _contactRow(
            Icons.location_on_outlined,
            'Port Harcourt, Rivers, Nigeria',
          ),
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: _lightBlue),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 12,
              height: 1.45,
              color: Colors.white.withOpacity(.58),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'SegoeUI',
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.8,
        color: _lightBlue,
      ),
    );
  }
}

class _Network {
  final String name;
  final String subtitle;
  final IconData icon;

  const _Network(this.name, this.subtitle, this.icon);
}

class _NetworkCard extends StatefulWidget {
  final _Network network;

  const _NetworkCard({required this.network});

  @override
  State<_NetworkCard> createState() => _NetworkCardState();
}

class _NetworkCardState extends State<_NetworkCard> {
  bool _hovered = false;

  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _lightBlue = Color(0xFF7EA4FF);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(_hovered ? .075 : .045),
              Colors.white.withOpacity(.018),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(_hovered ? .13 : .065),
          ),
          boxShadow: [
            BoxShadow(
              color: _blue.withOpacity(_hovered ? .12 : .035),
              blurRadius: _hovered ? 25 : 16,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: _blue.withOpacity(.11),
                border: Border.all(color: _lightBlue.withOpacity(.14)),
              ),
              child: Icon(widget.network.icon, size: 21, color: _lightBlue),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.network.name,
                    style: const TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.network.subtitle,
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 11.7,
                      color: Colors.white.withOpacity(.47),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: Colors.white.withOpacity(.25),
            ),
          ],
        ),
      ),
    );
  }
}

class _UseCase {
  final IconData icon;
  final String title;
  final String description;

  const _UseCase(this.icon, this.title, this.description);
}

class _UseCaseCard extends StatefulWidget {
  final _UseCase useCase;

  const _UseCaseCard({required this.useCase});

  @override
  State<_UseCaseCard> createState() => _UseCaseCardState();
}

class _UseCaseCardState extends State<_UseCaseCard> {
  bool _hovered = false;

  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _lightBlue = Color(0xFF7EA4FF);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(_hovered ? .055 : .035),
          border: Border.all(
            color: Colors.white.withOpacity(_hovered ? .12 : .06),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: _blue.withOpacity(.10),
                border: Border.all(color: _lightBlue.withOpacity(.14)),
              ),
              child: Icon(widget.useCase.icon, size: 21, color: _lightBlue),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.useCase.title,
                    style: const TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 14.2,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.useCase.description,
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

class _Step {
  final String number;
  final String title;
  final String description;

  const _Step(this.number, this.title, this.description);
}

class _StepRow extends StatelessWidget {
  final _Step step;

  const _StepRow({required this.step});

  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _lightBlue = Color(0xFF7EA4FF);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 39,
          height: 39,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _blue.withOpacity(.11),
            border: Border.all(color: _lightBlue.withOpacity(.15)),
          ),
          child: Text(
            step.number,
            style: const TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: _lightBlue,
            ),
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step.title,
                style: const TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 13.8,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                step.description,
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 11.8,
                  height: 1.45,
                  color: Colors.white.withOpacity(.48),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContentPanel extends StatelessWidget {
  final bool isMobile;
  final IconData icon;
  final String label;
  final String title;
  final String body;

  const _ContentPanel({
    required this.isMobile,
    required this.icon,
    required this.label,
    required this.title,
    required this.body,
  });

  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _lightBlue = Color(0xFF7EA4FF);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_blue.withOpacity(.10), Colors.white.withOpacity(.028)],
        ),
        border: Border.all(color: _lightBlue.withOpacity(.10)),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_icon(), const SizedBox(height: 16), _copy()],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _icon(),
                const SizedBox(width: 18),
                Expanded(child: _copy()),
              ],
            ),
    );
  }

  Widget _icon() {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _blue.withOpacity(.11),
        border: Border.all(color: _lightBlue.withOpacity(.15)),
      ),
      child: Icon(icon, color: _lightBlue, size: 25),
    );
  }

  Widget _copy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
            color: _lightBlue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          body,
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 12.7,
            height: 1.6,
            color: Colors.white.withOpacity(.52),
          ),
        ),
      ],
    );
  }
}
