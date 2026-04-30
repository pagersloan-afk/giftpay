import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/wallet_transaction.dart';

class WalletService {
  final walletRef = FirebaseFirestore.instance.collection("wallets");

  /// ⭐ Always get the current user dynamically and safely
  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  Future<void> createWalletIfNotExists() async {
    if (uid == null) return; // ⛔ Prevent crash before login

    final doc = await walletRef.doc(uid).get();

    if (!doc.exists) {
      await walletRef.doc(uid).set({"balance": 0, "transactions": []});
    }
  }

  /// ⭐ REAL-TIME BALANCE STREAM — only runs when user is logged in
  Stream<double> balanceStream() {
    if (uid == null) {
      print("[WALLET DEBUG] No user logged in → returning 0.0 stream");
      return Stream.value(0.0);
    }

    return walletRef.doc(uid!).snapshots().map((doc) {
      final data = doc.data();
      print('[WALLET DEBUG] Firestore doc data: $data');

      if (data == null) return 0.0;

      final bal = data['balance'];
      print('[WALLET DEBUG] balance field: $bal (${bal.runtimeType})');

      if (bal is int) return bal.toDouble();
      if (bal is double) return bal;
      if (bal is String) return double.tryParse(bal) ?? 0.0;

      return 0.0;
    });
  }

  Stream<double> walletBalanceStream() => balanceStream();

  /// ⭐ REAL-TIME TRANSACTION STREAM — safe for null user
  Stream<List<WalletTransaction>> transactionStream() {
    if (uid == null) {
      print(
        "[WALLET DEBUG] No user logged in → returning empty transaction list",
      );
      return Stream.value([]);
    }

    return walletRef.doc(uid!).snapshots().map((doc) {
      final list = doc.data()?['transactions'] ?? [];

      if (list is! List) return [];

      return list
          .whereType<Map<String, dynamic>>()
          .map((t) => WalletTransaction.fromMap(Map<String, dynamic>.from(t)))
          .toList();
    });
  }

  Future<void> creditWallet({
    required String title,
    required String amount,
  }) async {
    if (uid == null) throw Exception("User not logged in");

    final doc = await walletRef.doc(uid).get();
    final balance = (doc.data()?["balance"] ?? 0).toDouble();

    final newTransaction = WalletTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: "credit",
      title: title,
      amount: amount,
      date: DateTime.now(),
    );

    await walletRef.doc(uid).update({
      "balance": balance + double.parse(amount),
      "transactions": FieldValue.arrayUnion([newTransaction.toMap()]),
    });
  }

  Future<void> debitWallet({
    required String title,
    required String amount,
  }) async {
    if (uid == null) throw Exception("User not logged in");

    final doc = await walletRef.doc(uid).get();
    final balance = (doc.data()?["balance"] ?? 0).toDouble();

    if (balance < double.parse(amount)) {
      throw Exception("Insufficient balance");
    }

    final newTransaction = WalletTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: "debit",
      title: title,
      amount: amount,
      date: DateTime.now(),
    );

    await walletRef.doc(uid).update({
      "balance": balance - double.parse(amount),
      "transactions": FieldValue.arrayUnion([newTransaction.toMap()]),
    });
  }
}
