import 'package:flutter/material.dart';

class PinPad extends StatelessWidget {
  final Function(String) onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onSubmit;

  const PinPad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      childAspectRatio: 1.4,
      children: [
        ...List.generate(9, (i) {
          final digit = "${i + 1}";
          return ElevatedButton(
            onPressed: () => onDigit(digit),
            child: Text(digit, style: const TextStyle(fontSize: 22)),
          );
        }),
        ElevatedButton(
          onPressed: onBackspace,
          child: const Icon(Icons.backspace),
        ),
        ElevatedButton(
          onPressed: () => onDigit("0"),
          child: const Text("0", style: TextStyle(fontSize: 22)),
        ),
        ElevatedButton(onPressed: onSubmit, child: const Icon(Icons.check)),
      ],
    );
  }
}
