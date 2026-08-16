import 'package:flutter/material.dart';

class AboutColors {
  static const Color navy = Color(0xFF273D68);
  static const Color blue = Color(0xFF4A6BB8);
  static const Color highlight = Color(0xFF7EA4FF);

  const AboutColors._();
}

class AboutSmallLabel extends StatelessWidget {
  final String text;

  const AboutSmallLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'SegoeUI',
        fontSize: 9,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.9,
        color: AboutColors.highlight,
      ),
    );
  }
}

class AboutLuxuryCard extends StatefulWidget {
  final Widget child;

  const AboutLuxuryCard({super.key, required this.child});

  @override
  State<AboutLuxuryCard> createState() => _AboutLuxuryCardState();
}

class _AboutLuxuryCardState extends State<AboutLuxuryCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (!mounted) return;
        setState(() => _hovered = true);
      },
      onExit: (_) {
        if (!mounted) return;
        setState(() => _hovered = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,

        // IMPORTANT:
        // Do not force a height here.
        // The card must size itself from its content.
        width: double.infinity,

        padding: const EdgeInsets.all(28),

        transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(_hovered ? 0.055 : 0.035),
              Colors.white.withOpacity(0.018),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(_hovered ? 0.11 : 0.065),
          ),
          boxShadow: [
            if (_hovered)
              BoxShadow(
                color: AboutColors.blue.withOpacity(0.10),
                blurRadius: 35,
                spreadRadius: -8,
                offset: const Offset(0, 14),
              ),
          ],
        ),

        child: widget.child,
      ),
    );
  }
}
