class GiftCardBrand {
  final String sku;
  final String name;
  final String currencyCode;
  final double minPrice;
  final double maxPrice;
  final bool preOrder;

  const GiftCardBrand({
    required this.sku,
    required this.name,
    required this.currencyCode,
    required this.minPrice,
    required this.maxPrice,
    required this.preOrder,
  });

  factory GiftCardBrand.fromMap(Map<String, dynamic> map) {
    final skuValue = map["sku"] ?? map["giftCardSKU"] ?? map["id"];

    final minValue = map["minPrice"] ?? map["min"] ?? 0;
    final maxValue = map["maxPrice"] ?? map["max"] ?? 0;

    return GiftCardBrand(
      sku: skuValue.toString(),
      name:
          (map["name"] ??
                  map["giftCardName"] ??
                  map["productName"] ??
                  "Gift Card")
              .toString(),
      currencyCode: (map["currencyCode"] ?? map["currency"] ?? "")
          .toString()
          .toUpperCase(),
      minPrice: double.tryParse(minValue.toString()) ?? 0,
      maxPrice: double.tryParse(maxValue.toString()) ?? 0,
      preOrder: map["preOrder"] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "sku": sku,
      "name": name,
      "currencyCode": currencyCode,
      "minPrice": minPrice,
      "maxPrice": maxPrice,
      "preOrder": preOrder,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GiftCardBrand &&
          runtimeType == other.runtimeType &&
          sku == other.sku;

  @override
  int get hashCode => sku.hashCode;
}
