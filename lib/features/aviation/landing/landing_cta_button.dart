import 'package:flutter/material.dart';

class LandingCtaButton extends StatelessWidget {
  const LandingCtaButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4FC3F7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 6,
          shadowColor: const Color(0xFF4FC3F7).withOpacity(0.45),
        ),
        onPressed: () {
          Navigator.pushNamed(context, "/aviation/search");
        },
        child: const Text(
          "Search Flights",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
