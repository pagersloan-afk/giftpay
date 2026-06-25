import 'package:flutter/material.dart';
import 'package:utilityhub/settings/data/faq_data.dart';
import 'package:utilityhub/settings/faq_articles_screen.dart';
import 'package:utilityhub/settings/model/faq_category.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help Center"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF0F1115),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "How can we help you?",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            "Browse articles, FAQs, and guides to get help using GiftPay.",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),

          const SizedBox(height: 30),

          // ⭐ FAQ CATEGORIES
          ...faqCategories.map((category) {
            return _categoryItem(context: context, category: category);
          }).toList(),

          const SizedBox(height: 40),

          // ⭐ CONTACT SUPPORT CTA
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, "/contact-support");
              },
              child: const Text(
                "Still need help? Contact Support",
                style: TextStyle(color: Color(0xFF0AC8FF), fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryItem({
    required BuildContext context,
    required FAQCategory category,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.help_outline, color: Colors.white, size: 28),
      title: Text(
        category.title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      subtitle: Text(
        category.subtitle,
        style: const TextStyle(color: Colors.white54, fontSize: 13),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FAQArticlesScreen(category: category),
          ),
        );
      },
    );
  }
}
