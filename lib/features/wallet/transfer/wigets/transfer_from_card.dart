import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'card_container.dart';

class TransferFromCard extends StatefulWidget {
  const TransferFromCard({super.key});

  @override
  State<TransferFromCard> createState() => _TransferFromCardState();
}

class _TransferFromCardState extends State<TransferFromCard> {
  String fullName = "";
  String accountNumber = "";
  double balance = 0.0;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserWalletData();
  }

  Future<void> _loadUserWalletData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .get();

      final walletDoc = await FirebaseFirestore.instance
          .collection("wallets")
          .doc(uid)
          .get();

      setState(() {
        final first = userDoc.data()?["firstName"] ?? "";
        final last = userDoc.data()?["lastName"] ?? "";
        fullName = "$first $last".trim();

        accountNumber =
            userDoc.data()?["phone"] ?? ""; // or your stored account number
        balance = (walletDoc.data()?["balance"] ?? 0).toDouble();

        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(" ");
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  String _formatAmount(num amount) {
    final formatter = NumberFormat("#,##0.00");
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),

        child: loading
            ? const Text("Loading...", style: TextStyle(color: Colors.white70))
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ⭐ Avatar with initials
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.10),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _initials(fullName),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // ⭐ Name + Balance (stacked, shifted left)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Full name + account number
                        Text(
                          "$fullName • $accountNumber",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withOpacity(0.95),
                          ),
                        ),

                        const SizedBox(height: 4),

                        // ⭐ Balance directly under name
                        Text(
                          "₦${_formatAmount(balance)}",
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.80),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
