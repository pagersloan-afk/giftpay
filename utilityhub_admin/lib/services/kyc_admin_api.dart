import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class KycAdminApi {
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:4000',
  );

  static Future<Map<String, String?>> getDocumentUrls(String uid) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Admin session expired. Please sign in again.');
    final token = await user.getIdToken();
    if (token == null || token.isEmpty) throw Exception('Could not obtain Firebase ID token.');

    final uri = Uri.parse('$_baseUrl/api/admin/kyc/${Uri.encodeComponent(uid)}/documents');
    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    Map<String, dynamic> body = {};
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) body = decoded;
    } catch (_) {}

    if (response.statusCode != 200 || body['status'] != true) {
      throw Exception(body['message']?.toString() ?? 'Document request failed (${response.statusCode}).');
    }
    final docs = body['documents'];
    if (docs is! Map) throw Exception('Invalid document response from backend.');
    return {
      'idFront': docs['idFront']?.toString(),
      'idBack': docs['idBack']?.toString(),
      'selfie': docs['selfie']?.toString(),
    };
  }
}
