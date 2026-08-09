import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchButton extends StatelessWidget {
  final String from;
  final String to;
  final DateTime? departureDate;

  const SearchButton({
    super.key,
    required this.from,
    required this.to,
    required this.departureDate,
  });

  Future<void> _search(BuildContext context) async {
    final fromCode = from.split(" - ").first;
    final toCode = to.split(" - ").first;

    final date =
        "${departureDate!.year}-${departureDate!.month}-${departureDate!.day}";

    final res = await http.post(
      Uri.parse("https://your-backend-url.com/api/aviation/search"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"from": fromCode, "to": toCode, "date": date}),
    );

    final flights = jsonDecode(res.body);

    Navigator.pushNamed(context, "/aviation/results", arguments: flights);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: departureDate == null ? null : () => _search(context),
        child: const Text(
          "Search Flights",
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
