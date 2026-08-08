import 'package:flutter/material.dart';

class AviationResultsScreen extends StatefulWidget {
  const AviationResultsScreen({super.key});

  @override
  State<AviationResultsScreen> createState() => _AviationResultsScreenState();
}

class _AviationResultsScreenState extends State<AviationResultsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  final List<Map<String, dynamic>> flights = [
    {
      "airline": "Air Peace",
      "flightNumber": "P4-712",
      "from": "LOS",
      "to": "ABV",
      "depart": "08:45",
      "arrive": "09:55",
      "duration": "1h 10m",
      "price": 45000,
    },
    {
      "airline": "Dana Air",
      "flightNumber": "DA-402",
      "from": "LOS",
      "to": "ABV",
      "depart": "12:20",
      "arrive": "13:30",
      "duration": "1h 10m",
      "price": 47000,
    },
    {
      "airline": "Ibom Air",
      "flightNumber": "IA-118",
      "from": "LOS",
      "to": "ABV",
      "depart": "16:00",
      "arrive": "17:10",
      "duration": "1h 10m",
      "price": 52000,
    },
  ];

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

  Widget _flightCard(Map<String, dynamic> f) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Airline + Flight Number
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                f["airline"],
                style: TextStyle(
                  color: Colors.white.withOpacity(0.95),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                f["flightNumber"],
                style: TextStyle(
                  color: Colors.white.withOpacity(0.55),
                  fontSize: 13,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Times
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    f["depart"],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    f["from"],
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.55),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.flight_takeoff,
                size: 28,
                color: Colors.white.withOpacity(0.85),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    f["arrive"],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    f["to"],
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.55),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Duration
          Text(
            f["duration"],
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 18),

          // Price + CTA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "₦${f["price"]}",
                style: const TextStyle(
                  color: Color(0xFF4FC3F7),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(
                height: 42,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4FC3F7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    shadowColor: const Color(0xFF4FC3F7).withOpacity(0.35),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      "/aviation/booking",
                      arguments: f,
                    );
                  },
                  child: const Text(
                    "Select",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "Available Flights",
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
              child: Column(children: flights.map(_flightCard).toList()),
            ),
          ),
        ),
      ),
    );
  }
}
