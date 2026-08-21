import 'package:flutter/material.dart';
import '../data/aviation_api_service.dart';
import '../data/aviation_models.dart';

class SearchButton extends StatefulWidget {
  final String from;
  final String to;
  final DateTime? departureDate;
  final int passengers;
  final String cabin;

  const SearchButton({
    super.key,
    required this.from,
    required this.to,
    required this.departureDate,
    required this.passengers,
    required this.cabin,
  });

  @override
  State<SearchButton> createState() => _SearchButtonState();
}

class _SearchButtonState extends State<SearchButton> {
  bool loading = false;

  Future<void> _search() async {
    if (widget.departureDate == null || loading) return;

    if (widget.from == widget.to) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("From and To airports must be different."),
        ),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final date =
          "${widget.departureDate!.year.toString().padLeft(4, "0")}-"
          "${widget.departureDate!.month.toString().padLeft(2, "0")}-"
          "${widget.departureDate!.day.toString().padLeft(2, "0")}";

      final request = AviationSearchRequest(
        from: widget.from.split(" - ").first,
        to: widget.to.split(" - ").first,
        date: date,
        passengers: widget.passengers,
        cabin: widget.cabin,
      );

      final flights = await AviationApiService().searchFlights(request);
      if (!mounted) return;

      Navigator.pushNamed(context, "/aviation/results", arguments: flights);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Flight search failed: $e")));
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
        onPressed: widget.departureDate == null || loading ? null : _search,
        child: loading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text(
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
