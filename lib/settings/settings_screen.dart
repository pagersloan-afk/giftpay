import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';
import 'package:utilityhub/core/widgets/app_responsive_layout.dart';
import 'components/settings_card.dart';
import 'components/section_title.dart';
import 'sections/account_security_section.dart';
import 'sections/preferences_section.dart';
import 'sections/notifications_section.dart';
import 'sections/support_legal_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05070A),
      appBar: const AppHeaderr(title: "Settings"),

      body: Stack(
        children: [
          // ⭐ FIXED CENTER WATERMARK (does NOT scroll)
          Positioned.fill(
            child: Center(
              child: Opacity(
                opacity: 0.06, // subtle, premium, non-intrusive
                child: Image.asset(
                  "assets/logo/giftpay_1.png", // your new shield logo
                  width: 420,
                  height: 420,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // ⭐ Scrollable content ABOVE watermark
          AppResponsiveLayout(child: _buildContent(context)),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth > 900;
        final double horizontal = isDesktop ? 24 : 16;
        final double maxWidth = isDesktop ? 720 : double.infinity;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SectionTitle("Account & Security"),
                  SizedBox(height: 8),
                  SettingsCard(child: AccountSecuritySection()),

                  SizedBox(height: 24),
                  SectionTitle("Preferences"),
                  SizedBox(height: 8),
                  SettingsCard(child: PreferencesSection()),

                  SizedBox(height: 24),
                  SectionTitle("Notifications"),
                  SizedBox(height: 8),
                  SettingsCard(child: NotificationsSection()),

                  SizedBox(height: 24),
                  SectionTitle("Support & Legal"),
                  SizedBox(height: 8),
                  SettingsCard(child: SupportLegalSection()),

                  SizedBox(height: 40),
                  Center(
                    child: Text(
                      "GiftPay v1.0.0",
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
