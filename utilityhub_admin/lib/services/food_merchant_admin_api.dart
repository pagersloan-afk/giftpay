import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

/// Set the deployed backend URL at build time, for example:
/// flutter run -d chrome --dart-define=API_BASE_URL=https://api.example.com
///
/// Do not include a trailing slash.
const String _apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:4000',
);

class FoodMerchantReviewResult {
  final String message;
  final bool? emailSent;
  final String? emailError;

  const FoodMerchantReviewResult({
    required this.message,
    this.emailSent,
    this.emailError,
  });
}

class FoodMerchantAdminApi {
  static Future<FoodMerchantReviewResult> review({
    required String merchantUid,
    required String decision,
    required bool registrationChecked,
    required bool foodSafetyChecked,
    required String notes,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Admin session expired. Please sign in again.');
    }

    final idToken = await user.getIdToken(true);
    if (idToken == null || idToken.isEmpty) {
      throw Exception('Unable to obtain your Firebase authentication token.');
    }

    final base = _apiBaseUrl.replaceFirst(RegExp(r'/+$'), '');
    final uri = Uri.parse(
      '$base/api/food-admin/merchant/${Uri.encodeComponent(merchantUid)}/review',
    );

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({
        'decision': decision,
        'registrationChecked': registrationChecked,
        'foodSafetyChecked': foodSafetyChecked,
        'notes': notes,
      }),
    );

    Map<String, dynamic> payload = {};
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) payload = decoded;
    } catch (_) {
      // A non-JSON response is reported below using the HTTP status.
    }

    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        payload['status'] != true) {
      throw Exception(
        (payload['message'] ?? 'Review request failed (${response.statusCode}).')
            .toString(),
      );
    }

    return FoodMerchantReviewResult(
      message: (payload['message'] ?? 'Review completed.').toString(),
      emailSent: payload['emailSent'] is bool ? payload['emailSent'] as bool : null,
      emailError: payload['emailError']?.toString(),
    );
  }
}
