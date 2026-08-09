import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';
import 'package:utilityhub/core/widgets/giftpay_background.dart';

import 'results/results_header.dart';
import 'results/results_list.dart';

class AviationResultsScreen extends StatefulWidget {
  const AviationResultsScreen({super.key});

  @override
  State<AviationResultsScreen> createState() => _AviationResultsScreenState();
}

class _AviationResultsScreenState extends State<AviationResultsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  List<dynamic> offers = [];

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    offers = ModalRoute.of(context)?.settings.arguments as List<dynamic>? ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return GiftPayBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const AppHeaderr(title: "Available Flights"),
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
                    const ResultsHeader(),
                    const SizedBox(height: 20),
                    ResultsList(offers: offers),
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
