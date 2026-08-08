import 'package:flutter/material.dart';

class AviationSearchScreen extends StatefulWidget {
  const AviationSearchScreen({super.key});

  @override
  State<AviationSearchScreen> createState() => _AviationSearchScreenState();
}

class _AviationSearchScreenState extends State<AviationSearchScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  String from = "LOS - Lagos";
  String to = "ABV - Abuja";

  DateTime? departureDate;
  DateTime? returnDate;

  int passengers = 1;
  String cabin = "Economy";

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

  Future<void> _pickDate(bool isDeparture) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF4FC3F7),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isDeparture) {
          departureDate = picked;
        } else {
          returnDate = picked;
        }
      });
    }
  }

  Widget _inputCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: child,
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
          "Search Flights",
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
                  // ⭐ Header
                  Text(
                    "Find the best flights",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Search domestic and international routes.",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.65),
                      fontSize: 13.5,
                    ),
                  ),

                  const SizedBox(height: 26),

                  // ⭐ FROM
                  _inputCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "From",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButton<String>(
                          value: from,
                          dropdownColor: const Color(0xFF1A1D21),
                          iconEnabledColor: Colors.white,
                          items: const [
                            DropdownMenuItem(
                              value: "LOS - Lagos",
                              child: Text("LOS - Lagos"),
                            ),
                            DropdownMenuItem(
                              value: "ABV - Abuja",
                              child: Text("ABV - Abuja"),
                            ),
                            DropdownMenuItem(
                              value: "KAN - Kano",
                              child: Text("KAN - Kano"),
                            ),
                          ],
                          onChanged: (v) => setState(() => from = v!),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ⭐ TO
                  _inputCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "To",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButton<String>(
                          value: to,
                          dropdownColor: const Color(0xFF1A1D21),
                          iconEnabledColor: Colors.white,
                          items: const [
                            DropdownMenuItem(
                              value: "ABV - Abuja",
                              child: Text("ABV - Abuja"),
                            ),
                            DropdownMenuItem(
                              value: "LOS - Lagos",
                              child: Text("LOS - Lagos"),
                            ),
                            DropdownMenuItem(
                              value: "PHC - Port Harcourt",
                              child: Text("PHC - Port Harcourt"),
                            ),
                          ],
                          onChanged: (v) => setState(() => to = v!),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ⭐ Departure Date
                  _inputCard(
                    child: GestureDetector(
                      onTap: () => _pickDate(true),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Departure",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.55),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            departureDate == null
                                ? "Select date"
                                : "${departureDate!.day}/${departureDate!.month}/${departureDate!.year}",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ⭐ Return Date
                  _inputCard(
                    child: GestureDetector(
                      onTap: () => _pickDate(false),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Return",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.55),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            returnDate == null
                                ? "Select date"
                                : "${returnDate!.day}/${returnDate!.month}/${returnDate!.year}",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ⭐ Passengers
                  _inputCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Passengers",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 12,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (passengers > 1) {
                                  setState(() => passengers--);
                                }
                              },
                              icon: const Icon(
                                Icons.remove,
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              "$passengers",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                            IconButton(
                              onPressed: () => setState(() => passengers++),
                              icon: const Icon(
                                Icons.add,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ⭐ Cabin Class
                  _inputCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Cabin Class",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButton<String>(
                          value: cabin,
                          dropdownColor: const Color(0xFF1A1D21),
                          iconEnabledColor: Colors.white,
                          items: const [
                            DropdownMenuItem(
                              value: "Economy",
                              child: Text("Economy"),
                            ),
                            DropdownMenuItem(
                              value: "Business",
                              child: Text("Business"),
                            ),
                            DropdownMenuItem(
                              value: "First Class",
                              child: Text("First Class"),
                            ),
                          ],
                          onChanged: (v) => setState(() => cabin = v!),
                          style: const TextStyle(color: Colors.white),
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
                        Navigator.pushNamed(context, "/aviation/results");
                      },
                      child: const Text(
                        "Search Flights",
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
