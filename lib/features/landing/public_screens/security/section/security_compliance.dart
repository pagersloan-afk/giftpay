import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class SecurityComplianceSection extends StatelessWidget {
  const SecurityComplianceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    final List<Map<String, dynamic>> items = [
      {
        "title": "PCI‑DSS Compliance",
        "description":
            "GiftPay follows strict PCI‑DSS standards to ensure secure handling of payment data.",
        "icon": Icons.verified_user_outlined,
      },
      {
        "title": "ISO 27001 Practices",
        "description":
            "Industry‑standard security management processes and continuous risk assessment.",
        "icon": Icons.security_outlined,
      },
      {
        "title": "GDPR & Data Privacy",
        "description":
            "User data is protected with transparent policies, encryption, and strict privacy controls.",
        "icon": Icons.privacy_tip_outlined,
      },
      {
        "title": "24/7 Monitoring",
        "description":
            "Real‑time infrastructure monitoring ensures uptime, reliability, and rapid threat response.",
        "icon": Icons.monitor_heart_outlined,
      },
    ];

    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: isMobile
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Text(
            "Compliance & Standards",
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w800,
              fontSize: isMobile ? 22 : 26,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),

          Wrap(
            spacing: isMobile ? 16 : 20,
            runSpacing: isMobile ? 16 : 20,
            alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
            children: items.map((item) {
              return _ComplianceCard(
                title: item["title"]!,
                description: item["description"]!,
                icon: item["icon"] as IconData,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ComplianceCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _ComplianceCard({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      width: isMobile ? double.infinity : 260,
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.70),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: isMobile
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32, color: GiftPayTheme.primaryBlue),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: isMobile ? 15 : 17,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: isMobile ? 13 : 14,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
