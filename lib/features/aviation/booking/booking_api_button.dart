import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BookingApiButton extends StatefulWidget {
  final Map<String, dynamic>? flight;
  final String fullName;
  final String dob;
  final String passport;
  final String nationality;

  const BookingApiButton({
    super.key,
    required this.flight,
    required this.fullName,
    required this.dob,
    required this.passport,
    required this.nationality,
  });

  @override
  State<BookingApiButton> createState() => _BookingApiButtonState();
}

class _BookingApiButtonState extends State<BookingApiButton> {
  bool loading = false;

  Future<void> _bookFlight() async {
    if (widget.flight == null) return;

    setState(() => loading = true);

    try {
      final selectedOfferId = widget.flight!["id"];

      final passengerData = {
        "firstName": widget.fullName.split(" ").first,
        "lastName": widget.fullName.split(" ").last,
        "dob": widget.dob,
        "passport": widget.passport,
        "nationality": widget.nationality,
      };

      final res = await http.post(
        Uri.parse("https://your-backend-url.com/api/aviation/book"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "offerId": selectedOfferId,
          "passenger": passengerData,
        }),
      );

      final bookingResponse = jsonDecode(res.body);

      Navigator.pushNamed(
        context,
        "/aviation/checkout",
        arguments: bookingResponse,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Booking failed: $e")));
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : _bookFlight,
        child: loading
            ? const CircularProgressIndicator(color: Colors.black)
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
