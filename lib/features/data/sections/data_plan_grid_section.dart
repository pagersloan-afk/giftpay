import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DataPlanGridSection extends StatelessWidget {
  final List<dynamic> plans;
  final String? selectedPlanId;
  final Color themeColor;
  final bool isWeb;
  final ValueChanged<String> onSelect;

  const DataPlanGridSection({
    super.key,
    required this.plans,
    required this.selectedPlanId,
    required this.themeColor,
    required this.isWeb,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat("#,##0", "en_US");

    return SizedBox(
      height: isWeb
          ? MediaQuery.of(context).size.height * 0.60
          : MediaQuery.of(context).size.height * 0.45,
      child: GridView.builder(
        itemCount: plans.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: isWeb ? 1.35 : 0.95,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        physics: const BouncingScrollPhysics(),
        shrinkWrap: false,
        itemBuilder: (_, i) {
          final plan = plans[i];
          final isSelected = selectedPlanId == plan["id"].toString();

          // Format price safely
          final rawPrice = plan["price"].toString();
          final parsedPrice = double.tryParse(rawPrice) ?? 0;
          final formattedPrice = formatter.format(parsedPrice);

          return GestureDetector(
            onTap: () => onSelect(plan["id"].toString()),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06), // GP‑1
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? themeColor : Colors.white24,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    plan["name"],
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white, // GP‑1 text
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "₦$formattedPrice",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: themeColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
