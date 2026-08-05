import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class CareersOpeningsSection extends StatelessWidget {
  const CareersOpeningsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    final openings = [
      {
        "title": "Senior Flutter Engineer",
        "location": "Remote • Full‑time",
        "route": "/careers/flutter",
      },
      {
        "title": "Backend Engineer (Node.js)",
        "location": "Remote • Full‑time",
        "route": "/careers/backend",
      },
      {
        "title": "Product Designer",
        "location": "Hybrid • Lagos",
        "route": "/careers/design",
      },
      {
        "title": "DevOps Engineer",
        "location": "Remote • Full‑time",
        "route": "/careers/devops",
      },
    ];

    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: isMobile
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          // ⭐ TAG TEXT — upgraded to stand out
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 14 : 18,
              vertical: isMobile ? 6 : 8,
            ),
            decoration: BoxDecoration(
              color: GiftPayTheme.primaryBlue.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "Open Roles",
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w800,
                fontSize: isMobile ? 20 : 24,
                color: const Color.fromARGB(255, 186, 198, 211),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ⭐ SINGLE ROW SCROLL
          SizedBox(
            height: isMobile ? 210 : 230,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: openings.length,
              separatorBuilder: (_, __) => const SizedBox(width: 20),
              itemBuilder: (_, index) {
                final job = openings[index];
                return _JobCard(
                  title: job["title"]!,
                  location: job["location"]!,
                  route: job["route"]!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final String title;
  final String location;
  final String route;

  const _JobCard({
    required this.title,
    required this.location,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      width: isMobile ? 260 : 300, // ⭐ Card width for single-row scroll
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.65),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.30), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: isMobile
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: isMobile ? 16 : 18,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            location,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: isMobile ? 13 : 14,
              color: Colors.black54,
            ),
          ),

          const Spacer(),

          // ⭐ Upgraded CTA button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, route);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: GiftPayTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 20 : 24,
                  vertical: isMobile ? 10 : 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                "View Role",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
