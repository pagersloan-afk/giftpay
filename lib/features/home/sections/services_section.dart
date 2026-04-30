import 'package:flutter/material.dart';
import '../widgets/home_service_card.dart';

class ServicesSection extends StatelessWidget {
  const ServicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Services",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE5E7EB),
          ),
        ),

        const SizedBox(height: 16),

        SizedBox(
          height: isMobile ? 300 : 360,
          child: GridView.count(
            crossAxisCount: isMobile ? 3 : 4,
            childAspectRatio: 1,
            physics: const BouncingScrollPhysics(),
            children: const [
              HomeServiceCard(
                title: "Transfer",
                icon: Icons.account_balance,
                route: "/transfer",
              ),
              HomeServiceCard(
                title: "Betting",
                icon: Icons.sports_soccer,
                route: "/betting",
              ),
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
                title: "Data",
                icon: Icons.data_usage,
                route: "/data",
              ),
              HomeServiceCard(
                title: "Gift Cards",
                icon: Icons.card_giftcard,
                route: "/giftcards",
              ),
              HomeServiceCard(
                title: "PS5 Games",
                icon: Icons.sports_esports,
                route: "/psgames",
              ),
              HomeServiceCard(
                title: "Cable TV",
                icon: Icons.tv,
                route: "/cable",
              ),
              HomeServiceCard(
                title: "Trade Gift Cards",
                icon: Icons.swap_horiz,
                route: "/trade",
              ),
            ],
          ),
        ),
      ],
    );
  }
}
