import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utilityhub/core/services/user_services_api.dart';
import 'services_catalog.dart';

class ServicesManager {
  static const _key = "user_services";

  // Load layout (cloud → local → default)
  static Future<List<ServiceItem>> load({required String userId}) async {
    final prefs = await SharedPreferences.getInstance();

    // 1️⃣ Try cloud first
    final cloud = await UserServicesApi.loadLayout(userId);
    if (cloud != null) {
      await prefs.setString(_key, jsonEncode(cloud));
      return _mapTitlesToItems(cloud);
    }

    // 2️⃣ Try local
    final raw = prefs.getString(_key);
    if (raw != null) {
      final list = List<String>.from(jsonDecode(raw));
      return _mapTitlesToItems(list);
    }

    // 3️⃣ Default (first 8 services)
    final defaults = ServicesCatalog.all.take(8).toList();
    await save(defaults, userId: userId);
    return defaults;
  }

  // Save layout (local + cloud)
  static Future<void> save(
    List<ServiceItem> items, {
    required String userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final titles = items.map((e) => e.title).toList();

    // Save locally
    await prefs.setString(_key, jsonEncode(titles));

    // Save to backend
    await UserServicesApi.saveLayout(userId: userId, services: titles);
  }

  // Helper: convert titles → ServiceItem list
  static List<ServiceItem> _mapTitlesToItems(List<String> titles) {
    return titles.map((title) {
      return ServicesCatalog.all.firstWhere(
        (s) => s.title == title,
        orElse: () => ServicesCatalog.all.first,
      );
    }).toList();
  }
}
