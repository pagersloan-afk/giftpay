import 'package:flutter/material.dart';
import 'giftpay_faq_navigation.dart';

class GiftPayFaqContent extends StatelessWidget {
  final void Function(GlobalKey key) onSectionTap;

  const GiftPayFaqContent({super.key, required this.onSectionTap});

  static const Color navy = Color(0xFF273D68);
  static const Color blue = Color(0xFF4A6BB8);
  static const Color lightBlue = Color(0xFF75A1FF);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _FaqSection(
          key: GiftPayFaqNavigation.generalKey,
          icon: Icons.help_outline_rounded,
          eyebrow: 'GENERAL',
          title: 'General questions',
          description:
              'Answers to common questions about GiftPay and how the platform works.',
          articles: const [
            _FaqArticle(
              question: 'What is GiftPay?',
              answer:
                  'GiftPay is a digital services platform designed to make everyday payments, digital purchases and supported services easier to access from one place.',
            ),
            _FaqArticle(
              question: 'What can I use GiftPay for?',
              answer:
                  'Depending on availability, GiftPay may support airtime, data, electricity, TV, gift cards, flights and other digital services.',
            ),
            _FaqArticle(
              question: 'Do I need an account to use GiftPay?',
              answer:
                  'Some public information and services may be available without an account, while account-based features may require registration and verification.',
            ),
          ],
        ),
        const SizedBox(height: 20),

        _FaqSection(
          key: GiftPayFaqNavigation.accountKey,
          icon: Icons.person_outline_rounded,
          eyebrow: 'ACCOUNT',
          title: 'Account & verification',
          description:
              'Everything you need to know about creating, securing and verifying your GiftPay account.',
          articles: const [
            _FaqArticle(
              question: 'Why does GiftPay require verification?',
              answer:
                  'Verification helps protect your account, support secure transactions and meet applicable identity and security requirements.',
            ),
            _FaqArticle(
              question: 'What information may I need to provide?',
              answer:
                  'Depending on the service, GiftPay may request identity, contact or other information required to verify your account.',
            ),
            _FaqArticle(
              question: 'What happens if I cannot complete verification?',
              answer:
                  'Make sure the information you provide is accurate and matches your identification documents. If you continue experiencing problems, contact GiftPay support.',
            ),
          ],
        ),
        const SizedBox(height: 20),

        _FaqSection(
          key: GiftPayFaqNavigation.paymentsKey,
          icon: Icons.payments_outlined,
          eyebrow: 'PAYMENTS',
          title: 'Payments & transactions',
          description:
              'Learn how GiftPay payments work and what to do when a transaction is pending or unsuccessful.',
          articles: const [
            _FaqArticle(
              question: 'How do I make a payment?',
              answer:
                  'Select the service you need, enter the required information, review the transaction details and complete the payment using an available payment method.',
            ),
            _FaqArticle(
              question: 'Where can I find my transaction history?',
              answer:
                  'When supported, your transaction history is available from your GiftPay account and can show transaction references, amounts and statuses.',
            ),
            _FaqArticle(
              question: 'Why is my transaction pending?',
              answer:
                  'A pending transaction may still be processing or waiting for confirmation from a third-party service provider. Allow the applicable processing time before attempting another transaction.',
            ),
            _FaqArticle(
              question:
                  'What should I do if I was charged but the transaction failed?',
              answer:
                  'Check the transaction status first. If funds were deducted but the service was not completed, keep your transaction reference and contact GiftPay support.',
            ),
          ],
        ),
        const SizedBox(height: 20),

        _FaqSection(
          key: GiftPayFaqNavigation.giftCardsKey,
          icon: Icons.card_giftcard_outlined,
          eyebrow: 'GIFT CARDS',
          title: 'Gift cards',
          description:
              'Common questions about purchasing and receiving digital gift cards.',
          articles: const [
            _FaqArticle(
              question: 'How do I purchase a gift card?',
              answer:
                  'Open the Gift Cards service, select an available brand or category, choose your preferred value and complete the purchase.',
            ),
            _FaqArticle(
              question: 'Can I purchase a gift card for someone else?',
              answer:
                  'Eligible digital gift cards may be purchased for another recipient. Follow the recipient and delivery information shown during checkout.',
            ),
            _FaqArticle(
              question: 'Why have I not received my gift card?',
              answer:
                  'Check the transaction status and delivery information associated with the purchase. If the transaction was successful but the gift card has not arrived, contact support with your transaction reference.',
            ),
          ],
        ),
        const SizedBox(height: 20),

        _FaqSection(
          key: GiftPayFaqNavigation.airtimeKey,
          icon: Icons.phone_android_rounded,
          eyebrow: 'MOBILE SERVICES',
          title: 'Airtime & data',
          description: 'Get answers about airtime and mobile data purchases.',
          articles: const [
            _FaqArticle(
              question: 'How do I buy airtime?',
              answer:
                  'Select Airtime, choose the relevant network, enter the recipient number and amount, review the transaction and complete payment.',
            ),
            _FaqArticle(
              question: 'How do I buy data?',
              answer:
                  'Select Data, choose the applicable network and bundle, enter the recipient information and complete the payment.',
            ),
            _FaqArticle(
              question: 'What if I entered the wrong phone number?',
              answer:
                  'Contact GiftPay support as soon as possible with your transaction reference. Any reversal or correction may depend on the transaction status and network provider.',
            ),
          ],
        ),
        const SizedBox(height: 20),

        _FaqSection(
          key: GiftPayFaqNavigation.billsKey,
          icon: Icons.receipt_long_outlined,
          eyebrow: 'BILLS & UTILITIES',
          title: 'Bills & utilities',
          description:
              'Questions about electricity, television and other supported utility services.',
          articles: const [
            _FaqArticle(
              question: 'How do I pay an electricity bill?',
              answer:
                  'Select Electricity, choose the applicable provider, enter the required meter or customer information and complete the transaction.',
            ),
            _FaqArticle(
              question: 'How do I pay for TV services?',
              answer:
                  'Select TV, choose your provider and subscription option, enter the required customer information and complete payment.',
            ),
            _FaqArticle(
              question: 'What happens when a bill payment fails?',
              answer:
                  'Check the transaction status first. If payment was unsuccessful but funds were deducted, allow the applicable reversal process to complete or contact support with your transaction reference.',
            ),
          ],
        ),
        const SizedBox(height: 20),

        _FaqSection(
          key: GiftPayFaqNavigation.flightsKey,
          icon: Icons.flight_takeoff_rounded,
          eyebrow: 'TRAVEL',
          title: 'Flights & travel',
          description:
              'Find answers about searching for and booking flights through GiftPay.',
          articles: const [
            _FaqArticle(
              question: 'How do I search for a flight?',
              answer:
                  'Open the Flights service, enter your departure and destination, travel dates and passenger information, then search the available options.',
            ),
            _FaqArticle(
              question: 'Can I book a flight as a guest?',
              answer:
                  'Public flight information may be available without signing in. Booking and payment requirements can vary depending on the available flight service.',
            ),
            _FaqArticle(
              question: 'What if I need help with a flight booking?',
              answer:
                  'Keep your booking or transaction reference and contact GiftPay support. Airline-specific change, cancellation and refund policies may also apply.',
            ),
          ],
        ),
        const SizedBox(height: 20),

        _FaqSection(
          key: GiftPayFaqNavigation.walletKey,
          icon: Icons.account_balance_wallet_outlined,
          eyebrow: 'WALLET',
          title: 'Wallet & balances',
          description:
              'Understand your GiftPay wallet, balances and supported wallet activity.',
          articles: const [
            _FaqArticle(
              question: 'How do I check my wallet balance?',
              answer:
                  'When wallet functionality is enabled for your account, your available balance is displayed in the wallet area of GiftPay.',
            ),
            _FaqArticle(
              question: 'Why has my wallet balance not updated?',
              answer:
                  'Some transactions require confirmation before the available balance changes. Review your transaction history and allow the applicable processing time.',
            ),
            _FaqArticle(
              question: 'Can I use my wallet for every GiftPay service?',
              answer:
                  'Wallet availability depends on the service and applicable payment options. GiftPay displays the available payment methods when you initiate a transaction.',
            ),
          ],
        ),
        const SizedBox(height: 20),

        _FaqSection(
          key: GiftPayFaqNavigation.refundsKey,
          icon: Icons.currency_exchange_rounded,
          eyebrow: 'REFUNDS',
          title: 'Refunds & reversals',
          description:
              'Learn what happens when a transaction is reversed, refunded or requires investigation.',
          articles: const [
            _FaqArticle(
              question: 'What is a transaction reversal?',
              answer:
                  'A reversal occurs when a transaction cannot be completed and the associated funds are returned according to the applicable payment and service-provider process.',
            ),
            _FaqArticle(
              question:
                  'My account was charged but the service was not delivered. What should I do?',
              answer:
                  'Do not immediately repeat the transaction. Check the transaction status and contact support with your transaction reference so the issue can be investigated.',
            ),
            _FaqArticle(
              question: 'How long does a refund take?',
              answer:
                  'Refund timing can depend on the payment method, transaction status and third-party provider involved. Contact GiftPay support for transaction-specific assistance.',
            ),
          ],
        ),
        const SizedBox(height: 20),

        _FaqSection(
          key: GiftPayFaqNavigation.securityKey,
          icon: Icons.shield_outlined,
          eyebrow: 'SECURITY',
          title: 'Security & fraud prevention',
          description:
              'Important information for keeping your GiftPay account and transactions secure.',
          articles: const [
            _FaqArticle(
              question: 'How do I protect my GiftPay account?',
              answer:
                  'Use a strong password, keep your credentials private and avoid signing into GiftPay through suspicious links or untrusted devices.',
            ),
            _FaqArticle(
              question:
                  'Should I share my password, PIN or authentication code?',
              answer:
                  'No. Never share your password, PIN, authentication codes or other confidential credentials with another person.',
            ),
            _FaqArticle(
              question: 'What should I do if I suspect fraud?',
              answer:
                  'Secure your account immediately and contact GiftPay through an official support channel. Keep relevant transaction information available for investigation.',
            ),
          ],
        ),
        const SizedBox(height: 20),

        _FaqSection(
          key: GiftPayFaqNavigation.troubleshootingKey,
          icon: Icons.build_outlined,
          eyebrow: 'TROUBLESHOOTING',
          title: 'Common problems',
          description:
              'Quick answers for common GiftPay website and service issues.',
          articles: const [
            _FaqArticle(
              question: 'The GiftPay website is not loading correctly.',
              answer:
                  'Refresh the page, check your internet connection and try again using an updated browser. If the problem continues, contact GiftPay support.',
            ),
            _FaqArticle(
              question: 'A service or button is not responding.',
              answer:
                  'Refresh the page and retry after a short period. If the issue persists, note the service and action that caused the problem and contact support.',
            ),
            _FaqArticle(
              question: 'I cannot find my transaction.',
              answer:
                  'Confirm that you are signed into the correct account and check your transaction history. If you still cannot locate it, contact support with the transaction details.',
            ),
          ],
        ),
        const SizedBox(height: 20),

        _FaqSection(
          key: GiftPayFaqNavigation.contactKey,
          icon: Icons.mail_outline_rounded,
          eyebrow: 'SUPPORT',
          title: 'Contact GiftPay support',
          description:
              'If your question is not answered here, GiftPay support can assist with account and transaction-specific issues.',
          articles: const [
            _FaqArticle(
              question: 'What information should I provide to support?',
              answer:
                  'Provide your account email or relevant identifier, transaction reference, service involved and a clear description of the issue. Never send your password, PIN or authentication codes.',
            ),
            _FaqArticle(
              question: 'When should I contact GiftPay support?',
              answer:
                  'Contact support when a transaction requires investigation, a service has not been delivered, you suspect fraud or the available FAQ information does not resolve your issue.',
            ),
          ],
          showContactButton: true,
        ),
      ],
    );
  }
}

class _FaqSection extends StatelessWidget {
  final IconData icon;
  final String eyebrow;
  final String title;
  final String description;
  final List<_FaqArticle> articles;
  final bool showContactButton;

  const _FaqSection({
    super.key,
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.articles,
    this.showContactButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 700;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(mobile ? 18 : 30),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(mobile ? 20 : 26),
        border: Border.all(color: const Color(0xFFE4E9F1)),
        boxShadow: [
          BoxShadow(
            color: GiftPayFaqContent.navy.withOpacity(0.055),
            blurRadius: 30,
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
              Container(
                width: mobile ? 42 : 48,
                height: mobile ? 42 : 48,
                decoration: BoxDecoration(
                  color: GiftPayFaqContent.blue.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: GiftPayFaqContent.blue,
                  size: mobile ? 21 : 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eyebrow,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.3,
                        color: GiftPayFaqContent.blue,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: mobile ? 22 : 28,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                        color: GiftPayFaqContent.navy,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              height: 1.55,
              color: Color(0xFF687386),
            ),
          ),
          SizedBox(height: mobile ? 18 : 24),
          ...articles.map(
            (article) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _FaqArticleTile(article: article),
            ),
          ),
          if (showContactButton) ...[
            const SizedBox(height: 5),
            SizedBox(
              height: 46,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.support_agent_rounded, size: 19),
                label: const Text(
                  'Contact GiftPay Support',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GiftPayFaqContent.blue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FaqArticle {
  final String question;
  final String answer;

  const _FaqArticle({required this.question, required this.answer});
}

class _FaqArticleTile extends StatefulWidget {
  final _FaqArticle article;

  const _FaqArticleTile({required this.article});

  @override
  State<_FaqArticleTile> createState() => _FaqArticleTileState();
}

class _FaqArticleTileState extends State<_FaqArticleTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: _expanded ? const Color(0xFFF5F8FF) : const Color(0xFFFAFBFD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _expanded
              ? GiftPayFaqContent.lightBlue.withOpacity(0.40)
              : const Color(0xFFE5E9F0),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _expanded = !_expanded;
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 33,
                      height: 33,
                      decoration: BoxDecoration(
                        color: _expanded
                            ? GiftPayFaqContent.blue.withOpacity(0.11)
                            : const Color(0xFFEEF2F8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _expanded ? Icons.remove_rounded : Icons.add_rounded,
                        size: 19,
                        color: _expanded
                            ? GiftPayFaqContent.blue
                            : GiftPayFaqContent.navy,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.article.question,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          height: 1.4,
                          fontWeight: FontWeight.w800,
                          color: GiftPayFaqContent.navy,
                        ),
                      ),
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 200),
                  crossFadeState: _expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(left: 45, right: 8, top: 12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.article.answer,
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

class _FaqAnswerText extends StatelessWidget {
  const _FaqAnswerText();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
