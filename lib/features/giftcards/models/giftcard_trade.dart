class GiftCardTrade {
  final String id;
  final String brand;
  final String country;
  final String cardType;
  final String amount;
  final String rate;
  final String valueInNaira;
  final List<String> images;
  final String status; // pending, reviewing, completed, rejected
  final DateTime createdAt;

  GiftCardTrade({
    required this.id,
    required this.brand,
    required this.country,
    required this.cardType,
    required this.amount,
    required this.rate,
    required this.valueInNaira,
    required this.images,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "brand": brand,
      "country": country,
      "cardType": cardType,
      "amount": amount,
      "rate": rate,
      "valueInNaira": valueInNaira,
      "images": images,
      "status": status,
      "createdAt": createdAt.toIso8601String(),
    };
  }

  factory GiftCardTrade.fromMap(Map<String, dynamic> map) {
    return GiftCardTrade(
      id: map["id"],
      brand: map["brand"],
      country: map["country"],
      cardType: map["cardType"],
      amount: map["amount"],
      rate: map["rate"],
      valueInNaira: map["valueInNaira"],
      images: List<String>.from(map["images"]),
      status: map["status"],
      createdAt: DateTime.parse(map["createdAt"]),
    );
  }
}
