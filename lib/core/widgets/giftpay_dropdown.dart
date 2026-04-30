import 'package:flutter/material.dart';

class GiftPayDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  const GiftPayDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items,
      onChanged: onChanged,

      // ⭐ This is the global fix
      dropdownColor: const Color.fromARGB(
        255,
        17,
        17,
        17,
      ), // solid dark background

      style: theme.textTheme.bodyLarge,

      decoration: InputDecoration(labelText: label),
    );
  }
}
