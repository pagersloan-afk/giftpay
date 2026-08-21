import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';
import 'package:utilityhub/core/widgets/giftpay_background.dart';

import 'data/aviation_api_service.dart';
import 'data/aviation_fare_utils.dart';
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
  bool loading = true;
  String? error;

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
    if (booking != null || ticket != null || error != null) return;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map) {
      final rawBooking = args["booking"];
      booking = rawBooking is Map
          ? Map<String, dynamic>.from(rawBooking)
          : null;

      if (booking != null) {
        _generateTicket(Map<String, dynamic>.from(args));
      } else {
        setState(() {
          loading = false;
          error = "Booking information is missing.";
        });
      }
    } else {
      setState(() {
        loading = false;
        error = "Ticket information is missing.";
      });
    }
  }

  Future<void> _generateTicket(Map<String, dynamic> args) async {
    try {
      final total = AviationFareUtils.toDouble(args["total"]);
      final paymentMethod = "${args["paymentMethod"] ?? "wallet"}";
      final service = AviationApiService();

      final result = service.useMockData
          ? service.generateMockTicket(
              booking: booking!,
              total: total,
              paymentMethod: paymentMethod,
            )
          : await service.generateTicket(
              bookingId: "${booking!["id"]}",
              total: total,
              paymentMethod: paymentMethod,
            );

      if (!mounted) return;
      setState(() {
        ticket = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = "Unable to generate ticket: $e";
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F1115),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF4FC3F7)),
        ),
      );
    }

    if (error != null || ticket == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F1115),
        appBar: const AppHeaderr(title: "Ticket"),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              error ?? "Ticket could not be generated.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }

    final rawQr = ticket!["qr"];
    final qr = rawQr is List ? List<int>.from(rawQr) : null;

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
                    TicketQr(qr: qr),
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
