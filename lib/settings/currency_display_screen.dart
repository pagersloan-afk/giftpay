import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class CurrencyDisplayScreen extends StatefulWidget {
  const CurrencyDisplayScreen({super.key});

  @override
  State<CurrencyDisplayScreen> createState() => _CurrencyDisplayScreenState();
}

class _CurrencyDisplayScreenState extends State<CurrencyDisplayScreen> {
  String selected = "ngn_standard"; // default

  @override
  void initState() {
    super.initState();
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selected = prefs.getString("currency_display") ?? "ngn_standard";
    });
  }

  Future<void> _savePreference(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("currency_display", value);
    setState(() => selected = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeaderr(title: "Currency Display"),

      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        children: [
          const Text(
            "Choose how you want amounts to be displayed across the app.",
            style: TextStyle(
              color: Color(0xFFE5E7EB),
              fontSize: 14,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 28),

          _option(
            title: "₦ 5,000",
            subtitle: "Standard Nigerian Naira format",
            value: "ngn_standard",
          ),

          _divider(),

          _option(
            title: "₦ 5,000.00",
            subtitle: "Show two decimal places",
            value: "ngn_decimal",
          ),

          _divider(),

          _option(
            title: "NGN 5,000",
            subtitle: "Use currency code instead of symbol",
            value: "ngn_code",
          ),

          _divider(),

          _option(
            title: "5,000",
            subtitle: "Hide currency symbol",
            value: "ngn_plain",
          ),

          const SizedBox(height: 40),

          _previewBox(),
        ],
      ),
    );
  }

  // ⭐ OPTION TILE
  Widget _option({
    required String title,
    required String subtitle,
    required String value,
  }) {
    final isSelected = selected == value;

    return InkWell(
      onTap: () => _savePreference(value),
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
    String preview;

    switch (selected) {
      case "ngn_decimal":
        preview = "₦ 12,450.50";
        break;
      case "ngn_code":
        preview = "NGN 12,450";
        break;
      case "ngn_plain":
        preview = "12,450";
        break;
      default:
        preview = "₦ 12,450";
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          const Icon(Icons.visibility, color: Colors.white70, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Preview: $preview",
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
