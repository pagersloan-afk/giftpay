import 'package:flutter/material.dart';
import 'enter_details_screen.dart';

class SelectCardTypeScreen extends StatelessWidget {
  final String category;

  const SelectCardTypeScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final types = [
      "$category USA",
      "$category UK",
      "$category Canada",
      "$category Australia",
      "$category Global",
    ];

    return Scaffold(
      appBar: AppBar(title: Text("Select $category Type")),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: types.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          return ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            title: Text(types[i]),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EnterTradeDetailsScreen(cardType: types[i]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
