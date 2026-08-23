import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'package:utilityhub/config/api.dart';

class UserServicesApi {
  // ------------------------------------------------------------
  // Save user layout to backend
  // ------------------------------------------------------------
  static Future<void> saveLayout({
    required String userId,
    required List<String> services,
  }) async {
    final base = await ApiConfig.baseUrl; // ✅ restored await
    final url = Uri.parse("$base/user/services/save");

    await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": userId, "services": services}),
    );
  }

  // ------------------------------------------------------------
  // Load user layout from backend
  // ------------------------------------------------------------
  static Future<List<String>?> loadLayout(String userId) async {
    final base = await ApiConfig.baseUrl; // ✅ restored await
    final url = Uri.parse("$base/user/services/$userId");

    final res = await http.get(url);

    if (res.statusCode != 200) return null;

    final data = jsonDecode(res.body);

    if (data["status"] != true) return null;
    if (data["services"] == null) return null;

    return List<String>.from(data["services"]);
  }

  // ------------------------------------------------------------
  // Log service usage analytics
  // ------------------------------------------------------------
  static Future<void> logUsage({
    required String userId,
    required String serviceName,
    required String device,
  }) async {
    final base = await ApiConfig.baseUrl; // ✅ restored await
    final url = Uri.parse("$base/analytics/service-usage");

    await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "serviceName": serviceName,
        "device": device,
      }),
    );
  }

  // ------------------------------------------------------------
  // Upload profile picture
  // ------------------------------------------------------------
  static Future<String> uploadProfilePicture({
    required List<int> imageBytes,
    required String filename,
    required String contentType,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User is not authenticated.");

    final idToken = await user.getIdToken(true);

    if (idToken == null || idToken.isEmpty) {
      throw Exception("Unable to obtain Firebase authentication token.");
    }

    final base = await ApiConfig.baseUrl; // ✅ also use await here
    final url = Uri.parse("$base/profile/upload-picture");

    final request = http.MultipartRequest("POST", url);
    request.headers.addAll({
      "Authorization": "Bearer $idToken",
      "Accept": "application/json",
    });

    request.files.add(
      http.MultipartFile.fromBytes(
        "image",
        imageBytes,
        filename: filename,
        contentType: _mediaType(contentType),
      ),
    );

    http.StreamedResponse streamedResponse;
    try {
      streamedResponse = await request.send();
    } catch (e) {
      throw Exception(
        "Unable to reach the profile upload service. "
        "Please check your internet connection and try again.",
      );
    }

    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractErrorMessage(response.statusCode, response.body));
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      throw Exception("Invalid response from profile upload service.");
    }

    if (decoded is! Map || decoded["status"] != true) {
      throw Exception(
        decoded["message"]?.toString() ??
            decoded["error"]?.toString() ??
            "Profile picture upload failed.",
      );
    }

    final profileUrl = decoded["profileUrl"];
    if (profileUrl is! String || profileUrl.trim().isEmpty) {
      throw Exception("Upload succeeded but no profile URL was returned.");
    }

    return profileUrl;
  }

  // ------------------------------------------------------------
  // Helpers
  // ------------------------------------------------------------
  static MediaType _mediaType(String contentType) {
    final parts = contentType.split("/");
    return parts.length == 2
        ? MediaType(parts[0], parts[1])
        : MediaType("image", "jpeg");
  }

  static String _extractErrorMessage(int statusCode, String body) {
    String? serverMessage;
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        serverMessage = decoded["message"]?.toString();
        serverMessage ??= decoded["error"]?.toString();
      }
    } catch (_) {}
    if (serverMessage != null && serverMessage.trim().isNotEmpty) {
      return serverMessage;
    }
    switch (statusCode) {
      case 400:
        return "Invalid profile picture.";
      case 401:
        return "Your Firebase session has expired. Please sign in again.";
      case 403:
        return "You are not authorized to upload a profile picture.";
      case 404:
        return "The profile upload service could not be found.";
      case 413:
        return "The selected image is too large. Maximum size is 5 MB.";
      case 415:
        return "Invalid image format. Please use JPG, PNG, or WebP.";
      case 500:
        return "The server encountered an error while uploading your picture.";
      case 502:
      case 503:
      case 504:
        return "The profile upload service is temporarily unavailable.";
      default:
        return body.trim().isNotEmpty
            ? body.trim()
            : "Profile picture upload failed. HTTP $statusCode.";
    }
  }
}
