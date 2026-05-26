class SavedMeter {
  final String meterNumber;
  final String meterType;
  final String discoCode;
  final String customerName;
  final int lastUsed;

  SavedMeter({
    required this.meterNumber,
    required this.meterType,
    required this.discoCode,
    required this.customerName,
    required this.lastUsed,
  });

  factory SavedMeter.fromMap(Map<String, dynamic> map) {
    return SavedMeter(
      meterNumber: map['meterNumber'] ?? '',
      meterType: map['meterType'] ?? '',
      discoCode: map['discoCode'] ?? '',
      customerName: map['customerName'] ?? '',
      lastUsed: map['lastUsed'] ?? 0,
    );
  }
}
