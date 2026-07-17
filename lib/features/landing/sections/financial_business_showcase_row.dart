import 'package:flutter/material.dart';
import 'package:utilityhub/features/landing/sections/business_solutions_section.dart';
import 'package:utilityhub/features/landing/sections/product_showcase_section.dart';
import 'package:utilityhub/features/landing/sections/financial_education_section.dart';

class FinancialBusinessShowcaseRow extends StatelessWidget {
  const FinancialBusinessShowcaseRow({super.key});

  Widget _uniformCard(Widget child) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 420, // ⭐ uniform baseline height
        maxHeight: double.infinity,
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;

        final bool isMobile = width < 700;
        final bool isTablet = width >= 700 && width < 1100;
        final bool isDesktop = width >= 1100;

        return Center(
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 1400),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12.0 : 16.0,
              vertical: isMobile ? 24.0 : 40.0,
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Learn, Compare, and Automate — All in One Platform",
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontWeight: FontWeight.w700,
                    fontSize: isMobile ? 22.0 : 28.0,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 32),

                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _uniformCard(const FinancialEducationSection()),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _uniformCard(const ProductShowcaseSection()),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _uniformCard(const BusinessSolutionsSection()),
                      ),
                    ],
                  ),

                if (isTablet)
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _uniformCard(
                              const FinancialEducationSection(),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _uniformCard(const ProductShowcaseSection()),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _uniformCard(const BusinessSolutionsSection()),
                    ],
                  ),

                if (isMobile)
                  Column(
                    children: [
                      _uniformCard(const FinancialEducationSection()),
                      const SizedBox(height: 24),
                      _uniformCard(const ProductShowcaseSection()),
                      const SizedBox(height: 24),
                      _uniformCard(const BusinessSolutionsSection()),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
