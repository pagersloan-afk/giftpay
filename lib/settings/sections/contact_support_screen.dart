import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  // ⭐ WHATSAPP DEEP LINK
  Future<void> openWhatsApp(String phone, String message) async {
    final encodedMessage = Uri.encodeComponent(message);
    final whatsappUrl = Uri.parse("https://wa.me/$phone?text=$encodedMessage");

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      throw "Could not open WhatsApp";
    }
  }

  // ⭐ CALL DEEP LINK
  Future<void> callNumber(String phone) async {
    final uri = Uri(scheme: "tel", path: phone);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw "Could not launch phone dialer";
    }
  }

  // ⭐ EMAIL DEEP LINK
  Future<void> sendEmail(String email) async {
    final uri = Uri(
      scheme: "mailto",
      path: email,
      query: "subject=GiftPay Support&body=Hello GiftPay Support,",
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw "Could not open email app";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contact Support"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF0F1115),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ⭐ CHAT
          _sectionHeader("Chat", "Avg. response time: 1 min"),
          _chatItem(
            title: "Support Chat",
            subtitle: "Start a conversation on live chat",
            onTap: () {},
          ),
          _chatItem(
            title: "WhatsApp",
            subtitle: "Start a conversation on WhatsApp",
            onTap: () {
              openWhatsApp(
                "2349010853849",
                "Hello GiftPay Support, I need help with...",
              );
            },
          ),

          const SizedBox(height: 30),

          // ⭐ CALL
          _sectionHeader("Call", "Avg. response time: 2 min"),
          _callItem(
            phone: "+234 901 085 3849",
            onTap: () {
              callNumber("09010853849");
            },
          ),

          const SizedBox(height: 30),

          // ⭐ EMAIL
          _sectionHeader("Email", "Avg. response time: 12 hrs"),
          _emailItem(
            email: "support@giftpayhq.com",
            onTap: () {
              sendEmail("support@giftpayhq.com");
            },
          ),

          const SizedBox(height: 30),

          // ⭐ SUPPORT PORTAL
          _sectionHeader("Support", null),
          _supportPortalItem(context: context),

          const SizedBox(height: 30),

          // ⭐ SOCIAL MEDIA
          _sectionHeader("Social Media", null),
          _socialMediaRow(),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, String? subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _chatItem({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54)),
      trailing: const Icon(Icons.chat_bubble_outline, color: Colors.white70),
      onTap: onTap,
    );
  }

  Widget _callItem({required String phone, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(phone, style: const TextStyle(color: Colors.white)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0AC8FF),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text("Call", style: TextStyle(color: Colors.black)),
      ),
      onTap: onTap,
    );
  }

  Widget _emailItem({required String email, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(email, style: const TextStyle(color: Colors.white)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0AC8FF),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text("Email", style: TextStyle(color: Colors.black)),
      ),
      onTap: onTap,
    );
  }

  Widget _supportPortalItem({required BuildContext context}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text(
        "GiftPay Support Portal",
        style: TextStyle(color: Colors.white),
      ),
      subtitle: const Text(
        "Read articles & FAQs on how to use GiftPay.",
        style: TextStyle(color: Colors.white54),
      ),
      trailing: const Text(
        "Read Now >",
        style: TextStyle(color: Color(0xFF0AC8FF)),
      ),
      onTap: () {
        Navigator.pushNamed(context, "/help-center");
      },
    );
  }

  Widget _socialMediaRow() {
    return Row(
      children: const [
        Icon(Icons.facebook, color: Colors.white),
        SizedBox(width: 20),
        Icon(Icons.camera_alt, color: Colors.white),
        SizedBox(width: 20),
        Icon(Icons.alternate_email, color: Colors.white),
      ],
    );
  }
}
