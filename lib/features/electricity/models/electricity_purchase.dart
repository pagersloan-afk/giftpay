class ElectricityPurchase {
  final String meterNumber;
  final String token;
  final String amount;
  final DateTime date;

  ElectricityPurchase({
    required this.meterNumber,
    required this.token,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      "meterNumber": meterNumber,
      "token": token,
      "amount": amount,
      "date": date.toIso8601String(),
    };
  }
}
