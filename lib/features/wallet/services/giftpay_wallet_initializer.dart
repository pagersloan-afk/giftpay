import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GiftPayWalletInitializer {
  static Future<void> createPrimaryWalletIfMissing() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final walletRef = FirebaseFirestore.instance
        .collection("wallets")
        .doc(user.uid);

    final walletDoc = await walletRef.get();

    // ⭐ If wallet already exists (old users), do nothing
    if (walletDoc.exists) return;

    // ⭐ Create GiftPay Primary Wallet (same structure as old users)
    await walletRef.set({
      "balance": 0.0,
      "transactions": [],
      "createdAt": FieldValue.serverTimestamp(),
    });
  }
}
