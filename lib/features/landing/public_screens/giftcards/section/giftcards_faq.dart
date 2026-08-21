import 'package:flutter/material.dart';

class GiftCardsFAQSection extends StatefulWidget {
  const GiftCardsFAQSection({super.key});

  @override
  State<GiftCardsFAQSection> createState() => _GiftCardsFAQSectionState();
}

class _GiftCardsFAQSectionState extends State<GiftCardsFAQSection> {
  int? _expandedIndex;

  static const Color navy = Color(0xFF273D68);
  static const Color blue = Color(0xFF4A6BB8);
  static const Color lightBlue = Color(0xFF75A1FF);

  static const List<_FAQ> faqs = [
    _FAQ(
      question: 'How do I redeem a GiftPay gift card?',
      answer:
          'Open GiftPay, go to Gift Cards, select the gift card you purchased, and follow the redemption instructions provided for that brand.',
    ),
    _FAQ(
      question: 'Can I send a gift card to someone else?',
      answer:
          'Yes. GiftPay is designed for digital gifting. You can purchase eligible gift cards for yourself or send them to another recipient.',
    ),
    _FAQ(
      question: 'How quickly are gift cards delivered?',
      answer:
          'Eligible digital gift cards are delivered electronically after a successful transaction. Delivery timing can depend on the specific brand and product.',
    ),
    _FAQ(
      question: 'Do gift cards expire?',
      answer:
          'Expiry rules depend on the individual gift card brand. Always review the terms displayed for the specific card before purchasing or redeeming it.',
    ),
    _FAQ(
      question: 'Can I earn rewards from gift card purchases?',
      answer:
          'Where rewards are available, eligible purchases can contribute to GiftPay rewards or loyalty benefits according to the applicable programme terms.',
    ),
    _FAQ(
      question: 'What happens if my gift card transaction fails?',
      answer:
          'GiftPay records transaction status so you can track the purchase. If a transaction fails, the wallet or payment status is handled according to the transaction outcome and applicable reversal process.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final bool mobile = width < 700;
    final bool tablet = width >= 700 && width < 1100;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: mobile
            ? 16
            : tablet
            ? 24
            : 32,
        vertical: mobile ? 28 : 38,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(mobile ? 20 : 28),
        border: Border.all(color: const Color(0xFFE5EAF3)),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.06),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 4,
                          decoration: BoxDecoration(
                            color: blue,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'HELP CENTRE',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: mobile ? 11 : 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.3,
                            color: blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Frequently asked questions',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: mobile ? 24 : 30,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                        color: navy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Everything you need to know before purchasing and using GiftPay digital gift cards.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        height: 1.55,
                        color: Color(0xFF687386),
                      ),
                    ),
                  ],
                ),
              ),
              if (!mobile) ...[
                const SizedBox(width: 20),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: blue.withOpacity(0.09),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.help_outline_rounded,
                    color: blue,
                    size: 24,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: mobile ? 22 : 30),
          ...List.generate(faqs.length, (index) {
            final faq = faqs[index];
            final bool expanded = _expandedIndex == index;

            return Padding(
              padding: EdgeInsets.only(
                bottom: index == faqs.length - 1 ? 0 : 12,
              ),
              child: _FAQTile(
                faq: faq,
                expanded: expanded,
                onTap: () {
                  setState(() {
                    _expandedIndex = expanded ? null : index;
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _FAQ {
  final String question;
  final String answer;

  const _FAQ({required this.question, required this.answer});
}

class _FAQTile extends StatelessWidget {
  final _FAQ faq;
  final bool expanded;
  final VoidCallback onTap;

  const _FAQTile({
    required this.faq,
    required this.expanded,
    required this.onTap,
  });

  static const Color navy = Color(0xFF273D68);
  static const Color blue = Color(0xFF4A6BB8);
  static const Color lightBlue = Color(0xFF75A1FF);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: expanded ? const Color(0xFFF5F8FF) : const Color(0xFFFAFBFD),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: expanded
              ? lightBlue.withOpacity(0.42)
              : const Color(0xFFE6EAF1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(17),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: expanded
                            ? blue.withOpacity(0.12)
                            : const Color(0xFFEEF2F8),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(
                        expanded ? Icons.remove_rounded : Icons.add_rounded,
                        size: 20,
                        color: expanded ? blue : navy,
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Text(
                        faq.question,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          height: 1.4,
                          fontWeight: FontWeight.w800,
                          color: navy,
                        ),
                      ),
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 200),
                  crossFadeState: expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(left: 47, right: 8, top: 13),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        faq.answer,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          height: 1.6,
                          color: Color(0xFF687386),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
