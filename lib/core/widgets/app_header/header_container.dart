import 'package:flutter/material.dart';

class HeaderContainer extends StatelessWidget {
  final Widget child;

  const HeaderContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 80,
        decoration: const BoxDecoration(color: Color(0xFF0F1115)),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 12,
                  left: 16,
                  right: 16,
                  bottom: 10,
                ),
                child: child,
              ),
            ),
            Container(height: 2, color: Colors.white.withOpacity(0.12)),
          ],
        ),
      ),
    );
  }
}
