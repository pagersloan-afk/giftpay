import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class UtilitiesHubScreen extends StatelessWidget {
  const UtilitiesHubScreen({super.key});

  static const Color _navy = Color(0xFF273D68);
  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _lightBlue = Color(0xFF7EA4FF);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 760;

    return GiftTechPageTemplate(
      title: 'Utilities Hub',
      description:
          'One digital hub for essential everyday services — from electricity and airtime to data, cable TV, and internet subscriptions.',
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
            _sectionLabel('LIVE SERVICES'),
            const SizedBox(height: 12),
            _serviceGrid(isMobile),
            const SizedBox(height: 22),
            _electricitySection(isMobile),
            const SizedBox(height: 22),
            _whySection(isMobile),
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
              children: [_heroIcon(), const SizedBox(height: 20), _heroCopy()],
            )
          : Row(
              children: [
                _heroIcon(),
                const SizedBox(width: 22),
                Expanded(child: _heroCopy()),
                const SizedBox(width: 25),
                _liveBadge(),
              ],
            ),
    );
  }

  Widget _heroIcon() {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(.08),
        border: Border.all(color: Colors.white.withOpacity(.14)),
        boxShadow: [
          BoxShadow(color: _lightBlue.withOpacity(.20), blurRadius: 28),
        ],
      ),
      child: const Icon(Icons.bolt_rounded, size: 32, color: Colors.white),
    );
  }

  Widget _heroCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GIFT TECHNOLOGY / UTILITIES',
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
          'Essential services,\nbeautifully connected.',
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
          'Use GiftPay to access everyday digital utility services '
          'from one connected experience.',
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
              color: Color(0xFF7EA4FF),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'LIVE SERVICES',
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

  Widget _serviceGrid(bool isMobile) {
    const services = [
      _Service(
        Icons.bolt_outlined,
        'Electricity',
        'Pay electricity bills and generate tokens through supported distribution companies.',
      ),
      _Service(
        Icons.phone_android_outlined,
        'Airtime',
        'Purchase airtime across MTN, Airtel, Glo, and 9mobile.',
      ),
      _Service(
        Icons.network_cell_outlined,
        'Data',
        'Buy mobile data bundles across supported Nigerian networks.',
      ),
      _Service(
        Icons.tv_outlined,
        'Cable TV',
        'Pay subscriptions for DSTV, GOTV, and Startimes.',
      ),
      _Service(
        Icons.wifi_outlined,
        'Internet',
        'Manage supported internet subscriptions including Spectranet and Smile.',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        mainAxisExtent: isMobile ? 132 : 142,
      ),
      itemBuilder: (_, index) => _ServiceCard(service: services[index]),
    );
  }

  Widget _electricitySection(bool isMobile) {
    const providers = [
      'PHED',
      'AEDC',
      'IKEDC',
      'EEDC',
      'KEDCO',
      'JED',
      'BEDC',
      'IBEDC',
    ];

    return _panel(
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _panelIcon(Icons.electric_bolt_outlined),
                const SizedBox(height: 16),
                _electricityCopy(),
                const SizedBox(height: 20),
                _providerWrap(providers),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _panelIcon(Icons.electric_bolt_outlined),
                const SizedBox(width: 18),
                Expanded(child: _electricityCopy()),
                const SizedBox(width: 25),
                SizedBox(width: 300, child: _providerWrap(providers)),
              ],
            ),
    );
  }

  Widget _electricityCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ELECTRICITY',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.7,
            color: _lightBlue,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'Electricity payments in one place.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'GiftPay supports electricity services across the listed distribution '
          'companies, including token generation where applicable.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 12.8,
            height: 1.55,
            color: Colors.white.withOpacity(.52),
          ),
        ),
      ],
    );
  }

  Widget _providerWrap(List<String> providers) {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: providers
          .map(
            (provider) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: _blue.withOpacity(.10),
                border: Border.all(color: _lightBlue.withOpacity(.12)),
              ),
              child: Text(
                provider,
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withOpacity(.70),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _whySection(bool isMobile) {
    const points = [
      _Point(
        Icons.hub_outlined,
        'One connected hub',
        'Access multiple everyday services from a single digital experience.',
      ),
      _Point(
        Icons.receipt_long_outlined,
        'Transaction history',
        'Keep track of utility purchases and related transaction activity.',
      ),
      _Point(
        Icons.security_outlined,
        'Built for secure access',
        'Services operate within the security and account controls of the GiftPay ecosystem.',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('THE GIFT TECHNOLOGY EXPERIENCE'),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: points.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 1 : 3,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            mainAxisExtent: 155,
          ),
          itemBuilder: (_, index) => _PointCard(point: points[index]),
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
        Text(
          'NEED HELP?',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
            color: _lightBlue,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'We are here when you need us.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'For utility-payment or service issues, contact Gift Technology support.',
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

class _Service {
  final IconData icon;
  final String title;
  final String description;

  const _Service(this.icon, this.title, this.description);
}

class _ServiceCard extends StatefulWidget {
  final _Service service;

  const _ServiceCard({required this.service});

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _hovered = false;

  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _lightBlue = Color(0xFF7EA4FF);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
        padding: const EdgeInsets.all(19),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(21),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(_hovered ? .08 : .055),
              Colors.white.withOpacity(.02),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(_hovered ? .14 : .07),
          ),
          boxShadow: [
            BoxShadow(
              color: _blue.withOpacity(_hovered ? .12 : .035),
              blurRadius: _hovered ? 28 : 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: _blue.withOpacity(.11),
                border: Border.all(color: _lightBlue.withOpacity(.14)),
              ),
              child: Icon(widget.service.icon, size: 22, color: _lightBlue),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.service.title,
                    style: const TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.service.description,
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 11.8,
                      height: 1.48,
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

class _Point {
  final IconData icon;
  final String title;
  final String description;

  const _Point(this.icon, this.title, this.description);
}

class _PointCard extends StatelessWidget {
  final _Point point;

  const _PointCard({required this.point});

  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _lightBlue = Color(0xFF7EA4FF);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(.04),
        border: Border.all(color: Colors.white.withOpacity(.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: _blue.withOpacity(.10),
            ),
            child: Icon(point.icon, size: 20, color: _lightBlue),
          ),
          const Spacer(),
          Text(
            point.title,
            style: const TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            point.description,
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 11.5,
              height: 1.45,
              color: Colors.white.withOpacity(.46),
            ),
          ),
        ],
      ),
    );
  }
}
