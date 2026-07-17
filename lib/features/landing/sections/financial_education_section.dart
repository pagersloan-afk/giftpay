import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class FinancialEducationSection extends StatelessWidget {
  const FinancialEducationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 900;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1400),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12.0 : 24.0,
          vertical: isMobile ? 20.0 : 40.0,
        ),

        child: Container(
          padding: EdgeInsets.all(isMobile ? 16.0 : 28.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isMobile ? 12.0 : 14.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: isMobile ? 12.0 : 18.0,
                offset: const Offset(0, 6),
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  // ⭐ FIX: Fully responsive image height
                  final double imgHeight = constraints.maxWidth * 0.28;

                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: 100.0,
                      maxHeight: isMobile ? 140.0 : 180.0,
                    ),
                    child: SizedBox(
                      height: imgHeight,
                      child: Image.asset(
                        "assets/illustrations/utility_spending.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: isMobile ? 16.0 : 20.0),

              Text(
                "Smart Utility Spending",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontWeight: FontWeight.w700,
                  fontSize: isMobile ? 20.0 : 24.0,
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: isMobile ? 10.0 : 12.0),

              Text(
                "Learn how to manage electricity, airtime, and data spending with smart budgeting tips, usage insights, and reward strategies.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: isMobile ? 13.0 : 15.0,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),

              SizedBox(height: isMobile ? 18.0 : 24.0),

              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: GiftPayTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 20.0 : 28.0,
                    vertical: isMobile ? 12.0 : 16.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                ),
                child: const Text(
                  "Browse Resources",
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontWeight: FontWeight.w600,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
