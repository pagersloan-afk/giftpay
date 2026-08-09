import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:utilityhub/core/theme/giftpay_theme.dart';

import 'package:utilityhub/core/widgets/giftpay_background.dart';

import 'ticket/ticket_header.dart';
import 'ticket/ticket_qr.dart';
import 'ticket/ticket_flight_details.dart';
import 'ticket/ticket_passenger_details.dart';
import 'ticket/ticket_payment_details.dart';
import 'ticket/ticket_done_button.dart';

class AviationTicketScreen extends StatefulWidget {
  const AviationTicketScreen({super.key});

  @override
  State<AviationTicketScreen> createState() => _AviationTicketScreenState();
}

class _AviationTicketScreenState extends State<AviationTicketScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  Map<String, dynamic>? booking;
  Map<String, dynamic>? ticket;

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

    if (booking != null) {
      _fetchTicket();
    }
  }

  Future<void> _fetchTicket() async {
    final bookingId = booking!["booking"]["id"];

    final res = await http.post(
      Uri.parse("https://your-backend-url.com/api/aviation/ticket"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"bookingId": bookingId}),
    );

    setState(() {
      ticket = jsonDecode(res.body);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (ticket == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F1115),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF4FC3F7)),
        ),
      );
    }

    return GiftPayBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const AppHeaderr(title: "Your Ticket"),
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
                    const TicketHeader(),
                    const SizedBox(height: 26),
                    TicketQr(qr: ticket!["qr"]),
                    TicketFlightDetails(ticket: ticket!),
                    TicketPassengerDetails(ticket: ticket!),
                    TicketPaymentDetails(ticket: ticket!),
                    const SizedBox(height: 30),
                    const TicketDoneButton(),
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
