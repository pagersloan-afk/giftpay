class AviationFareUtils {
  const AviationFareUtils._();

  static double extractBaseFare(Map<String, dynamic> booking) {
    final offer = booking["offer"];
    if (offer is! Map) return 0;

    final price = offer["price"];
    if (price is num) return price.toDouble();
    if (price is String) {
      return double.tryParse(price.replaceAll(",", "").trim()) ?? 0;
    }
    if (price is Map) {
      final total = price["total"];
      if (total is num) return total.toDouble();
      if (total is String) {
        return double.tryParse(total.replaceAll(",", "").trim()) ?? 0;
      }
    }
    return 0;
  }

  static int calculateTax(double baseFare) => (baseFare * 0.075).round();
  static const int serviceFee = 2500;

  static int calculateTotal(double baseFare) =>
      baseFare.round() + calculateTax(baseFare) + serviceFee;

  static String formatNaira(num amount) => "₦${amount.round()}";

  static double toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(",", "").trim()) ?? 0;
    }
    return 0;
  }
}
