import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

class CommunityCard extends StatelessWidget {
  final String title;
  final String text;
  final String route;
  final IconData icon;

  const CommunityCard({
    super.key,
    required this.title,
    required this.text,
    required this.route,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 275,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => Navigator.pushNamed(context, route),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.92),
                  const Color(0xFFF3F7FF).withOpacity(0.72),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.9),
                width: 1.1,
              ),
              boxShadow: [
                BoxShadow(
                  color: GiftPayTheme.primaryBlue.withOpacity(0.07),
                  blurRadius: 28,
                  spreadRadius: 1,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.white, const Color(0xFFEAF1FF)],
                        ),
                        border: Border.all(
                          color: GiftPayTheme.primaryBlue.withOpacity(0.12),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: GiftPayTheme.primaryBlue.withOpacity(0.10),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        size: 23,
                        color: GiftPayTheme.primaryBlue,
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: GiftPayTheme.primaryBlue.withOpacity(0.06),
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 17,
                        color: GiftPayTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: Color(0xFF142850),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 13.5,
                    height: 1.45,
                    color: Colors.black.withOpacity(0.57),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
