import 'package:flutter/material.dart';
import 'package:utilityhub/features/landing/public_screens/help/section/giftpay_help_navigation.dart';

class GiftPayHelpContent extends StatelessWidget {
  final void Function(GlobalKey key) onSectionTap;

  const GiftPayHelpContent({super.key, required this.onSectionTap});

  static const Color navy = Color(0xFF273D68);
  static const Color blue = Color(0xFF4A6BB8);
  static const Color lightBlue = Color(0xFF75A1FF);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HelpSection(
          key: GiftPayHelpNavigation.gettingStartedKey,
          icon: Icons.rocket_launch_outlined,
          eyebrow: 'GETTING STARTED',
          title: 'Getting started with GiftPay',
          description:
              'Learn the basics of using GiftPay and discover the services available to you.',
          articles: const [
            _HelpArticle(
              question: 'What is GiftPay?',
              answer:
                  'GiftPay is a digital services platform designed to make everyday payments, digital purchases and other supported services easier to access from one place.',
            ),
            _HelpArticle(
              question: 'How do I start using GiftPay?',
              answer:
                  'Create or access your GiftPay account, complete any required verification and select the service you want to use from the available products.',
            ),
            _HelpArticle(
              question: 'Which services are available?',
              answer:
                  'Availability may include airtime, data, electricity, TV, gift cards, flights and other services supported by GiftPay. Available services can vary by location and account eligibility.',
            ),
          ],
        ),
        const SizedBox(height: 20),

        _HelpSection(
          key: GiftPayHelpNavigation.accountKey,
          icon: Icons.person_outline_rounded,
          eyebrow: 'ACCOUNT',
          title: 'Account & verification',
          description:
              'Manage your account and understand why GiftPay may request verification.',
          articles: const [
            _HelpArticle(
              question: 'Why do I need to verify my account?',
              answer:
                  'Verification helps protect your account, support secure transactions and allow GiftPay to meet applicable identity and security requirements.',
            ),
            _HelpArticle(
              question: 'What information may be required?',
              answer:
                  'Depending on the service, GiftPay may request identity, contact or other information needed to verify your account and provide the requested service.',
            ),
            _HelpArticle(
              question: 'What if I cannot complete verification?',
              answer:
                  'Check that the information you provide is accurate and matches your identification documents. If the issue continues, contact GiftPay support for assistance.',
            ),
          ],
        ),
        const SizedBox(height: 20),

        _HelpSection(
          key: GiftPayHelpNavigation.paymentsKey,
          icon: Icons.payments_outlined,
          eyebrow: 'PAYMENTS',
          title: 'Payments & transactions',
          description:
              'Understand payment processing, transaction status and common payment issues.',
          articles: const [
            _HelpArticle(
              question: 'How do I make a payment?',
              answer:
                  'Select the service you need, provide the required details, review the transaction information and complete payment using the available payment method.',
            ),
            _HelpArticle(
              question: 'Where can I see my transaction history?',
              answer:
                  'Your transaction history is available through your GiftPay account where supported. Transaction records can show the status and details of completed or attempted transactions.',
            ),
            _HelpArticle(
              question: 'Why is my transaction pending?',
              answer:
                  'A pending transaction may still be processing or waiting for confirmation from a third-party service provider. Allow processing time before attempting the transaction again.',
            ),
          ],
        ),
        const SizedBox(height: 20),

        _HelpSection(
          key: GiftPayHelpNavigation.giftCardsKey,
          icon: Icons.card_giftcard_outlined,
          eyebrow: 'GIFT CARDS',
          title: 'Gift cards',
          description:
              'Get help purchasing, receiving and using GiftPay digital gift cards.',
          articles: const [
            _HelpArticle(
              question: 'How do I purchase a gift card?',
              answer:
                  'Open the Gift Cards section, select a category or available brand, choose the desired value and complete the purchase.',
            ),
            _HelpArticle(
              question: 'Can I send a gift card to another person?',
              answer:
                  'Eligible digital gift cards can be purchased for another recipient. Follow the delivery information presented during checkout.',
            ),
            _HelpArticle(
              question: 'Why has my gift card not arrived?',
              answer:
                  'Check your transaction status and the delivery information associated with the purchase. If the transaction was successful but the card has not arrived, contact support with your transaction details.',
            ),
          ],
        ),
        const SizedBox(height: 20),

        _HelpSection(
          key: GiftPayHelpNavigation.airtimeKey,
          icon: Icons.phone_android_rounded,
          eyebrow: 'MOBILE SERVICES',
          title: 'Airtime & data',
          description: 'Get help with mobile airtime and data purchases.',
          articles: const [
            _HelpArticle(
              question: 'How do I buy airtime?',
              answer:
                  'Select Airtime, choose the relevant network, enter the recipient number and amount, then review and complete the transaction.',
            ),
            _HelpArticle(
              question: 'How do I purchase data?',
              answer:
                  'Select Data, choose the applicable network and bundle, enter the recipient information and complete the payment.',
            ),
            _HelpArticle(
              question: 'What if I entered the wrong phone number?',
              answer:
                  'Contact GiftPay support as soon as possible with your transaction reference. Reversal or correction may depend on the transaction status and network provider.',
            ),
          ],
        ),
        const SizedBox(height: 20),

        _HelpSection(
          key: GiftPayHelpNavigation.billsKey,
          icon: Icons.receipt_long_outlined,
          eyebrow: 'BILLS & UTILITIES',
          title: 'Bills & utilities',
          description:
              'Information about electricity, TV and other supported utility payments.',
          articles: const [
            _HelpArticle(
              question: 'How do I pay an electricity bill?',
              answer:
                  'Select Electricity, choose the applicable provider, enter the required meter or customer information and complete the transaction.',
            ),
            _HelpArticle(
              question: 'How do I pay for TV services?',
              answer:
                  'Select TV, choose your provider and subscription option, enter the required customer information and complete payment.',
            ),
            _HelpArticle(
              question: 'What happens if a bill payment fails?',
              answer:
                  'Check the transaction status first. If payment was unsuccessful but funds were deducted, allow the applicable reversal process to complete or contact support with your transaction reference.',
            ),
          ],
        ),
        const SizedBox(height: 20),

        _HelpSection(
          key: GiftPayHelpNavigation.flightsKey,
          icon: Icons.flight_takeoff_rounded,
          eyebrow: 'AVIATION',
          title: 'Flights & travel',
          description:
              'Find help with flight searches, bookings and travel transactions.',
          articles: const [
            _HelpArticle(
              question: 'How do I search for a flight?',
              answer:
                  'Open the Flights service, enter your departure and destination information, travel dates and passenger details, then search the available options.',
            ),
            _HelpArticle(
              question: 'Can I book a flight as a guest?',
              answer:
                  'Public flight information may be available without signing in. Booking and payment requirements can vary depending on the flight service and transaction.',
            ),
            _HelpArticle(
              question: 'What if my flight booking needs assistance?',
              answer:
                  'Keep your booking or transaction reference and contact GiftPay support. Airline-specific changes and cancellation rules may also apply.',
            ),
          ],
        ),
        const SizedBox(height: 20),

        _HelpSection(
          key: GiftPayHelpNavigation.walletKey,
          icon: Icons.account_balance_wallet_outlined,
          eyebrow: 'WALLET',
          title: 'Wallet & balances',
          description:
              'Understand wallet balances, deposits and supported wallet activity.',
          articles: const [
            _HelpArticle(
              question: 'How can I check my wallet balance?',
              answer:
                  'Your available wallet balance is displayed in the wallet area of your GiftPay account when wallet functionality is enabled for your account.',
            ),
            _HelpArticle(
              question: 'Why has my wallet balance not updated?',
              answer:
                  'Some transactions require confirmation before your available balance changes. Review your transaction history and allow the applicable processing time.',
            ),
            _HelpArticle(
              question: 'Can I use my wallet for every service?',
              answer:
                  'Wallet availability depends on the service and applicable payment options. GiftPay will display the available payment methods when you initiate a transaction.',
            ),
          ],
        ),
        const SizedBox(height: 20),

        _HelpSection(
          key: GiftPayHelpNavigation.refundsKey,
          icon: Icons.currency_exchange_rounded,
          eyebrow: 'REFUNDS',
          title: 'Refunds & reversals',
          description:
              'What to do when a transaction fails, is reversed or requires review.',
          articles: const [
            _HelpArticle(
              question: 'What is a transaction reversal?',
              answer:
                  'A reversal occurs when a transaction cannot be completed and the associated funds are returned according to the applicable payment and service-provider process.',
            ),
            _HelpArticle(
              question:
                  'My account was charged but the service was not delivered.',
              answer:
                  'Do not repeat the transaction immediately. Check the transaction status and contact support with your reference number so the transaction can be investigated.',
            ),
            _HelpArticle(
              question: 'How long does a refund take?',
              answer:
                  'Refund timing can depend on the payment method, transaction status and third-party provider involved. GiftPay support can assist with transaction-specific enquiries.',
            ),
          ],
        ),
        const SizedBox(height: 20),

        _HelpSection(
          key: GiftPayHelpNavigation.securityKey,
          icon: Icons.shield_outlined,
          eyebrow: 'SECURITY',
          title: 'Security & fraud prevention',
          description: 'Keep your GiftPay account and transactions protected.',
          articles: const [
            _HelpArticle(
              question: 'How do I protect my GiftPay account?',
              answer:
                  'Use a strong password, keep your login credentials private and avoid signing in through suspicious links or untrusted devices.',
            ),
            _HelpArticle(
              question: 'Will GiftPay ask for my password or PIN?',
              answer:
                  'Never share your password, PIN, authentication codes or other confidential credentials with another person. If you receive a suspicious request, contact GiftPay through an official support channel.',
            ),
            _HelpArticle(
              question: 'What should I do if I suspect fraud?',
              answer:
                  'Secure your account immediately and contact GiftPay support with relevant transaction information. Do not continue communicating with a suspected fraudster.',
            ),
          ],
        ),
        const SizedBox(height: 20),

        _HelpSection(
          key: GiftPayHelpNavigation.troubleshootingKey,
          icon: Icons.build_outlined,
          eyebrow: 'TROUBLESHOOTING',
          title: 'Common problems',
          description: 'Simple steps for resolving common GiftPay issues.',
          articles: const [
            _HelpArticle(
              question: 'The GiftPay website is not loading correctly.',
              answer:
                  'Refresh the page, check your internet connection and try again using an updated browser. If the issue continues, contact support.',
            ),
            _HelpArticle(
              question: 'A button or service is not responding.',
              answer:
                  'Refresh the page and retry after a short period. If the problem persists, record the service and action that caused the issue and contact support.',
            ),
            _HelpArticle(
              question: 'I cannot find my transaction.',
              answer:
                  'Confirm that you are signed into the correct account and check your transaction history. If you still cannot locate it, contact support with the transaction details.',
            ),
          ],
        ),
        const SizedBox(height: 20),

        _HelpSection(
          key: GiftPayHelpNavigation.contactKey,
          icon: Icons.mail_outline_rounded,
          eyebrow: 'SUPPORT',
          title: 'Contact GiftPay support',
          description:
              'If you cannot find the answer you need, our support team can help with account and transaction-specific questions.',
          articles: const [
            _HelpArticle(
              question: 'What information should I provide to support?',
              answer:
                  'Provide your account email or relevant identifier, transaction reference, service involved and a clear description of the issue. Never send your password, PIN or authentication codes.',
            ),
            _HelpArticle(
              question: 'When should I contact support?',
              answer:
                  'Contact support when a transaction requires investigation, a service has not been delivered, you suspect fraud, or the available Help Centre information does not resolve your issue.',
            ),
          ],
          showContactButton: true,
        ),
      ],
    );
  }
}

class _HelpSection extends StatelessWidget {
  final IconData icon;
  final String eyebrow;
  final String title;
  final String description;
  final List<_HelpArticle> articles;
  final bool showContactButton;

  const _HelpSection({
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
            color: const Color(0xFF273D68).withOpacity(0.055),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        key: key,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: mobile ? 42 : 48,
                height: mobile ? 42 : 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A6BB8).withOpacity(0.09),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF4A6BB8),
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
                        color: Color(0xFF4A6BB8),
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
                        color: const Color(0xFF273D68),
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
              child: _HelpArticleTile(article: article),
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
                  backgroundColor: const Color(0xFF4A6BB8),
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

class _HelpArticle {
  final String question;
  final String answer;

  const _HelpArticle({required this.question, required this.answer});
}

class _HelpArticleTile extends StatefulWidget {
  final _HelpArticle article;

  const _HelpArticleTile({required this.article});

  @override
  State<_HelpArticleTile> createState() => _HelpArticleTileState();
}

class _HelpArticleTileState extends State<_HelpArticleTile> {
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
              ? const Color(0xFF75A1FF).withOpacity(0.40)
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
                            ? const Color(0xFF4A6BB8).withOpacity(0.11)
                            : const Color(0xFFEEF2F8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _expanded ? Icons.remove_rounded : Icons.add_rounded,
                        size: 19,
                        color: _expanded
                            ? const Color(0xFF4A6BB8)
                            : const Color(0xFF273D68),
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
                          color: Color(0xFF273D68),
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
