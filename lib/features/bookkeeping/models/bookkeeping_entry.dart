class BookkeepingEntry {
  final String id;
  final String type;
  final String description;
  final String category;
  final String notes;
  final String entryDate;
  final int amountKobo;
  final int cashBalanceAfterKobo;
  final int savingsBalanceAfterKobo;

  const BookkeepingEntry({
    required this.id,
    required this.type,
    required this.description,
    required this.category,
    required this.notes,
    required this.entryDate,
    required this.amountKobo,
    required this.cashBalanceAfterKobo,
    required this.savingsBalanceAfterKobo,
  });

  factory BookkeepingEntry.fromMap(Map<String, dynamic> map) {
    int asInt(dynamic value) => value is num
        ? value.toInt()
        : int.tryParse(value?.toString() ?? '') ?? 0;

    return BookkeepingEntry(
      id: map['id']?.toString() ?? '',
      type: map['type']?.toString() ?? 'expense',
      description: map['description']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      notes: map['notes']?.toString() ?? '',
      entryDate: map['entryDate']?.toString() ?? '',
      amountKobo: asInt(map['amountKobo']),
      cashBalanceAfterKobo: asInt(map['cashBalanceAfterKobo']),
      savingsBalanceAfterKobo: asInt(map['savingsBalanceAfterKobo']),
    );
  }

  Map<String, dynamic> toPayload() => {
        'type': type,
        'description': description,
        'category': category,
        'notes': notes,
        'entryDate': entryDate,
        'amountKobo': amountKobo,
      };
}
