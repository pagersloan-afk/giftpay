import 'package:flutter/material.dart';

/// GiftPay Contact Location Section
class ContactLocationSection extends StatelessWidget {
  const ContactLocationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      color: const Color(0xFFF9F9F9),
      padding: EdgeInsets.all(isMobile ? 16 : 40),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Flex(
            direction: isMobile ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ⭐ Static Map Image
              Expanded(
                flex: 1,
                child: Container(
                  height: isMobile ? 200 : 300,
                  margin: EdgeInsets.only(
                    bottom: isMobile ? 20 : 0,
                    right: isMobile ? 0 : 32,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                    image: const DecorationImage(
                      image: AssetImage("assets/images/static_map.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              // ⭐ GiftPay Contact Info
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.all(isMobile ? 12 : 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ⭐ Strong readable heading
                      Text(
                        "GiftPay Headquarters",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: isMobile ? 18 : 20,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A1A), // deep readable black
                        ),
                      ),

                      SizedBox(height: isMobile ? 10 : 14),

                      // ⭐ High contrast body text
                      Text(
                        "6th Ave. SARS Road, Rukpoku, Port Harcourt",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: isMobile ? 14 : 16,
                          color: const Color(0xFF333333), // readable dark gray
                          height: 1.4,
                        ),
                      ),
                      Text(
                        "Rivers State, Nigeria",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: isMobile ? 14 : 16,
                          color: const Color(0xFF333333),
                          height: 1.4,
                        ),
                      ),
                      Text(
                        "Support: +234 810 000 0000",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: isMobile ? 14 : 16,
                          color: const Color(0xFF333333),
                          height: 1.4,
                        ),
                      ),
                      Text(
                        "Email: support@giftpayhq.com",
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: isMobile ? 14 : 16,
                          color: const Color(0xFF333333),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
