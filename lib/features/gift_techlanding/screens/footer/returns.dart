import 'package:flutter/material.dart';

import '../gifttech_page_template.dart';

class ReturnsScreen extends StatelessWidget {
  const ReturnsScreen({super.key});

  static const Color _navy = Color(0xFF273D68);
  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _lightBlue = Color(0xFF7EA4FF);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 760;

    return GiftTechPageTemplate(
      title: 'Returns & Refunds',
      description:
          'Understand when a Gift Technology payment may be refunded, how service failures are handled, and the expected processing timelines.',
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
            _sectionLabel('REFUND ELIGIBILITY'),
            const SizedBox(height: 12),
            _eligibilityGrid(isMobile),
            const SizedBox(height: 22),
            _sectionLabel('PROCESSING TIMELINES'),
            const SizedBox(height: 12),
            _timelineSection(isMobile),
            const SizedBox(height: 22),
            _nonRefundableSection(isMobile),
            const SizedBox(height: 22),
            _posSection(isMobile),
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _heroIcon(),
                const SizedBox(width: 22),
                Expanded(child: _heroCopy()),
                const SizedBox(width: 20),
                _statusBadge(),
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
      child: const Icon(
        Icons.currency_exchange_rounded,
        size: 31,
        color: Colors.white,
      ),
    );
  }

  Widget _heroCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GIFT TECHNOLOGY / RETURNS',
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
          'Clear rules.\nFair resolutions.',
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
          'When a qualifying payment or digital service fails, '
          'we provide a defined path for resolution and refund processing.',
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

  Widget _statusBadge() {
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
            'REFUND SUPPORT',
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

  Widget _eligibilityGrid(bool isMobile) {
    const items = [
      _RefundCase(
        Icons.error_outline_rounded,
        'Service failed',
        'A payment was successfully made but the intended service was not completed.',
      ),
      _RefundCase(
        Icons.bolt_outlined,
        'Electricity token',
        'A qualifying electricity payment where the electricity token was not generated.',
      ),
      _RefundCase(
        Icons.phone_android_outlined,
        'Airtime or data',
        'A qualifying purchase where the airtime or data service was not delivered.',
      ),
      _RefundCase(
        Icons.copy_all_outlined,
        'Duplicate charge',
        'The same transaction was charged more than once.',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        mainAxisExtent: 137,
      ),
      itemBuilder: (_, index) => _RefundCaseCard(item: items[index]),
    );
  }

  Widget _timelineSection(bool isMobile) {
    const timelines = [
      _Timeline(
        '01',
        'Digital service failure',
        'Resolution within 24 hours.',
        Icons.flash_on_outlined,
      ),
      _Timeline(
        '02',
        'Wallet refund',
        '1–3 business days.',
        Icons.account_balance_wallet_outlined,
      ),
      _Timeline(
        '03',
        'Bank refund',
        '3–7 business days.',
        Icons.account_balance_outlined,
      ),
      _Timeline(
        '04',
        'POS reversal',
        'Refund eligibility applies where the reversal remains pending beyond 48 hours.',
        Icons.point_of_sale_outlined,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_blue.withOpacity(.11), Colors.white.withOpacity(.035)],
        ),
        border: Border.all(color: _lightBlue.withOpacity(.10)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < timelines.length; i++) ...[
            _TimelineRow(item: timelines[i]),
            if (i != timelines.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 1,
                    height: 15,
                    color: Colors.white.withOpacity(.08),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _nonRefundableSection(bool isMobile) {
    const items = [
      _NonRefundable(
        Icons.phone_android_outlined,
        'Airtime',
        'Non-refundable once delivered.',
      ),
      _NonRefundable(
        Icons.data_usage_outlined,
        'Data',
        'Non-refundable once activated.',
      ),
      _NonRefundable(
        Icons.bolt_outlined,
        'Electricity tokens',
        'Non-refundable once generated.',
      ),
      _NonRefundable(
        Icons.card_giftcard_outlined,
        'Gift cards',
        'Non-refundable once delivered.',
      ),
      _NonRefundable(
        Icons.swap_horiz_rounded,
        'Wallet transfers',
        'Irreversible once completed.',
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
          Text(
            'COMPLETED DIGITAL PRODUCTS',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.8,
              color: _lightBlue,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Completed services are generally final.',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Once a digital product has been successfully delivered, '
            'activated, generated, or completed, it is not refundable under '
            'the supplied returns rules.',
            style: TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 12.8,
              height: 1.55,
              color: Colors.white.withOpacity(.50),
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: items
                .map((item) => _NonRefundableChip(item: item))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _posSection(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_navy.withOpacity(.75), _blue.withOpacity(.12)],
        ),
        border: Border.all(color: _lightBlue.withOpacity(.11)),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_posIcon(), const SizedBox(height: 16), _posCopy()],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _posIcon(),
                const SizedBox(width: 18),
                Expanded(child: _posCopy()),
              ],
            ),
    );
  }

  Widget _posIcon() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _blue.withOpacity(.13),
        border: Border.all(color: _lightBlue.withOpacity(.15)),
      ),
      child: const Icon(
        Icons.point_of_sale_outlined,
        color: _lightBlue,
        size: 24,
      ),
    );
  }

  Widget _posCopy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'POS TRANSACTIONS',
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
          'POS reversals follow applicable bank reversal rules.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'Where a POS reversal remains pending beyond 48 hours, '
          'the transaction qualifies for refund handling under the supplied policy.',
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
        Text(
          'REFUND SUPPORT',
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
          'Need help with a transaction?',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Contact Gift Technology support with the transaction details '
          'so the team can review the payment or service failure.',
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

class _RefundCase {
  final IconData icon;
  final String title;
  final String description;

  const _RefundCase(this.icon, this.title, this.description);
}

class _RefundCaseCard extends StatefulWidget {
  final _RefundCase item;

  const _RefundCaseCard({required this.item});

  @override
  State<_RefundCaseCard> createState() => _RefundCaseCardState();
}

class _RefundCaseCardState extends State<_RefundCaseCard> {
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
              child: Icon(widget.item.icon, size: 21, color: _lightBlue),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.title,
                    style: const TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.item.description,
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

class _Timeline {
  final String number;
  final String title;
  final String description;
  final IconData icon;

  const _Timeline(this.number, this.title, this.description, this.icon);
}

class _TimelineRow extends StatelessWidget {
  final _Timeline item;

  const _TimelineRow({required this.item});

  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _lightBlue = Color(0xFF7EA4FF);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _blue.withOpacity(.11),
            border: Border.all(color: _lightBlue.withOpacity(.14)),
          ),
          child: Icon(item.icon, size: 19, color: _lightBlue),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontFamily: 'SegoeUI',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Text(
                      item.number,
                      style: TextStyle(
                        fontFamily: 'SegoeUI',
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withOpacity(.24),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 12,
                    height: 1.45,
                    color: Colors.white.withOpacity(.49),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NonRefundable {
  final IconData icon;
  final String title;
  final String description;

  const _NonRefundable(this.icon, this.title, this.description);
}

class _NonRefundableChip extends StatelessWidget {
  final _NonRefundable item;

  const _NonRefundableChip({required this.item});

  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _lightBlue = Color(0xFF7EA4FF);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 205,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: _blue.withOpacity(.075),
        border: Border.all(color: _lightBlue.withOpacity(.10)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.icon, size: 17, color: _lightBlue),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.description,
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
