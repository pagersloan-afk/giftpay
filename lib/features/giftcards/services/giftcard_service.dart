import 'dart:async';
import 'package:utilityhub/features/giftcards/models/giftcard_brand.dart';

class GiftCardService {
  final bool mockMode;

  GiftCardService({this.mockMode = true});

  /// Fetch all gift card brands + their card types
  Future<List<GiftCardBrand>> getBrands() async {
    if (mockMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      return [
        GiftCardBrand(
          id: "1",
          name: "Amazon",
          cardTypes: ["USA", "UK", "Global"],
        ),
        GiftCardBrand(
          id: "2",
          name: "Apple",
          cardTypes: ["USA", "UK", "Canada"],
        ),
        GiftCardBrand(id: "3", name: "Steam", cardTypes: ["Global", "USA"]),
      ];
    }

    // TODO: Replace with real backend API
    return [];
  }

  /// Buy a gift card after successful Paystack payment
  Future<String> buyGiftCard({
    required String brand,
    required String cardType,
    required String amount,
  }) async {
    if (mockMode) {
      await Future.delayed(const Duration(seconds: 1));
      return "GC-${DateTime.now().millisecondsSinceEpoch}";
    }

    // TODO: Replace with real backend API call
    await Future.delayed(const Duration(seconds: 1));
    return "XXXX-XXXX-XXXX";
  }
}
