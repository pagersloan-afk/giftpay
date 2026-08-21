import 'package:flutter/material.dart';
import 'package:utilityhub/core/widgets/giftpay_background.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

import 'booking/booking_flight_summary.dart';
import 'booking/booking_input_fullname.dart';
import 'booking/booking_input_dob.dart';
import 'booking/booking_input_passport.dart';
import 'booking/booking_input_nationality.dart';
import 'booking/booking_api_button.dart';

class AviationBookingScreen extends StatefulWidget {
  const AviationBookingScreen({super.key});

  @override
  State<AviationBookingScreen> createState() => _AviationBookingScreenState();
}

class _AviationBookingScreenState extends State<AviationBookingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  Map<String, dynamic>? flight;

  final fullName = TextEditingController();
  final dob = TextEditingController();
  final passport = TextEditingController();
  final nationality = TextEditingController();

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
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) flight = args;
  }

  @override
  void dispose() {
    _controller.dispose();
    fullName.dispose();
    dob.dispose();
    passport.dispose();
    nationality.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GiftPayBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const AppHeaderr(title: "Passenger Details"),
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
                    BookingFlightSummary(flight: flight),
                    BookingInputFullName(controller: fullName),
                    const SizedBox(height: 16),
                    BookingInputDob(controller: dob),
                    const SizedBox(height: 16),
                    BookingInputPassport(controller: passport),
                    const SizedBox(height: 16),
                    BookingInputNationality(controller: nationality),
                    const SizedBox(height: 30),
                    BookingApiButton(
                      flight: flight,
                      fullNameController: fullName,
                      dobController: dob,
                      passportController: passport,
                      nationalityController: nationality,
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
