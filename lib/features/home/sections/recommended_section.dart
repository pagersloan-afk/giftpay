import 'package:flutter/material.dart';
import '../widgets/home_service_card.dart';

class RecommendedSection extends StatelessWidget {
  const RecommendedSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recommended for You",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE5E7EB),
          ),
        ),

        const SizedBox(height: 16),

        SizedBox(
          height: isMobile ? 180 : 220,
          child: GridView.count(
            crossAxisCount: isMobile ? 3 : 4,
            childAspectRatio: 1,
            physics: const BouncingScrollPhysics(),
            children: const [
              HomeServiceCard(
                title: "Electricity",
                icon: Icons.flash_on,
                route: "/electricity",
              ),
              HomeServiceCard(
                title: "Airtime",
                icon: Icons.phone_android,
                route: "/airtime",
              ),
              HomeServiceCard(
                title: "Cable TV",
                icon: Icons.tv,
                route: "/cable",
              ),
            ],
          ),
        ),
      ],
    );
  }
}
