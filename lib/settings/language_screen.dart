import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String selected = "en"; // default English

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selected = prefs.getString("app_language") ?? "en";
    });
  }

  Future<void> _saveLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("app_language", lang);
    setState(() => selected = lang);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeaderr(title: "Language"),

      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        children: [
          const Text(
            "Choose your preferred language for the GiftPay app.",
            style: TextStyle(
              color: Color(0xFFE5E7EB),
              fontSize: 14,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 28),

          _option(title: "English", subtitle: "Default language", value: "en"),

          _divider(),

          _option(title: "French", subtitle: "Français", value: "fr"),

          _divider(),

          _option(title: "Spanish", subtitle: "Español", value: "es"),

          _divider(),

          _option(title: "Arabic", subtitle: "العربية", value: "ar"),

          _divider(),

          _option(title: "Portuguese", subtitle: "Português", value: "pt"),

          const SizedBox(height: 40),

          _previewBox(),
        ],
      ),
    );
  }

  // ⭐ LANGUAGE OPTION TILE
  Widget _option({
    required String title,
    required String subtitle,
    required String value,
  }) {
    final isSelected = selected == value;

    return InkWell(
      onTap: () => _saveLanguage(value),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            // TEXTS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.55),
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),

            // RADIO CHECK
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? const Color(0xFF0AC8FF) : Colors.white54,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  // ⭐ DIVIDER
  Widget _divider() {
    return Divider(
      height: 1,
      thickness: 0.8,
      color: Colors.white.withOpacity(0.10),
    );
  }

  // ⭐ PREVIEW BOX
  Widget _previewBox() {
    final previewText = {
      "en": "Hello, how can we help you?",
      "fr": "Bonjour, comment pouvons-nous vous aider?",
      "es": "Hola, ¿cómo podemos ayudarte?",
      "ar": "مرحبًا، كيف يمكننا مساعدتك؟",
      "pt": "Olá, como podemos ajudar você?",
    }[selected]!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          const Icon(Icons.language, color: Colors.white70, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Preview: $previewText",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
