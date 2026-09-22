import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:utilityhub/config/api.dart';

import '../models/giftcard_trade.dart';

class GiftCardTradeService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ============================================================
  // AUTH
  // ============================================================

  Future<String> _token() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Please sign in before trading a gift card.');
    }

    final token = await user.getIdToken();

    if (token == null || token.trim().isEmpty) {
      throw Exception('Unable to authenticate your account.');
    }

    return token;
  }

  // ============================================================
  // URL
  // ============================================================

  Uri _uri(String path) {
    return Uri.parse(ApiConfig.api(path));
  }

  // ============================================================
  // SELL RATE CALCULATOR
  // ============================================================

  Future<Map<String, dynamic>> getRateCalculatorData() async {
    final token = await _token();

    final response = await http.get(
      _uri('/api/prestmit/sell/rates'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    return _decodeResponse(response);
  }

  // ============================================================
  // PAYOUT METHODS
  // ============================================================

  Future<Map<String, dynamic>> getPayoutMethods() async {
    final token = await _token();

    final response = await http.get(
      _uri('/api/prestmit/sell/payout-methods'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    return _decodeResponse(response);
  }

  // ============================================================
  // E-CODE DETECTION
  // ============================================================
  //
  // Prestmit may return forms such as:
  //
  //   Ecode
  //   E-code
  //   E Code
  //   e_code
  //   Digital
  //
  // Normalize all of these before determining whether the
  // transaction requires an E-code or physical card image.
  // ============================================================

  bool _isEcodeForm(String value) {
    final normalized = value
        .toLowerCase()
        .replaceAll('-', '')
        .replaceAll('_', '')
        .replaceAll(' ', '')
        .trim();

    return normalized == 'ecode' ||
        normalized == 'digital' ||
        normalized.contains('ecode');
  }

  // ============================================================
  // SUBMIT SELL TRADE
  // ============================================================

  Future<GiftCardTrade> submitTrade({
    required String giftcardId,
    required String brand,
    required String country,
    required String cardType,
    required String amount,
    required String rate,
    required String expectedPayout,
    required String payoutMethod,
    String? comments,
    List<XFile> images = const [],
  }) async {
    final token = await _token();

    final trimmedGiftcardId = giftcardId.trim();

    final trimmedAmount = amount.trim();

    final trimmedCardType = cardType.trim();

    final trimmedComments = comments?.trim();

    final trimmedPayoutMethod = payoutMethod.trim();

    // ==========================================================
    // BASIC VALIDATION
    // ==========================================================

    if (trimmedGiftcardId.isEmpty) {
      throw Exception('Gift card type is required.');
    }

    if (trimmedAmount.isEmpty) {
      throw Exception('Gift card amount is required.');
    }

    final parsedAmount = double.tryParse(trimmedAmount.replaceAll(',', ''));

    if (parsedAmount == null || parsedAmount <= 0) {
      throw Exception('Enter a valid gift card amount.');
    }

    if (trimmedPayoutMethod.isEmpty) {
      throw Exception('Please select a payout method.');
    }

    // ==========================================================
    // DETERMINE CARD FORM
    // ==========================================================

    final isEcode = _isEcodeForm(trimmedCardType);

    // ==========================================================
    // E-CODE VALIDATION
    // ==========================================================
    //
    // Prestmit's documented E-code flow is:
    //
    //   comments = actual E-code
    //   attachments = none
    //
    // Therefore we explicitly clear attachments for E-code
    // transactions before constructing the multipart request.
    // ==========================================================

    if (isEcode) {
      if (trimmedComments == null || trimmedComments.isEmpty) {
        throw Exception('Enter your gift card code.');
      }

      images = const [];
    }

    // ==========================================================
    // PHYSICAL CARD VALIDATION
    // ==========================================================

    if (!isEcode && images.isEmpty) {
      throw Exception('Upload at least one gift card image.');
    }

    if (images.length > 20) {
      throw Exception('You can upload a maximum of 20 images.');
    }

    // ==========================================================
    // CREATE MULTIPART REQUEST
    // ==========================================================

    final request = http.MultipartRequest(
      'POST',
      _uri('/api/prestmit/sell/create'),
    );

    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    // ==========================================================
    // REQUIRED PRESTMIT FIELDS
    // ==========================================================

    request.fields['giftcard_id'] = trimmedGiftcardId;

    request.fields['amount'] = trimmedAmount;

    request.fields['payoutMethod'] = trimmedPayoutMethod;

    // ==========================================================
    // LOCAL/UI CONTEXT
    // ==========================================================
    //
    // These are retained because your GiftPay backend/controller
    // can use them for local transaction information.
    //
    // The Prestmit backend service should only forward fields
    // supported by Prestmit's SELL API.
    // ==========================================================

    request.fields['brand'] = brand.trim();

    request.fields['country'] = country.trim();

    request.fields['cardType'] = trimmedCardType;

    request.fields['rate'] = rate.trim();

    request.fields['expectedPayout'] = expectedPayout.trim();

    // ==========================================================
    // COMMENTS
    // ==========================================================
    //
    // For E-code:
    //   comments = actual gift card code
    //
    // For physical cards:
    //   comments is optional.
    // ==========================================================

    if (trimmedComments != null && trimmedComments.isNotEmpty) {
      request.fields['comments'] = trimmedComments;
    }

    // ==========================================================
    // UNIQUE IDENTIFIER
    // ==========================================================

    request.fields['uniqueIdentifier'] =
        'giftpay-${DateTime.now().millisecondsSinceEpoch}';

    // ==========================================================
    // ATTACHMENTS
    // ==========================================================
    //
    // E-code:
    //   NO attachments
    //
    // Physical:
    //   JPG/PNG attachments
    //
    // This is deliberately based on the normalized Prestmit
    // form rather than merely checking whether the user selected
    // an image.
    // ==========================================================

    if (!isEcode) {
      for (final image in images) {
        final bytes = await image.readAsBytes();

        if (bytes.isEmpty) {
          throw Exception('One of the selected images is empty.');
        }

        if (bytes.length > 5 * 1024 * 1024) {
          throw Exception('Each gift card image must be 5 MB or smaller.');
        }

        final filename = image.name.isNotEmpty
            ? image.name
            : 'giftcard_${DateTime.now().millisecondsSinceEpoch}.jpg';

        final contentType = _contentType(filename);

        request.files.add(
          http.MultipartFile.fromBytes(
            'attachments[]',
            bytes,
            filename: filename,
            contentType: contentType,
          ),
        );
      }
    }

    // ==========================================================
    // SEND REQUEST
    // ==========================================================

    final streamedResponse = await request.send();

    final response = await http.Response.fromStream(streamedResponse);

    final body = _decodeResponse(response);

    // ==========================================================
    // READ LOCAL TRANSACTION
    // ==========================================================

    final transaction = body['transaction'];

    if (transaction is! Map) {
      throw Exception('The server did not return a valid sell transaction.');
    }

    return GiftCardTrade.fromMap({
      'id': transaction['id'],

      'providerReference': transaction['reference'],

      'brand': transaction['brand'] ?? brand,

      'country': transaction['country'] ?? country,

      'cardType': transaction['cardType'] ?? (isEcode ? 'E-code' : cardType),

      'amount': transaction['amount'] ?? amount,

      'rate': transaction['rate'] ?? rate,

      'valueInNaira': transaction['expectedPayout'] ?? expectedPayout,

      'images': transaction['images'] ?? const [],

      'status': transaction['status'] ?? 'PENDING',

      'providerStatus': transaction['providerStatus'] ?? 'PENDING',

      'payoutMethod': transaction['payoutMethod'] ?? payoutMethod,

      'rejectionReason': transaction['rejectionReason'],

      'comments': transaction['comments'] ?? trimmedComments,

      'createdAt': transaction['createdAt'] ?? DateTime.now().toIso8601String(),

      'updatedAt': transaction['updatedAt'],
    });
  }

  // ============================================================
  // HISTORY
  // ============================================================

  Future<List<GiftCardTrade>> getHistory() async {
    final token = await _token();

    final response = await http.get(
      _uri('/api/prestmit/sell/history'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    final body = _decodeResponse(response);

    final raw = body['transactions'];

    if (raw is! List) {
      return <GiftCardTrade>[];
    }

    return raw
        .whereType<Map>()
        .map((item) => GiftCardTrade.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  // ============================================================
  // GET SINGLE TRANSACTION
  // ============================================================

  Future<GiftCardTrade> getTransaction(String reference) async {
    final token = await _token();

    final response = await http.get(
      _uri('/api/prestmit/sell/$reference'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    final body = _decodeResponse(response);

    final transaction = body['transaction'];

    if (transaction is! Map) {
      throw Exception('Transaction information was not returned.');
    }

    return GiftCardTrade.fromMap(Map<String, dynamic>.from(transaction));
  }

  // ============================================================
  // REQUERY
  // ============================================================

  Future<GiftCardTrade> requeryTransaction(String reference) async {
    final token = await _token();

    final response = await http.post(
      _uri('/api/prestmit/sell/requery/$reference'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    _decodeResponse(response);

    // Always retrieve the refreshed
    // local transaction.
    return getTransaction(reference);
  }

  // ============================================================
  // RESPONSE DECODER
  // ============================================================

  Map<String, dynamic> _decodeResponse(http.Response response) {
    dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      throw Exception('The server returned an invalid response.');
    }

    if (decoded is! Map) {
      throw Exception('The server returned an invalid response.');
    }

    final body = Map<String, dynamic>.from(decoded);

    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        body['status'] == false) {
      final message = body['message']?.toString();

      throw Exception(
        message?.isNotEmpty == true
            ? message!
            : 'Gift card request failed (${response.statusCode}).',
      );
    }

    return body;
  }

  // ============================================================
  // IMAGE CONTENT TYPE
  // ============================================================

  http.MediaType _contentType(String filename) {
    final lower = filename.toLowerCase();

    if (lower.endsWith('.png')) {
      return http.MediaType('image', 'png');
    }

    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return http.MediaType('image', 'jpeg');
    }

    throw Exception('Only JPG and PNG gift card images are allowed.');
  }
}
