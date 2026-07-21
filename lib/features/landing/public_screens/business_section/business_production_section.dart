import 'package:flutter/material.dart';

class BusinessProductsSection extends StatelessWidget {
  const BusinessProductsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;

    final products = [
      {
        "img": "assets/illustrations/bulk_electricity.png",
        "title": "Bulk Electricity Tokens",
        "desc":
            "Instant multi‑meter electricity token generation for offices and facilities.",
      },
      {
        "img": "assets/illustrations/airtime_distribution.png",
        "title": "Airtime Distribution",
        "desc":
            "Automate staff airtime top‑ups and monthly communication allowances.",
      },
      {
        "img": "assets/illustrations/corporate_data.png",
        "title": "Corporate Data Plans",
        "desc":
            "Manage and automate corporate data bundles for teams and devices.",
      },
    ];

    return Center(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 1400),
        padding: EdgeInsets.all(isMobile ? 16 : 40),

        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 1 : 3,
            crossAxisSpacing: isMobile ? 12 : 24,
            mainAxisSpacing: isMobile ? 16 : 24,
            childAspectRatio: isMobile ? 0.9 : 0.85,
          ),
          itemBuilder: (context, index) {
            final card = products[index];

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Image.asset(
                      card["img"]!,
                      fit: BoxFit.contain,
                      width: double.infinity,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    card["title"]!,
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    card["desc"]!,
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: isMobile ? 13 : 15,
                      color: Colors.black54,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
