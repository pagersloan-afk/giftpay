import 'dart:convert';
import 'package:http/http.dart' as http;
import 'aviation_mock_data.dart';
import 'aviation_models.dart';

class AviationApiService {
  AviationApiService({
    this.baseUrl = "https://your-backend-url.com/api/aviation",
    this.useMockData = true,
  });

  final String baseUrl;
  final bool useMockData;

  Future<List<Map<String, dynamic>>> searchFlights(
    AviationSearchRequest request,
  ) async {
    if (useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      return aviationMockOffers;
    }

    final response = await http.post(
      Uri.parse("$baseUrl/search"),
      headers: const {"Content-Type": "application/json"},
      body: jsonEncode(request.toJson()),
    );

    _ensureSuccess(response);
    final decoded = jsonDecode(response.body);

    if (decoded is List) {
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    if (decoded is Map && decoded["offers"] is List) {
      return (decoded["offers"] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    throw const FormatException("Invalid flight search response.");
  }

  Future<Map<String, dynamic>> createBooking(
    AviationBookingRequest request,
  ) async {
    if (useMockData) {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      final offer = aviationMockOffers.firstWhere(
        (o) => o["id"] == request.offerId,
        orElse: () => aviationMockOffers.first,
      );
      return aviationMockBooking(
        offer: offer,
        passenger: request.passenger.toJson(),
      );
    }

    final response = await http.post(
      Uri.parse("$baseUrl/book"),
      headers: const {"Content-Type": "application/json"},
      body: jsonEncode(request.toJson()),
    );

    _ensureSuccess(response);
    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const FormatException("Invalid booking response.");
    }
    return Map<String, dynamic>.from(decoded);
  }

  Future<Map<String, dynamic>> generateTicket({
    required String bookingId,
    required double total,
    required String paymentMethod,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/ticket"),
      headers: const {"Content-Type": "application/json"},
      body: jsonEncode({
        "bookingId": bookingId,
        "total": total,
        "paymentMethod": paymentMethod,
      }),
    );

    _ensureSuccess(response);
    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const FormatException("Invalid ticket response.");
    }
    return Map<String, dynamic>.from(decoded);
  }

  Map<String, dynamic> generateMockTicket({
    required Map<String, dynamic> booking,
    required double total,
    required String paymentMethod,
  }) => aviationMockTicket(
    booking: booking,
    total: total,
    paymentMethod: paymentMethod,
  );

  void _ensureSuccess(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        "Aviation API error ${response.statusCode}: ${response.body}",
      );
    }
  }
}
