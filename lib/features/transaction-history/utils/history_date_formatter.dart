import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryDateFormatter {
  static String safeDate(dynamic raw) {
    try {
      if (raw == null) return "Unknown";

      if (raw is int) {
        return DateFormat(
          "dd MMM yyyy • h:mm a",
        ).format(DateTime.fromMillisecondsSinceEpoch(raw));
      }

      if (raw is Timestamp) {
        return DateFormat("dd MMM yyyy • h:mm a").format(raw.toDate());
      }

      if (raw is String) {
        final dt = DateTime.tryParse(raw);
        if (dt != null) {
          return DateFormat("dd MMM yyyy • h:mm a").format(dt);
        }
      }

      return raw.toString();
    } catch (_) {
      return raw.toString();
    }
  }
}
