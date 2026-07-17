import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class BusinessSolutionsSection extends StatelessWidget {
  const BusinessSolutionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 900;

    return Center(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 1400),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12.0 : 16.0,
          vertical: isMobile ? 24.0 : 40.0,
        ),

        // ⭐ Luxury card wrapper with uniform height
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 420, // ⭐ uniform baseline height
            maxHeight: double.infinity,
          ),
          padding: EdgeInsets.all(isMobile ? 18.0 : 28.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 18.0,
                offset: const Offset(0, 6),
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final double imgHeight = constraints.maxWidth < 500
                      ? 120.0
                      : 180.0;

                  return SizedBox(
                    height: imgHeight,
                    child: Image.asset(
                      "assets/illustrations/business_solutions.png",
                      fit: BoxFit.contain,
                    ),
                  );
                },
              ),

              SizedBox(height: isMobile ? 20.0 : 24.0),

              Text(
                "GiftPay for Business",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontWeight: FontWeight.w700,
                  fontSize: isMobile ? 20.0 : 24.0,
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),

              SizedBox(height: isMobile ? 12.0 : 14.0),

              Text(
                "Automate bulk electricity tokens, airtime distribution, and corporate data plans with ease.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: isMobile ? 13.0 : 15.0,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),

              SizedBox(height: isMobile ? 20.0 : 24.0),

              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: GiftPayTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 22.0 : 28.0,
                    vertical: isMobile ? 14.0 : 16.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                ),
                child: const Text(
                  "Explore Business Solutions",
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontWeight: FontWeight.w600,
                    fontSize: 16.0,
                    letterSpacing: 0.2,
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
