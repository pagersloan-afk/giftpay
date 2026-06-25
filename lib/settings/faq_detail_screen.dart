import 'package:flutter/material.dart';
import 'package:utilityhub/settings/model/faq_category.dart';

class FAQDetailScreen extends StatelessWidget {
  final FAQArticle article;

  const FAQDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article.question),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF0F1115),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          article.answer,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
