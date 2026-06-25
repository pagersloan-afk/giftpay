import 'package:flutter/material.dart';
import 'package:utilityhub/settings/model/faq_category.dart';
import 'faq_detail_screen.dart';

class FAQArticlesScreen extends StatelessWidget {
  final FAQCategory category;

  const FAQArticlesScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF0F1115),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: category.articles.map((article) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              article.question,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.white54),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FAQDetailScreen(article: article),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
