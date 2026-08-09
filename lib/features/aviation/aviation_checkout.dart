import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';
import 'package:utilityhub/core/widgets/giftpay_background.dart';

import 'checkout/checkout_flight_summary.dart';
import 'checkout/checkout_passenger_summary.dart';
import 'checkout/checkout_fare_breakdown.dart';
import 'checkout/checkout_payment_method.dart';
import 'checkout/checkout_pay_button.dart';

class AviationCheckoutScreen extends StatefulWidget {
  const AviationCheckoutScreen({super.key});

  @override
  State<AviationCheckoutScreen> createState() => _AviationCheckoutScreenState();
}

class _AviationCheckoutScreenState extends State<AviationCheckoutScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  Map<String, dynamic>? booking;
  String paymentMethod = "wallet";

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
    booking =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
  }

  @override
  Widget build(BuildContext context) {
    if (booking == null) {
      return const Scaffold(body: Center(child: Text("No booking data")));
    }

    return GiftPayBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const AppHeaderr(title: "Checkout"),
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
                    CheckoutFlightSummary(booking: booking!),
                    CheckoutPassengerSummary(booking: booking!),
                    CheckoutFareBreakdown(booking: booking!),
                    CheckoutPaymentMethod(
                      paymentMethod: paymentMethod,
                      onChanged: (v) => setState(() => paymentMethod = v!),
                    ),
                    const SizedBox(height: 30),
                    CheckoutPayButton(
                      booking: booking!,
                      paymentMethod: paymentMethod,
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
