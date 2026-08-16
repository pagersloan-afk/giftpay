import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:utilityhub/features/gift_techlanding/widgets/gifttech_lift_card.dart';

class ContactCard extends StatelessWidget {
  final String title;
  final String text;
  final IconData icon;

  const ContactCard({
    super.key,
    required this.title,
    required this.text,
    required this.icon,
  });

  static const Color _softBlue = Color(0xFF4A6BB8);
  static const Color _highlight = Color(0xFF75A1FF);

  @override
  Widget build(BuildContext context) {
    return GiftTechLiftCard(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: 290,
            height: 205,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),

              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.075),
                  Colors.white.withOpacity(0.025),
                  _softBlue.withOpacity(0.045),
                ],
              ),

              border: Border.all(
                color: Colors.white.withOpacity(0.10),
                width: 1,
              ),

              boxShadow: [
                BoxShadow(
                  color: _softBlue.withOpacity(0.08),
                  blurRadius: 35,
                  spreadRadius: -8,
                  offset: const Offset(0, 18),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ----------------------------------------------------------
                // ICON
                // ----------------------------------------------------------
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),

                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _softBlue.withOpacity(0.24),
                        Colors.white.withOpacity(0.045),
                      ],
                    ),

                    border: Border.all(color: Colors.white.withOpacity(0.09)),

                    boxShadow: [
                      BoxShadow(
                        color: _softBlue.withOpacity(0.14),
                        blurRadius: 22,
                        spreadRadius: -4,
                      ),
                    ],
                  ),

                  child: Icon(icon, size: 21, color: _highlight),
                ),

                const SizedBox(height: 22),

                // ----------------------------------------------------------
                // TITLE
                // ----------------------------------------------------------
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 16,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 9),

                // ----------------------------------------------------------
                // DESCRIPTION
                // ----------------------------------------------------------
                Expanded(
                  child: Text(
                    text,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 12.5,
                      height: 1.5,
                      color: Colors.white.withOpacity(0.84),
                    ),
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
