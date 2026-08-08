import 'package:flutter/material.dart';

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

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4FC3F7).withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final flight = booking?["flight"];
    final fullName = booking?["fullName"];
    final dob = booking?["dob"];
    final passport = booking?["passport"];
    final nationality = booking?["nationality"];

    final price = flight?["price"] ?? 0;
    final tax = (price * 0.075).round();
    final serviceFee = 2500;
    final total = price + tax + serviceFee;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "Checkout",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 550),
          child: FadeTransition(
            opacity: _fade,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ⭐ Flight Summary
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          flight?["airline"] ?? "",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "${flight?["from"]} → ${flight?["to"]}",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "${flight?["depart"]} - ${flight?["arrive"]}  •  ${flight?["duration"]}",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ⭐ Passenger Summary
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Passenger",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          fullName ?? "",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "DOB: $dob",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          "Passport: $passport",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          "Nationality: $nationality",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ⭐ Fare Breakdown
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Fare Breakdown",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 14),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Base Fare",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.65),
                              ),
                            ),
                            Text(
                              "₦$price",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Tax (7.5%)",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.65),
                              ),
                            ),
                            Text(
                              "₦$tax",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Service Fee",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.65),
                              ),
                            ),
                            Text(
                              "₦$serviceFee",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.95),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              "₦$total",
                              style: const TextStyle(
                                color: Color(0xFF4FC3F7),
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ⭐ Payment Method
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Payment Method",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 14),

                        RadioListTile(
                          value: "wallet",
                          groupValue: paymentMethod,
                          onChanged: (v) => setState(() => paymentMethod = v!),
                          activeColor: const Color(0xFF4FC3F7),
                          title: const Text(
                            "GiftPay Wallet",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),

                        RadioListTile(
                          value: "card",
                          groupValue: paymentMethod,
                          onChanged: (v) => setState(() => paymentMethod = v!),
                          activeColor: const Color(0xFF4FC3F7),
                          title: const Text(
                            "Debit / Credit Card",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ⭐ CTA
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4FC3F7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 6,
                        shadowColor: const Color(0xFF4FC3F7).withOpacity(0.45),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          "/aviation/ticket",
                          arguments: {
                            "flight": flight,
                            "fullName": fullName,
                            "total": total,
                            "paymentMethod": paymentMethod,
                          },
                        );
                      },
                      child: const Text(
                        "Pay & Generate Ticket",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
