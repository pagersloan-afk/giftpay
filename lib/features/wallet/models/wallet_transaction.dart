class WalletTransaction {
  final String id;
  final String type; // credit or debit
  final String title;
  final String amount;
  final DateTime date;

  WalletTransaction({
    required this.id,
    required this.type,
    required this.title,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "type": type,
      "title": title,
      "amount": amount,
      "date": date.toIso8601String(),
    };
  }

  factory WalletTransaction.fromMap(Map<String, dynamic> map) {
    return WalletTransaction(
      id: map["id"],
      type: map["type"],
      title: map["title"],
      amount: map["amount"],
      date: DateTime.parse(map["date"]),
    );
  }
}
