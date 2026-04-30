class MeterVerification {
  final String meterNumber;
  final String customerName;
  final String address;
  final String disco;

  MeterVerification({
    required this.meterNumber,
    required this.customerName,
    required this.address,
    required this.disco,
  });

  factory MeterVerification.fromMap(Map<String, dynamic> map) {
    return MeterVerification(
      meterNumber: map["meterNumber"],
      customerName: map["customerName"],
      address: map["address"],
      disco: map["disco"],
    );
  }
}
