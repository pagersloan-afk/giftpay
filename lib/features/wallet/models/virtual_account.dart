class VirtualAccount {
  final String bankName;
  final String accountNumber;
  final String accountName;
  final String provider;

  VirtualAccount({
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
    this.provider = 'monnify',
  });

  factory VirtualAccount.fromMap(Map<String, dynamic> map) {
    return VirtualAccount(
      bankName: (map['bankName'] ?? '').toString(),
      accountNumber: (map['accountNumber'] ?? '').toString(),
      accountName: (map['accountName'] ?? '').toString(),
      provider: (map['provider'] ?? 'monnify').toString(),
    );
  }
}
