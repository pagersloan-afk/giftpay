import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:utilityhub/config/api.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';

import 'package:utilityhub/core/widgets/app_responsive_layout.dart';
import 'package:utilityhub/core/widgets/success_dialog.dart';
import 'package:utilityhub/features/wallet/transfer/bank_selection_screen.dart';

import 'wigets/amount_card.dart';
import 'wigets/auth_method_dialog.dart';
import 'wigets/confirm_dialog.dart';
import 'wigets/description_card.dart';
import 'wigets/pin_entry_dialog.dart';
import 'wigets/transfer_to_card.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final amountCtrl = TextEditingController();
  final accountCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();

  String? selectedBankCode;
  String? selectedBankName;
  String? resolvedName;

  bool resolving = false;
  bool loadingBanks = true;
  bool submitting = false;

  List<dynamic> banks = [];
  double? walletBalance;

  @override
  void initState() {
    super.initState();
    _loadBanks();
    _loadWalletBalance();
  }

  Future<void> _loadWalletBalance() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    try {
      final doc = await FirebaseFirestore.instance
          .collection("wallets")
          .doc(userId)
          .get();

      if (doc.exists) {
        setState(() {
          walletBalance = (doc.data()?["balance"] ?? 0).toDouble();
        });
      }
    } catch (_) {}
  }

  Future<void> _loadBanks() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.api("/api/transfer/banks")),
      );

      final data = jsonDecode(response.body);

      if (data["status"] == true) {
        setState(() {
          banks = data["data"];
          loadingBanks = false;
        });
      } else {
        setState(() => loadingBanks = false);
      }
    } catch (_) {
      setState(() => loadingBanks = false);
    }
  }

  Future<void> _resolveAccount() async {
    final acct = accountCtrl.text.trim();
    if (acct.length != 10 || selectedBankCode == null) return;

    setState(() => resolving = true);

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.api("/api/transfer/resolve-account")),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"bankCode": selectedBankCode, "accountNumber": acct}),
      );

      final data = jsonDecode(response.body);

      if (data["status"] == true) {
        setState(() {
          resolvedName = data["data"]["accountName"];
        });
      } else {
        setState(() => resolvedName = null);
      }
    } catch (_) {
      setState(() => resolvedName = null);
    }

    setState(() => resolving = false);
  }

  Future<void> _submitTransfer() async {
    Navigator.pop(context);
    setState(() => submitting = true);

    final userId = FirebaseAuth.instance.currentUser!.uid;

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.api("/api/transfer/transfer-to-bank")),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": userId,
          "amount": amountCtrl.text.trim(),
          "bankCode": selectedBankCode,
          "accountNumber": accountCtrl.text.trim(),
          "accountName": resolvedName,
          "description": descriptionCtrl.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (data["status"] == true) {
        showSuccessDialog(
          context: context,
          title: "Transfer Successful",
          message:
              "₦${NumberFormat("#,##0.00").format(double.parse(amountCtrl.text))} has been sent to $resolvedName (${accountCtrl.text}).",
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Transfer failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => submitting = false);
  }

  void _showConfirmDialog() {
    if (resolvedName == null ||
        selectedBankCode == null ||
        amountCtrl.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Complete all fields")));
      return;
    }

    final amount = double.tryParse(amountCtrl.text.trim()) ?? 0;
    const fee = 10.75;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => ConfirmDialog(
        amount: amount,
        fee: fee,
        onConfirm: _showAuthMethodDialog,
      ),
    );
  }

  void _showAuthMethodDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AuthMethodDialog(
        onPinSelected: _showPinDialog,
        onSecurePassSelected: () {},
        onSaveOptionChanged: (_) {},
      ),
    );
  }

  void _showPinDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => PinEntryDialog(
        onCompleted: _submitTransfer,
        onChangeMethod: _showAuthMethodDialog,
      ),
    );
  }

  Future<void> _openBankSelector() async {
    if (loadingBanks || banks.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Bank list not loaded yet")));
      return;
    }

    final selected = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BankSelectionScreen(banks: banks)),
    );

    if (selected != null) {
      setState(() {
        selectedBankCode = selected["code"];
        selectedBankName = selected["name"];
        resolvedName = null;
      });

      _resolveAccount();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115), // ⭐ Premium dark background

      appBar: const AppHeaderr(title: "Transfer to Bank"),

      body: Stack(
        children: [
          // ⭐ Cyan glow behind content
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [const Color(0x334FC3F7), Colors.transparent],
                  radius: 1.2,
                  center: Alignment.topCenter,
                ),
              ),
            ),
          ),

          AppResponsiveLayout(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  TransferToCard(
                    selectedBankName: selectedBankName,
                    resolvedName: resolvedName,
                    resolving: resolving,
                    onSelectBank: _openBankSelector,
                    onAccountChanged: (_) => _resolveAccount(),
                    accountController: accountCtrl,
                  ),

                  AmountCard(controller: amountCtrl),
                  DescriptionCard(controller: descriptionCtrl),

                  const SizedBox(height: 32),

                  // ⭐ MOST PREMIUM BUTTON (Cyan Glow Button)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: submitting ? null : _showConfirmDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4FC3F7),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 8,
                        shadowColor: const Color(0xFF4FC3F7).withOpacity(0.45),
                      ),
                      child: const Text(
                        "Continue",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // ⭐ GP‑1 LOADING OVERLAY
          if (submitting)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.45),
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFF4FC3F7)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
