import 'package:utilityhub/settings/model/faq_category.dart';

final faqCategories = [
  FAQCategory(
    title: "Account & Security",
    subtitle: "Login issues, verification, password reset",
    articles: [
      FAQArticle(
        question: "How do I reset my password?",
        answer:
            "Open the GiftPay app → Go to Login → Tap 'Forgot Password' → Enter your email → Follow the reset instructions.",
      ),
      FAQArticle(
        question: "Why can't I log into my account?",
        answer:
            "Ensure your email and password are correct. If the issue persists, reset your password or contact support.",
      ),
    ],
  ),

  FAQCategory(
    title: "Payments & Wallet",
    subtitle: "Funding, withdrawals, transfers",
    articles: [
      FAQArticle(
        question: "My wallet funding is delayed",
        answer:
            "Most funding reflects instantly. If delayed, wait 5–10 minutes. If still pending, contact support with your transaction ID.",
      ),
      FAQArticle(
        question: "How do I withdraw to my bank?",
        answer:
            "Go to Wallet → Withdraw → Enter amount → Select bank → Confirm transaction.",
      ),
    ],
  ),

  FAQCategory(
    title: "Gift Cards",
    subtitle: "Buying, trading, rates, delivery",
    articles: [
      FAQArticle(
        question: "How long does gift card verification take?",
        answer:
            "Gift card verification typically takes 5–15 minutes depending on the card type.",
      ),
      FAQArticle(
        question: "Where can I see current gift card rates?",
        answer:
            "Open the GiftPay app → Gift Cards → Rates. Rates update in real time.",
      ),
    ],
  ),

  FAQCategory(
    title: "Electricity, Airtime & Data",
    subtitle: "Failed transactions, delays, refunds",
    articles: [
      FAQArticle(
        question: "I bought electricity but didn’t receive token",
        answer:
            "Go to Transactions → Select the electricity purchase → Tap 'View Token'. If missing, contact support.",
      ),
      FAQArticle(
        question: "Airtime purchase failed but I was debited",
        answer:
            "Refunds are automatic within 5–10 minutes. If not refunded, contact support.",
      ),
    ],
  ),
];
