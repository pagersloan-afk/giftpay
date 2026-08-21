import 'package:flutter/material.dart';
import 'package:utilityhub/features/aviation/data/aviation_api_service.dart';
import '../data/aviation_models.dart';

class BookingApiButton extends StatefulWidget {
  final Map<String, dynamic>? flight;
  final TextEditingController fullNameController;
  final TextEditingController dobController;
  final TextEditingController passportController;
  final TextEditingController nationalityController;

  const BookingApiButton({
    super.key,
    required this.flight,
    required this.fullNameController,
    required this.dobController,
    required this.passportController,
    required this.nationalityController,
  });

  @override
  State<BookingApiButton> createState() => _BookingApiButtonState();
}

class _BookingApiButtonState extends State<BookingApiButton> {
  bool loading = false;

  Future<void> _bookFlight() async {
    if (widget.flight == null || loading) return;

    final fullName = widget.fullNameController.text.trim();
    final dob = widget.dobController.text.trim();
    final passport = widget.passportController.text.trim();
    final nationality = widget.nationalityController.text.trim();

    if (fullName.isEmpty ||
        dob.isEmpty ||
        passport.isEmpty ||
        nationality.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all passenger details.")),
      );
      return;
    }

    final parts = fullName.split(RegExp(r"\s+"));
    if (parts.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter the passenger's full name."),
        ),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final request = AviationBookingRequest(
        offerId: "${widget.flight!["id"]}",
        passenger: AviationPassenger(
          firstName: parts.first,
          lastName: parts.sublist(1).join(" "),
          dob: dob,
          passport: passport,
          nationality: nationality,
        ),
      );

      final booking = await AviationApiService().createBooking(request);
      if (!mounted) return;

      Navigator.pushNamed(context, "/aviation/checkout", arguments: booking);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Booking failed: $e")));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : _bookFlight,
        child: loading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text(
                "Continue to Checkout",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
      ),
    );
  }
}
