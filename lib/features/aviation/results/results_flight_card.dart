import 'package:flutter/material.dart';

class ResultsFlightCard extends StatelessWidget {
  final Map<String, dynamic> offer;

  const ResultsFlightCard({super.key, required this.offer});

  /// Safely extracts the first itinerary segment.
  Map<String, dynamic> get _segment {
    final itineraries = offer["itineraries"];

    if (itineraries is List && itineraries.isNotEmpty) {
      final itinerary = itineraries.first;

      if (itinerary is Map) {
        final segments = itinerary["segments"];

        if (segments is List && segments.isNotEmpty) {
          final segment = segments.first;

          if (segment is Map) {
            return Map<String, dynamic>.from(segment);
          }
        }
      }
    }

    return <String, dynamic>{};
  }

  /// Supports both:
  ///
  /// "price": "85000"
  ///
  /// and:
  ///
  /// "price": {
  ///   "total": "85000"
  /// }
  ///
  /// It also supports numeric values returned by a real API.
  String get _price {
    final priceData = offer["price"];

    if (priceData is Map) {
      final total = priceData["total"];

      if (total != null) {
        return total.toString();
      }
    }

    if (priceData != null) {
      return priceData.toString();
    }

    // Some APIs may use "total" at the offer level.
    final total = offer["total"];

    if (total != null) {
      return total.toString();
    }

    return "0";
  }

  String get _airline {
    final validatingCodes = offer["validatingAirlineCodes"];

    if (validatingCodes is List && validatingCodes.isNotEmpty) {
      return validatingCodes.first.toString();
    }

    final airline = offer["airline"];

    if (airline != null) {
      return airline.toString();
    }

    return "Unknown Airline";
  }

  String get _from {
    final departure = _segment["departure"];

    if (departure is Map && departure["iataCode"] != null) {
      return departure["iataCode"].toString();
    }

    return offer["from"]?.toString() ?? "---";
  }

  String get _to {
    final arrival = _segment["arrival"];

    if (arrival is Map && arrival["iataCode"] != null) {
      return arrival["iataCode"].toString();
    }

    return offer["to"]?.toString() ?? "---";
  }

  String get _depart {
    final departure = _segment["departure"];

    if (departure is Map && departure["at"] != null) {
      return _formatTime(departure["at"].toString());
    }

    return offer["depart"]?.toString() ?? "--:--";
  }

  String get _arrive {
    final arrival = _segment["arrival"];

    if (arrival is Map && arrival["at"] != null) {
      return _formatTime(arrival["at"].toString());
    }

    return offer["arrive"]?.toString() ?? "--:--";
  }

  String get _duration {
    final duration = _segment["duration"];

    if (duration != null) {
      return _formatDuration(duration.toString());
    }

    return offer["duration"]?.toString() ?? "Unknown duration";
  }

  String _formatTime(String value) {
    // Handles:
    // 2026-12-01T08:00:00
    // 2026-12-01T08:00:00Z
    // 08:00
    if (value.contains("T")) {
      final timePart = value.split("T").last;

      if (timePart.length >= 5) {
        return timePart.substring(0, 5);
      }
    }

    if (value.length >= 5) {
      return value.substring(0, 5);
    }

    return value;
  }

  String _formatDuration(String value) {
    // Convert ISO duration such as PT1H15M
    // into a friendlier display: 1h 15m.
    if (value.startsWith("PT")) {
      final iso = value.substring(2);

      final hoursMatch = RegExp(r"(\d+)H").firstMatch(iso);
      final minutesMatch = RegExp(r"(\d+)M").firstMatch(iso);

      final hours = hoursMatch?.group(1);
      final minutes = minutesMatch?.group(1);

      if (hours != null && minutes != null) {
        return "${hours}h ${minutes}m";
      }

      if (hours != null) {
        return "${hours}h";
      }

      if (minutes != null) {
        return "${minutes}m";
      }
    }

    return value;
  }

  String get _offerId {
    return offer["id"]?.toString() ?? "Unknown Flight";
  }

  @override
  Widget build(BuildContext context) {
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
          // Airline + Flight ID
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _airline,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _offerId,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.55),
                  fontSize: 13,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Flight Times
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _depart,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    _from,
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
                    _arrive,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    _to,
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
            _duration,
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 18),

          // Price + Select Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "₦$_price",
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
                      arguments: offer,
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
}
