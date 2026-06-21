import 'dart:io';

class ApiConfig {
  // Automatically detects if app is running in release mode
  static const bool isProduction = bool.fromEnvironment("dart.vm.product");

  static String get baseUrl {
    // ⭐ PRODUCTION URL
    if (isProduction) {
      return "https://api.giftpay.com"; // <-- your real production domain
    }

    // ⭐ WEB (Flutter Web)
    if (identical(0, 0.0)) {
      return "http://localhost:4000";
    }

    // ⭐ ANDROID (physical device)
    if (Platform.isAndroid) {
      return "http://192.168.1.2:4000"; // <-- your LAN IP
    }

    // ⭐ iOS simulator / Windows / macOS / Linux
    return "http://localhost:4000";
  }

  // ⭐ Helper to build endpoints cleanly
  static String api(String path) => "$baseUrl$path";
}
