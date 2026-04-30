import 'package:flutter/material.dart';

class HistoryIconMapper {
  static Map<String, dynamic> detect(String title, String type) {
    title = title.toLowerCase();

    // ⭐ CREDIT
    if (type == "credit") {
      return {
        "icon": const Icon(Icons.arrow_downward, color: Colors.white),
        "color": Colors.green,
      };
    }

    // ⭐ ELECTRICITY
    if (title.startsWith("electricity")) {
      return {
        "icon": const Icon(Icons.flash_on, color: Colors.white),
        "color": Colors.blue,
      };
    }

    // ⭐ AIRTIME
    if (title.startsWith("airtime")) {
      return {
        "icon": const Icon(Icons.phone_android, color: Colors.white),
        "color": Colors.red,
      };
    }

    // ⭐ DATA
    if (title.startsWith("data")) {
      return {
        "icon": const Icon(Icons.data_usage, color: Colors.white),
        "color": Colors.teal,
      };
    }

    // ⭐ CABLE TV
    if (title.startsWith("cable")) {
      return {
        "icon": const Icon(Icons.tv, color: Colors.white),
        "color": Colors.deepPurple,
      };
    }

    // ⭐ BETTING (NEW)
    if (title.contains("betting") || type == "betting") {
      return {
        "icon": const Icon(Icons.sports_soccer, color: Colors.white),
        "color": Colors.green,
      };
    }

    // ⭐ DEBIT
    if (type == "debit") {
      return {
        "icon": const Icon(Icons.arrow_upward, color: Colors.white),
        "color": Colors.red,
      };
    }

    // ⭐ DEFAULT
    return {
      "icon": const Icon(Icons.receipt_long, color: Colors.white),
      "color": Colors.grey,
    };
  }
}
