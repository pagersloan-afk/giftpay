import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/giftcard_trade.dart';

class GiftCardTradeService {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> submitTrade({
    required String brand,
    required String country,
    required String cardType,
    required String amount,
    required String rate,
    required String valueInNaira,
    required List<File> images,
  }) async {
    final user = _auth.currentUser!;
    final docRef = _firestore.collection("giftcard_trades").doc();

    // 1. Upload images
    List<String> imageUrls = [];

    for (var img in images) {
      final ref = _storage.ref(
        "giftcard_trades/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg",
      );

      await ref.putFile(img);
      final url = await ref.getDownloadURL();
      imageUrls.add(url);
    }

    // 2. Create trade object using YOUR model
    final trade = GiftCardTrade(
      id: docRef.id,
      brand: brand,
      country: country,
      cardType: cardType,
      amount: amount,
      rate: rate,
      valueInNaira: valueInNaira,
      images: imageUrls,
      status: "pending",
      createdAt: DateTime.now(),
    );

    // 3. Save to Firestore
    await docRef.set(trade.toMap());
  }
}
