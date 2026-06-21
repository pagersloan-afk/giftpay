import 'package:flutter/material.dart';
import '../widgets/home_service_card.dart';

class ServicesSection extends StatelessWidget {
  const ServicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Services",
          style: TextStyle(
            fontSize: 11.50, // ⭐ slightly smaller like Moniepoint
            fontWeight: FontWeight.w500,
            color: Color(0xFFE5E7EB),
          ),
        ),

        const SizedBox(height: 14),

        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,

          // ⭐ Moniepoint uses a compact, tall-enough cell
          childAspectRatio: 0.95,

          children: const [
            HomeServiceCard(
              title: "Transfer",
              icon: Icons.send,
              route: "/transfer",
            ),
            HomeServiceCard(
              title: "Airtime",
              icon: Icons.phone_android,
              route: "/airtime",
            ),
            HomeServiceCard(title: "Data", icon: Icons.wifi, route: "/data"),
            HomeServiceCard(
              title: "Electricity",
              icon: Icons.flash_on,
              route: "/electricity",
            ),
            HomeServiceCard(
              title: "Betting",
              icon: Icons.sports_soccer,
              route: "/betting",
            ),
            HomeServiceCard(
              title: "Savings",
              icon: Icons.savings,
              route: "/savings",
            ),
            HomeServiceCard(
              title: "Education",
              icon: Icons.school,
              route: "/education",
            ),
            HomeServiceCard(
              title: "More",
              icon: Icons.apps,
              route: "/services",
            ),
          ],
        ),
      ],
    );
  }
}
