import 'package:flutter/material.dart';
import 'package:utilityhub/core/widgets/app_responsive_layout.dart';
import 'enter_amount_screen.dart';

class SelectBrandScreen extends StatelessWidget {
  const SelectBrandScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brands = [
      {"name": "Apple", "icon": Icons.apple},
      {"name": "Google Play", "icon": Icons.android},
      {"name": "Amazon", "icon": Icons.shopping_bag},
      {"name": "Steam", "icon": Icons.games},
      {"name": "PlayStation", "icon": Icons.sports_esports},
      {"name": "Xbox", "icon": Icons.videogame_asset},
      {"name": "Netflix", "icon": Icons.movie},
      {"name": "Spotify", "icon": Icons.music_note},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Buy Gift Card")),
      body: AppResponsiveLayout(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: GridView.builder(
            itemCount: brands.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1,
            ),
            itemBuilder: (_, i) {
              final brand = brands[i];

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EnterGiftCardAmountScreen(
                        brandName: brand["name"] as String,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        brand["icon"] as IconData,
                        size: 40,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        brand["name"] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
