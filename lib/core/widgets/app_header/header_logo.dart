import 'package:flutter/material.dart';

class HeaderLogo extends StatelessWidget {
  final bool compact;
  final bool showWordmark;

  const HeaderLogo({super.key, this.compact = false, this.showWordmark = true});

  static const Color navy = Color(0xFF273D68);
  static const Color blue = Color(0xFF4A6BB8);
  static const Color lightBlue = Color(0xFF75A1FF);

  @override
  Widget build(BuildContext context) {
    final markSize = compact ? 38.0 : 44.0;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ============================================================
          // G MARK
          // ============================================================
          Container(
            width: markSize,
            height: markSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.16),
                  blue.withOpacity(0.19),
                ],
              ),
              borderRadius: BorderRadius.circular(compact ? 12 : 14),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
              boxShadow: [
                BoxShadow(
                  color: blue.withOpacity(0.22),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Container(
              width: compact ? 26 : 30,
              height: compact ? 26 : 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.96),
              ),
              child: Text(
                'G',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: compact ? 15 : 17,
                  fontWeight: FontWeight.w900,
                  color: navy,
                ),
              ),
            ),
          ),

          if (showWordmark) ...[
            const SizedBox(width: 11),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'GiftPay',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: compact ? 17 : 19,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.45,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 1),

                Text(
                  'SMARTER EVERYDAY',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 7,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.35,
                    color: lightBlue.withOpacity(0.84),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
