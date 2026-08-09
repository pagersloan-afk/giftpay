import 'package:flutter/material.dart';

class SearchPassengerField extends StatelessWidget {
  final int passengers;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const SearchPassengerField({
    super.key,
    required this.passengers,
    required this.onAdd,
    required this.onRemove,
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
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Passengers",
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontSize: 12,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: passengers > 1 ? onRemove : null,
                icon: const Icon(Icons.remove, color: Colors.white70),
              ),
              Text(
                "$passengers",
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
              IconButton(
                onPressed: onAdd,
                icon: const Icon(Icons.add, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
