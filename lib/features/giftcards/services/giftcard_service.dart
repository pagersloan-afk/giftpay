import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:utilityhub/config/api.dart';
import 'package:utilityhub/features/giftcards/models/giftcard_brand.dart';

class GiftCardService {
  Future<Map<String, String>> _headers() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("You must be signed in to buy a gift card.");
    }

    final token = await user.getIdToken();

    return {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
      "Accept": "application/json",
    };
  }

  dynamic _decodeResponse(http.Response response) {
    dynamic data;

    try {
      data = jsonDecode(response.body);
    } catch (_) {
      throw Exception("Invalid server response (${response.statusCode}).");
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (data is Map<String, dynamic>) {
        throw Exception(
          data["message"]?.toString() ??
              "Request failed (${response.statusCode}).",
        );
      }

      throw Exception("Request failed (${response.statusCode}).");
    }

    if (data is Map<String, dynamic> && data["status"] == false) {
      throw Exception(
        data["message"]?.toString() ?? "Gift card request failed.",
      );
    }

    return data;
  }

  dynamic _extractData(dynamic response) {
    if (response is Map<String, dynamic>) {
      return response["data"] ?? response;
    }

    return response;
  }

  /// Fetch the live Prestmit gift-card catalog through GiftPay backend.
  Future<List<GiftCardBrand>> getCatalog({
    String? currencyCode,
    int page = 1,
    int perPage = 25,
  }) async {
    final headers = await _headers();

    final queryParameters = <String, String>{
      "page": page.toString(),
      "perPage": perPage.toString(),
    };

    if (currencyCode != null && currencyCode.trim().isNotEmpty) {
      queryParameters["currencyCode"] = currencyCode.trim();
    }

    final uri = Uri.parse(
      ApiConfig.api("/api/prestmit/catalog"),
    ).replace(queryParameters: queryParameters);

    final response = await http.get(uri, headers: headers);

    final decoded = _decodeResponse(response);
    final data = _extractData(decoded);

    dynamic products;

    if (data is List) {
      products = data;
    } else if (data is Map<String, dynamic>) {
      products =
          data["data"] ??
          data["giftCards"] ??
          data["giftcards"] ??
          data["products"] ??
          data["items"] ??
          data["results"] ??
          [];
    }

    if (products is! List) {
      return [];
    }

    return products
        .whereType<Map>()
        .map((item) => GiftCardBrand.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  /// Check whether a Prestmit SKU/price/quantity combination is available.
  Future<bool> checkAvailability({
    required String sku,
    required double price,
    int quantity = 1,
  }) async {
    final headers = await _headers();

    final response = await http.post(
      Uri.parse(ApiConfig.api("/api/prestmit/check-availability")),
      headers: headers,
      body: jsonEncode({
        "giftCardSKU": sku,
        "price": price,
        "quantity": quantity,
      }),
    );

    final decoded = _decodeResponse(response);
    final data = _extractData(decoded);

    if (data is Map<String, dynamic>) {
      return data["isAvailable"] == true;
    }

    return false;
  }

  /// Ask Prestmit to calculate the actual payment amount.
  Future<Map<String, dynamic>> calculatePayment({
    required String sku,
    required double price,
    int quantity = 1,
  }) async {
    final headers = await _headers();

    final response = await http.post(
      Uri.parse(ApiConfig.api("/api/prestmit/calculate-payment")),
      headers: headers,
      body: jsonEncode({
        "giftCardSKU": sku,
        "price": price,
        "quantity": quantity,
      }),
    );

    final decoded = _decodeResponse(response);
    final data = _extractData(decoded);

    if (data is! Map<String, dynamic>) {
      throw Exception("Invalid payment calculation response.");
    }

    return data;
  }

  /// Check availability and calculate the payment in one operation.
  Future<Map<String, dynamic>> getQuote({
    required String sku,
    required double price,
    int quantity = 1,
  }) async {
    final available = await checkAvailability(
      sku: sku,
      price: price,
      quantity: quantity,
    );

    if (!available) {
      throw Exception(
        "This gift card is currently unavailable for the selected amount.",
      );
    }

    final quote = await calculatePayment(
      sku: sku,
      price: price,
      quantity: quantity,
    );

    if (quote["isAvailable"] == false) {
      throw Exception(
        "This gift card is currently unavailable for the selected amount.",
      );
    }

    return quote;
  }

  /// Create the actual Prestmit gift-card purchase.
  /// Extract the amount the GiftPay customer should actually pay.
  ///
  /// The backend is the source of truth. Older responses may only contain
  /// Prestmit's provider amount, so the 3% customer total is used only as a
  /// compatibility fallback for old backend responses. The UI never displays
  /// the fee itself.
  double customerDebitAmount(Map<String, dynamic> quote) {
    final directKeys = [
      "customerDebitAmount",
      "customerAmount",
      "customerTotal",
      "walletDebitAmount",
    ];

    for (final key in directKeys) {
      final value = _number(quote[key]);
      if (value != null && value > 0) return value;
    }

    final providerAmount =
        _number(quote["totalPaymentAmount"]) ?? _number(quote["NAIRA"]);

    if (providerAmount != null && providerAmount > 0) {
      return providerAmount * 1.03;
    }

    throw Exception("A valid customer payment amount was not returned.");
  }

  double? _number(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString().replaceAll(',', '') ?? '');
  }

  Future<Map<String, dynamic>> buyGiftCard({
    required String sku,
    required double price,
    int quantity = 1,
    required String paymentMethod,
    required String uniqueIdentifier,
    String? currentAccountPIN,
    String? twoFactorCode,
  }) async {
    final headers = await _headers();

    final body = <String, dynamic>{
      "giftCardSKU": sku,
      "price": price,
      "quantity": quantity,
      "paymentMethod": paymentMethod,
      "uniqueIdentifier": uniqueIdentifier,
    };

    if (currentAccountPIN != null && currentAccountPIN.trim().isNotEmpty) {
      body["currentAccountPIN"] = currentAccountPIN.trim();
    }

    if (twoFactorCode != null && twoFactorCode.trim().isNotEmpty) {
      body["2fa_code"] = twoFactorCode.trim();
    }

    final response = await http.post(
      Uri.parse(ApiConfig.api("/api/prestmit/buy")),
      headers: headers,
      body: jsonEncode(body),
    );

    final decoded = _decodeResponse(response);
    final data = _extractData(decoded);

    if (data is! Map<String, dynamic>) {
      throw Exception("Invalid Prestmit purchase response.");
    }

    return data;
  }

  /// Re-query a Prestmit purchase through the GiftPay backend.
  ///
  /// The backend checks Prestmit's latest transaction status and updates
  /// the local GiftPay purchase/wallet state when appropriate.
  Future<Map<String, dynamic>> requeryPrestmitPurchase({
    required String reference,
  }) async {
    final headers = await _headers();

    final response = await http.post(
      Uri.parse(
        ApiConfig.api(
          "/api/prestmit/requery/${Uri.encodeComponent(reference)}",
        ),
      ),
      headers: headers,
    );

    final decoded = _decodeResponse(response);
    final data = _extractData(decoded);

    if (data is! Map<String, dynamic>) {
      throw Exception("Invalid Prestmit status response.");
    }

    return data;
  }

  /// Fetch the gift-card codes using Prestmit's transaction reference.
  Future<Map<String, dynamic>> fetchGiftCardCodes({
    required String reference,
  }) async {
    final headers = await _headers();

    final response = await http.get(
      Uri.parse(
        ApiConfig.api("/api/prestmit/codes/${Uri.encodeComponent(reference)}"),
      ),
      headers: headers,
    );

    final decoded = _decodeResponse(response);
    final data = _extractData(decoded);

    if (data is! Map<String, dynamic>) {
      throw Exception("Invalid gift-card code response.");
    }

    return data;
  }

  /// Fetch Prestmit purchase history.
  Future<dynamic> getHistory({
    String? referenceOrID,
    String? uniqueIdentifier,
    int page = 1,
    int perPage = 25,
  }) async {
    final headers = await _headers();

    final query = <String, String>{
      "page": page.toString(),
      "perPage": perPage.toString(),
    };

    if (referenceOrID != null && referenceOrID.trim().isNotEmpty) {
      query["referenceOrID"] = referenceOrID.trim();
    }

    if (uniqueIdentifier != null && uniqueIdentifier.trim().isNotEmpty) {
      query["uniqueIdentifier"] = uniqueIdentifier.trim();
    }

    final uri = Uri.parse(
      ApiConfig.api("/api/prestmit/history"),
    ).replace(queryParameters: query);

    final response = await http.get(uri, headers: headers);

    return _decodeResponse(response);
  }
}
