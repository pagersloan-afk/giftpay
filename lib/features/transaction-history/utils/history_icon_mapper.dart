import 'package:flutter/material.dart';

class HistoryIconMapper {
  static Map<String, dynamic> detect(String title, String type) {
    title = title.toLowerCase().trim();
    type = type.toLowerCase().trim();

    // FOOD ORDERS
    // Match the Recent Transactions widget exactly:
    // Icons.restaurant_rounded with the warm gold theme color.
    if (type == "food_order" ||
        type == "food_order_refund" ||
        type == "food_refund" ||
        title.startsWith("food order") ||
        title.startsWith("giftpay food order")) {
      return {
        "icon": const Icon(Icons.restaurant_rounded, color: Color(0xFFFFC66D)),
        "color": const Color(0xFFFFC66D),
      };
    }

    // CREDIT
    if (type == "credit") {
      return {
        "icon": const Icon(Icons.arrow_downward, color: Colors.white),
        "color": Colors.green,
      };
    }

    // ELECTRICITY
    if (title.startsWith("electricity")) {
      return {
        "icon": const Icon(Icons.flash_on, color: Colors.white),
        "color": Colors.blue,
      };
    }

    // AIRTIME
    if (title.startsWith("airtime")) {
      return {
        "icon": const Icon(Icons.phone_android, color: Colors.white),
        "color": Colors.red,
      };
    }

    // DATA
    if (title.startsWith("data")) {
      return {
        "icon": const Icon(Icons.data_usage, color: Colors.white),
        "color": Colors.teal,
      };
    }

    // CABLE TV
    if (title.startsWith("cable")) {
      return {
        "icon": const Icon(Icons.tv, color: Colors.white),
        "color": Colors.deepPurple,
      };
    }

    // BETTING
    if (title.contains("betting") || type == "betting") {
      return {
        "icon": const Icon(Icons.sports_soccer, color: Colors.white),
        "color": Colors.green,
      };
    }

    // DEBIT
    if (type == "debit") {
      return {
        "icon": const Icon(Icons.arrow_upward, color: Colors.white),
        "color": Colors.red,
      };
    }

    // DEFAULT
    return {
      "icon": const Icon(Icons.receipt_long, color: Colors.white),
      "color": Colors.grey,
    };
  }
}
