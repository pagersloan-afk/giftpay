import 'dart:io';

class ApiConfig {
  // Automatically detects if app is running in release mode
  static const bool isProduction = bool.fromEnvironment("dart.vm.product");

  static String get baseUrl {
    // ⭐ PRODUCTION
    if (isProduction) {
      return "https://gifttechnologyltd.com";
    }

    // ⭐ FLUTTER WEB
    if (identical(0, 0.0)) {
      return "http://localhost:4000";
    }

    // ⭐ ANDROID PHYSICAL DEVICE
    if (Platform.isAndroid) {
      return "http://192.168.1.10:4000";
    }

    // ⭐ iOS simulator / Windows / macOS / Linux
    return "http://localhost:4000";
  }

  // ⭐ Generic backend endpoint
  static String api(String path) {
    return "$baseUrl$path";
  }

  // ⭐ Express API routes mounted under /api
  static String apiRoute(String path) {
    final cleanPath = path.startsWith("/") ? path : "/$path";

    return "$baseUrl/api$cleanPath";
  }
}
