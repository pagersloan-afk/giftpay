import 'package:flutter/material.dart';

class KycProgressSteps extends StatelessWidget {
  final int step; // 1, 2, or 3

  const KycProgressSteps({super.key, required this.step});

  Color _circleColor(int current) {
    if (step > current) return Colors.green;
    if (step == current) return Colors.blue;
    return Colors.grey.shade400;
  }

  Color _lineColor(int current) {
    return step > current ? Colors.green : Colors.grey.shade300;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Step 1
        _stepCircle("1", _circleColor(1)),
        _stepLine(_lineColor(1)),

        // Step 2
        _stepCircle("2", _circleColor(2)),
        _stepLine(_lineColor(2)),

        // Step 3
        _stepCircle("3", _circleColor(3)),
      ],
    );
  }

  Widget _stepCircle(String text, Color color) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _stepLine(Color color) {
    return Expanded(child: Container(height: 3, color: color));
  }
}
