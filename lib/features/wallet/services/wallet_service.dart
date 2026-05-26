import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/wallet_transaction.dart';

class WalletService {
  final walletRef = FirebaseFirestore.instance.collection("wallets");
  final userRef = FirebaseFirestore.instance.collection("users");

  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  Future<void> createWalletIfNotExists() async {
    if (uid == null) return;

    final doc = await walletRef.doc(uid).get();
    if (!doc.exists) {
      await walletRef.doc(uid).set({"balance": 0, "transactions": []});
    }
  }

  // ⭐ OLD METHOD (your app depends on this)
  Stream<double> balanceStream() => walletBalanceStream();

  // ⭐ REAL-TIME WALLET BALANCE
  Stream<double> walletBalanceStream() {
    if (uid == null) return Stream.value(0.0);

    return walletRef.doc(uid!).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) return 0.0;

      final bal = data["balance"];
      if (bal is int) return bal.toDouble();
      if (bal is double) return bal;
      if (bal is String) return double.tryParse(bal) ?? 0.0;

      return 0.0;
    });
  }

  // ⭐ WALLET TRANSACTIONS (Airtime, Funding, Withdrawals)
  Stream<List<WalletTransaction>> walletTransactionStream() {
    if (uid == null) return Stream.value([]);

    return walletRef.doc(uid!).snapshots().map((doc) {
      final list = doc.data()?["transactions"] ?? [];
      if (list is! List) return [];

      return list
          .whereType<Map<String, dynamic>>()
          .map((t) => WalletTransaction.fromMap(Map<String, dynamic>.from(t)))
          .toList();
    });
  }

  // ⭐ ELECTRICITY TRANSACTIONS (users/{uid}/transactions)
  Stream<List<WalletTransaction>> electricityTransactionStream() {
    if (uid == null) return Stream.value([]);

    return userRef.doc(uid!).collection("transactions").snapshots().map((snap) {
      return snap.docs
          .map((doc) => WalletTransaction.fromMap(doc.data()))
          .toList();
    });
  }

  // ⭐ MERGED TRANSACTIONS WITHOUT RXDART
  Stream<List<WalletTransaction>> mergedTransactionStream() async* {
    if (uid == null) {
      yield [];
      return;
    }

    await for (final walletSnap in walletTransactionStream()) {
      final electricitySnap =
          await electricityTransactionStream().first; // get latest once

      final merged = <Map<String, dynamic>>[
        ...walletSnap.map((e) => e.toMap()),
        ...electricitySnap.map((e) => e.toMap()),
      ];

      merged.sort((a, b) {
        final t1 = (a["timestamp"] ?? a["date"] ?? 0) as int;
        final t2 = (b["timestamp"] ?? b["date"] ?? 0) as int;
        return t2.compareTo(t1);
      });

      yield merged.map((m) => WalletTransaction.fromMap(m)).toList();
    }
  }

  // ⭐ CREDIT WALLET
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

  // ⭐ DEBIT WALLET
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
