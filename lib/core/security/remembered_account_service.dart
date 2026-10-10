import 'package:shared_preferences/shared_preferences.dart';

/// Stores only the last successfully authenticated email address.
///
/// IMPORTANT: Never store the user's Firebase password here.
class RememberedAccountService {
  static const String _emailKey = 'giftpay.remembered_login_email';

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_emailKey)?.trim();

    if (email == null || email.isEmpty) {
      return null;
    }

    return email;
  }

  static Future<void> saveEmail(String email) async {
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, normalized);
  }

  static Future<void> clearEmail() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_emailKey);
  }
}
