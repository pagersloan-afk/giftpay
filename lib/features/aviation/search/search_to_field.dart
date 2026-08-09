import 'package:flutter/material.dart';

class SearchToField extends StatelessWidget {
  final String value;
  final ValueChanged<String?>? onChanged;

  const SearchToField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "To",
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButton<String>(
            value: value,
            dropdownColor: const Color(0xFF1A1D21),
            iconEnabledColor: Colors.white,
            items: const [
              DropdownMenuItem(
                value: "ABV - Abuja",
                child: Text("ABV - Abuja"),
              ),
              DropdownMenuItem(
                value: "LOS - Lagos",
                child: Text("LOS - Lagos"),
              ),
              DropdownMenuItem(
                value: "PHC - Port Harcourt",
                child: Text("PHC - Port Harcourt"),
              ),
            ],
            onChanged: onChanged,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
