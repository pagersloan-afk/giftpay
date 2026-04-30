import 'package:flutter/material.dart';
import 'financial_education_section.dart';
import 'product_showcase_section.dart';
import 'business_solutions_section.dart';

class FinancialBusinessShowcaseRow extends StatelessWidget {
  const FinancialBusinessShowcaseRow({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 1000;

        if (isDesktop) {
          // ⭐ Desktop → 3 cards in one row
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Expanded(child: FinancialEducationSection()),
                  SizedBox(width: 40),
                  Expanded(child: ProductShowcaseSection()),
                  SizedBox(width: 40),
                  Expanded(child: BusinessSolutionsSection()),
                ],
              ),
            ),
          );
        }

        // ⭐ Mobile → stacked cards
        return Column(
          children: const [
            FinancialEducationSection(),
            ProductShowcaseSection(),
            BusinessSolutionsSection(),
          ],
        );
      },
    );
  }
}
