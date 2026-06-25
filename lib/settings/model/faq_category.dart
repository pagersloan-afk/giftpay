class FAQCategory {
  final String title;
  final String subtitle;
  final List<FAQArticle> articles;

  FAQCategory({
    required this.title,
    required this.subtitle,
    required this.articles,
  });
}

class FAQArticle {
  final String question;
  final String answer;

  FAQArticle({required this.question, required this.answer});
}
