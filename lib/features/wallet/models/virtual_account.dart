class VirtualAccount {
  final String bankName;
  final String accountNumber;
  final String accountName;

  VirtualAccount({
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
  });

  factory VirtualAccount.fromMap(Map<String, dynamic> map) {
    return VirtualAccount(
      bankName: map["bankName"] ?? "",
      accountNumber: map["accountNumber"] ?? "",
      accountName: map["accountName"] ?? "",
    );
  }
}
