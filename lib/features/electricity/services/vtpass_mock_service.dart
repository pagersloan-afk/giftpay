class VTPassMockService {
  Future<Map<String, dynamic>> verifyMeter({
    required String meterNumber,
    required String disco,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    return {
      "code": "000",
      "content": {
        "Customer_Name": "Gift Baker",
        "Meter_Number": meterNumber,
        "Address": "Port Harcourt",
        "Business_Unit": disco,
        "Tariff": "Residential",
      },
      "request_id": "mock-${DateTime.now().millisecondsSinceEpoch}",
    };
  }

  Future<Map<String, dynamic>> buyElectricity({
    required String meterNumber,
    required String disco,
    required String amount,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    return {
      "code": "000",
      "token": "1234-5678-9012-3456",
      "units": "23.5",
      "amount": amount,
      "request_id": "mock-${DateTime.now().millisecondsSinceEpoch}",
    };
  }

  Future<Map<String, dynamic>> buyAirtime({
    required String phone,
    required String amount,
    required String networkId,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    return {
      "code": "000",
      "message": "Airtime sent successfully",
      "phone": phone,
      "amount": amount,
      "network": networkId,
    };
  }

  Future<Map<String, dynamic>> buyData({
    required String phone,
    required String networkId,
    required String variationCode,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    return {
      "code": "000",
      "message": "Data activated successfully",
      "phone": phone,
      "bundle": variationCode,
      "network": networkId,
    };
  }

  Future<Map<String, dynamic>> subscribeCable({
    required String smartCard,
    required String variationCode,
    required String provider,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    return {
      "code": "000",
      "message": "Subscription successful",
      "smartcard": smartCard,
      "plan": variationCode,
      "provider": provider,
    };
  }
}
