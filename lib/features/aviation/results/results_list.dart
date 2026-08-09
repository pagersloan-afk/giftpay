import 'package:flutter/material.dart';
import 'results_flight_card.dart';

class ResultsList extends StatelessWidget {
  final List<dynamic> offers;

  const ResultsList({super.key, required this.offers});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: offers.map((o) => ResultsFlightCard(offer: o)).toList(),
    );
  }
}
