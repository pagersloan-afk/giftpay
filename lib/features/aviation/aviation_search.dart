import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';
import 'package:utilityhub/core/widgets/giftpay_background.dart';

import 'search/search_header.dart';
import 'search/search_from_field.dart';
import 'search/search_to_field.dart';
import 'search/search_date_field.dart';
import 'search/search_passenger_field.dart';
import 'search/search_cabin_field.dart';
import 'search/search_button.dart';

class AviationSearchScreen extends StatefulWidget {
  const AviationSearchScreen({super.key});

  @override
  State<AviationSearchScreen> createState() => _AviationSearchScreenState();
}

class _AviationSearchScreenState extends State<AviationSearchScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  String? from = "LOS - Lagos";
  String? to = "ABV - Abuja";
  String? cabin = "Economy";
  DateTime? departureDate;
  int passengers = 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null && mounted) setState(() => departureDate = picked);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GiftPayBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const AppHeaderr(title: "Search Flights"),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550),
            child: FadeTransition(
              opacity: _fade,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SearchHeader(),
                    const SizedBox(height: 26),
                    SearchFromField(
                      value: from!,
                      onChanged: (v) => setState(() => from = v),
                    ),
                    const SizedBox(height: 16),
                    SearchToField(
                      value: to!,
                      onChanged: (v) => setState(() => to = v),
                    ),
                    const SizedBox(height: 16),
                    SearchDateField(
                      label: "Departure",
                      date: departureDate,
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: 16),
                    SearchPassengerField(
                      passengers: passengers,
                      onAdd: () => setState(() => passengers++),
                      onRemove: () {
                        if (passengers > 1) setState(() => passengers--);
                      },
                    ),
                    const SizedBox(height: 16),
                    SearchCabinField(
                      cabin: cabin!,
                      onChanged: (v) => setState(() => cabin = v),
                    ),
                    const SizedBox(height: 30),
                    SearchButton(
                      from: from!,
                      to: to!,
                      departureDate: departureDate,
                      passengers: passengers,
                      cabin: cabin!,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
