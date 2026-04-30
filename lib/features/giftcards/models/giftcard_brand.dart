class GiftCardBrand {
  final String id;
  final String name;
  final List<String> cardTypes;

  GiftCardBrand({
    required this.id,
    required this.name,
    required this.cardTypes,
  });

  factory GiftCardBrand.fromMap(Map<String, dynamic> map) {
    return GiftCardBrand(
      id: map["id"],
      name: map["name"],
      cardTypes: List<String>.from(map["cardTypes"]),
    );
  }
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GiftCardBrand &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
