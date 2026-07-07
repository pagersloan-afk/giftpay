import 'package:flutter/material.dart';
import 'package:utilityhub/features/auth/login/sections/business_solutions_section.dart';
import 'package:utilityhub/features/auth/login/sections/product_showcase_section.dart';
import 'financial_education_section.dart';

class FinancialBusinessShowcaseRow extends StatelessWidget {
  const FinancialBusinessShowcaseRow({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 1000;

        if (isDesktop) {
          return Center(
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 1400),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Expanded(child: FinancialEducationSection()),
                  SizedBox(width: 24),
                  Expanded(child: ProductShowcaseSection()),
                  SizedBox(width: 24),
                  Expanded(child: BusinessSolutionsSection()),
                ],
              ),
            ),
          );
        }

        return Column(
          children: const [
            FinancialEducationSection(),
            SizedBox(height: 24),
            ProductShowcaseSection(),
            SizedBox(height: 24),
            BusinessSolutionsSection(),
          ],
        );
      },
    );
  }
}
