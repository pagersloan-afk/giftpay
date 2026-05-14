import 'package:flutter/material.dart';

class LoanBannerSection extends StatelessWidget {
  const LoanBannerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4FC3F7).withOpacity(0.12),
            blurRadius: 22,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ⭐ Naira icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.08),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: const Text(
              "₦",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4FC3F7),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // ⭐ FIXED: Flexible text block (prevents pushing button down)
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Need Quick Cash?",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                    color: Colors.white.withOpacity(0.95),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Apply for instant loans with flexible repayment.",
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.25,
                    color: Colors.white.withOpacity(0.65),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // ⭐ FIXED: Button stays vertically centered
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, "/loan"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4FC3F7),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 8,
              shadowColor: const Color(0xFF4FC3F7).withOpacity(0.45),
            ),
            child: const Text(
              "Apply",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
