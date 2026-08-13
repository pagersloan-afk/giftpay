import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'contact_card.dart';
import 'contact_scroll_helper.dart';

class ContactGrid extends StatelessWidget {
  const ContactGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController controller = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      autoScroll(controller);
    });

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection("systemConfig")
          .doc("contactDetails")
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 205,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox(
            height: 205,
            child: Center(child: Text("Contact information unavailable")),
          );
        }

        final data = snapshot.data!.data() ?? {};

        final items = [
          {
            "title": "Corporate Office",
            "icon": Icons.location_city,
            "text": data["officeAddress"] ?? "",
          },
          {
            "title": "Email Support",
            "icon": Icons.email,
            "text": data["emailSupport"] ?? "",
          },
          {"title": "Phone", "icon": Icons.phone, "text": data["phone"] ?? ""},
          {
            "title": "Business Partnerships",
            "icon": Icons.handshake,
            "text": data["emailBusiness"] ?? "",
          },
          {
            "title": "Developer Support",
            "icon": Icons.code,
            "text": data["emailDeveloper"] ?? "",
          },
        ];

        return SizedBox(
          height: 205,
          child: SingleChildScrollView(
            controller: controller,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                for (final item in items) ...[
                  ContactCard(
                    title: item["title"],
                    text: item["text"],
                    icon: item["icon"],
                  ),
                  const SizedBox(width: 24),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
