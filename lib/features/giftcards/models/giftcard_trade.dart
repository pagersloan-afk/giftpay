class GiftCardTrade {
  final String id;
  final String providerReference;
  final String brand;
  final String country;
  final String cardType;
  final String amount;
  final String rate;
  final String valueInNaira;
  final List<String> images;
  final String status;
  final String providerStatus;
  final String payoutMethod;
  final String? rejectionReason;
  final String? comments;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const GiftCardTrade({
    required this.id,
    required this.providerReference,
    required this.brand,
    required this.country,
    required this.cardType,
    required this.amount,
    required this.rate,
    required this.valueInNaira,
    required this.images,
    required this.status,
    required this.providerStatus,
    required this.payoutMethod,
    this.rejectionReason,
    this.comments,
    required this.createdAt,
    this.updatedAt,
  });

  factory GiftCardTrade.fromMap(Map<String, dynamic> map) {
    return GiftCardTrade(
      id: _string(map['id']),
      providerReference: _string(map['providerReference'] ?? map['reference']),
      brand: _string(map['brand'] ?? map['categoryName']),
      country: _string(map['country']),
      cardType: _string(map['cardType'] ?? map['form']),
      amount: _string(map['amount']),
      rate: _string(map['rate']),
      valueInNaira: _string(
        map['valueInNaira'] ?? map['expectedPayout'] ?? map['totalAmount'],
      ),
      images: _stringList(map['images']),
      status: _normalizeStatus(map['status']),
      providerStatus: _normalizeStatus(
        map['providerStatus'] ?? map['provider_status'],
      ),
      payoutMethod: _string(
        map['payoutMethod'] ?? map['payout_method'] ?? 'NAIRA',
      ),
      rejectionReason: map['rejectionReason']?.toString(),
      comments: map['comments']?.toString(),
      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseNullableDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'providerReference': providerReference,
      'brand': brand,
      'country': country,
      'cardType': cardType,
      'amount': amount,
      'rate': rate,
      'valueInNaira': valueInNaira,
      'images': images,
      'status': status,
      'providerStatus': providerStatus,
      'payoutMethod': payoutMethod,
      'rejectionReason': rejectionReason,
      'comments': comments,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static String _string(dynamic value) {
    if (value == null) {
      return '';
    }

    return value.toString();
  }

  static List<String> _stringList(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }

    return <String>[];
  }

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      final parsed = DateTime.tryParse(value);

      if (parsed != null) {
        return parsed;
      }
    }

    if (value is Map) {
      final seconds = value['_seconds'] ?? value['seconds'];

      if (seconds is num) {
        return DateTime.fromMillisecondsSinceEpoch(seconds.toInt() * 1000);
      }
    }

    return DateTime.now();
  }

  static DateTime? _parseNullableDate(dynamic value) {
    if (value == null) {
      return null;
    }

    return _parseDate(value);
  }

  static String _normalizeStatus(dynamic value) {
    final status = value?.toString().toUpperCase() ?? 'PENDING';

    switch (status) {
      case 'COMPLETED':
        return 'completed';

      case 'REJECTED':
      case 'FAILED':
        return 'rejected';

      case 'PROCESSING':
      case 'PENDING':
        return 'pending';

      default:
        return status.toLowerCase();
    }
  }
}
