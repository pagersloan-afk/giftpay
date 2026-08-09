import 'package:flutter/material.dart';

class SearchCabinField extends StatelessWidget {
  final String cabin;
  final ValueChanged<String?>? onChanged;

  const SearchCabinField({
    super.key,
    required this.cabin,
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
            "Cabin Class",
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButton<String>(
            value: cabin,
            dropdownColor: const Color(0xFF1A1D21),
            iconEnabledColor: Colors.white,
            items: const [
              DropdownMenuItem(value: "Economy", child: Text("Economy")),
              DropdownMenuItem(value: "Business", child: Text("Business")),
              DropdownMenuItem(
                value: "First Class",
                child: Text("First Class"),
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
