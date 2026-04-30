import 'package:flutter/material.dart';
import 'card_container.dart';

class DescriptionCard extends StatelessWidget {
  final TextEditingController controller;

  const DescriptionCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Description",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.95),
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: controller,
            maxLength: 35,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "What is this for?",
              hintStyle: TextStyle(color: Colors.white54),
              counterText: "35 characters max",
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: const Color(0xFF4FC3F7),
                  width: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
