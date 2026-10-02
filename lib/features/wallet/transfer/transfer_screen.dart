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
import 'package:utilityhub/features/wallet/transfer/wigets/transfer_notice_card.dart';

import 'wigets/amount_card.dart';
import 'wigets/auth_method_dialog.dart';
import 'wigets/confirm_dialog.dart';
import 'wigets/description_card.dart';
import 'wigets/pin_entry_dialog.dart';
import 'wigets/transfer_to_card.dart';
import 'wigets/transfer_from_card.dart';

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

  @override
  void dispose() {
    amountCtrl.dispose();
    accountCtrl.dispose();
    descriptionCtrl.dispose();

    super.dispose();
  }

  // ============================================================
  // WALLET BALANCE
  // ============================================================

  Future<void> _loadWalletBalance() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    final userId = user.uid;

    try {
      final doc = await FirebaseFirestore.instance
          .collection("wallets")
          .doc(userId)
          .get();

      if (!mounted) {
        return;
      }

      if (doc.exists) {
        final rawBalance = doc.data()?["balance"];

        final parsedBalance = rawBalance is num
            ? rawBalance.toDouble()
            : double.tryParse(rawBalance?.toString() ?? "") ?? 0.0;

        setState(() {
          walletBalance = parsedBalance;
        });
      }
    } catch (_) {
      // Keep existing UI behavior.
    }
  }

  // ============================================================
  // BANK LIST
  // ============================================================

  Future<void> _loadBanks() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.api("/api/transfer/banks")),
      );

      final data = jsonDecode(response.body);

      if (!mounted) {
        return;
      }

      if (data["status"] == true) {
        setState(() {
          banks = data["data"] ?? [];
          loadingBanks = false;
        });
      } else {
        setState(() {
          loadingBanks = false;
        });
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        loadingBanks = false;
      });
    }
  }

  // ============================================================
  // ACCOUNT NAME ENQUIRY
  // ============================================================

  Future<void> _resolveAccount() async {
    final acct = accountCtrl.text.trim();

    if (acct.length != 10 || selectedBankCode == null) {
      return;
    }

    if (mounted) {
      setState(() {
        resolving = true;
      });
    }

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.api("/api/transfer/resolve-account")),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"bankCode": selectedBankCode, "accountNumber": acct}),
      );

      final data = jsonDecode(response.body);

      if (!mounted) {
        return;
      }

      if (data["status"] == true) {
        setState(() {
          resolvedName = data["data"]?["accountName"];
        });
      } else {
        setState(() {
          resolvedName = null;
        });
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        resolvedName = null;
      });
    }

    if (!mounted) {
      return;
    }

    setState(() {
      resolving = false;
    });
  }

  // ============================================================
  // TRANSFER REQUEST
  //
  // The backend is authoritative for PIN verification.
  //
  // Possible PIN responses:
  //
  // PIN_INVALID
  // PIN_LOCKED
  // PIN_NOT_SET
  // AUTH_REQUIRED
  // AUTH_INVALID
  //
  // A successful backend response returns:
  //
  // PinVerificationStatus.success
  // ============================================================

  Future<PinVerificationResult> _submitTransfer(String transactionPin) async {
    if (submitting) {
      return const PinVerificationResult(
        status: PinVerificationStatus.error,
        message: "A transfer is already being processed.",
      );
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const PinVerificationResult(
        status: PinVerificationStatus.authRequired,
        message: "Authentication is required. Please sign in again.",
      );
    }

    if (mounted) {
      setState(() {
        submitting = true;
      });
    }

    try {
      // ========================================================
      // FIREBASE AUTH TOKEN
      // ========================================================

      final idToken = await user.getIdToken(true);

      if (idToken == null || idToken.isEmpty) {
        return const PinVerificationResult(
          status: PinVerificationStatus.authRequired,
          message: "Authentication expired. Please sign in again.",
        );
      }

      // ========================================================
      // TRANSFER REQUEST
      // ========================================================

      final response = await http.post(
        Uri.parse(ApiConfig.api("/api/transfer/transfer-to-bank")),
        headers: {
          "Content-Type": "application/json",

          // Required by the backend auth middleware.
          "Authorization": "Bearer $idToken",
        },
        body: jsonEncode({
          "amount": amountCtrl.text.trim(),

          "bankCode": selectedBankCode,

          "accountNumber": accountCtrl.text.trim(),

          "accountName": resolvedName,

          // The Monnify backend expects this
          // field as `reason`.
          "reason": descriptionCtrl.text.trim().isEmpty
              ? "Wallet Cashout"
              : descriptionCtrl.text.trim(),

          // IMPORTANT:
          // This PIN is sent only over the
          // authenticated HTTPS request.
          //
          // The backend verifies it before
          // creating the debit reservation
          // or calling Monnify.
          "transactionPin": transactionPin,
        }),
      );

      // ========================================================
      // SAFE JSON PARSING
      // ========================================================

      dynamic data;

      try {
        data = jsonDecode(response.body);
      } catch (_) {
        data = null;
      }

      final Map<String, dynamic>? responseData = data is Map
          ? Map<String, dynamic>.from(data)
          : null;

      // ========================================================
      // BACKEND ERROR CODE
      // ========================================================

      final String? code = responseData?["code"]?.toString();

      final String? backendMessage = responseData?["message"]?.toString();

      // ========================================================
      // PIN LOCKED
      //
      // Backend returns:
      //
      // code: PIN_LOCKED
      // lockedUntil: milliseconds
      //
      // The PIN dialog uses this to disable
      // keypad input and display countdown.
      // ========================================================

      if (code == "PIN_LOCKED") {
        final rawLockedUntil = responseData?["lockedUntil"];

        int? lockedUntilMillis;

        if (rawLockedUntil is num) {
          lockedUntilMillis = rawLockedUntil.toInt();
        } else if (rawLockedUntil != null) {
          lockedUntilMillis = int.tryParse(rawLockedUntil.toString());
        }

        DateTime? lockedUntil;

        if (lockedUntilMillis != null && lockedUntilMillis > 0) {
          lockedUntil = DateTime.fromMillisecondsSinceEpoch(lockedUntilMillis);
        }

        return PinVerificationResult(
          status: PinVerificationStatus.locked,
          message:
              backendMessage ??
              "Transaction PIN temporarily locked after too many failed attempts.",
          lockedUntil: lockedUntil,
        );
      }

      // ========================================================
      // INVALID PIN
      // ========================================================

      if (code == "PIN_INVALID") {
        return PinVerificationResult(
          status: PinVerificationStatus.invalid,
          message: backendMessage ?? "Incorrect transaction PIN.",
        );
      }

      // ========================================================
      // PIN NOT SET
      // ========================================================

      if (code == "PIN_NOT_SET") {
        return PinVerificationResult(
          status: PinVerificationStatus.pinNotSet,
          message:
              backendMessage ??
              "Transaction PIN has not been set for this account.",
        );
      }

      // ========================================================
      // AUTH REQUIRED / INVALID
      // ========================================================

      if (code == "AUTH_REQUIRED" || code == "AUTH_INVALID") {
        return PinVerificationResult(
          status: PinVerificationStatus.authRequired,
          message:
              backendMessage ??
              "Authentication is required. Please sign in again.",
        );
      }

      // ========================================================
      // HTTP SUCCESS
      // ========================================================

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final transferStatus = (responseData?["transferStatus"] ?? "")
            .toString()
            .toUpperCase();

        // ======================================================
        // SUCCESS / COMPLETED
        // ======================================================

        if (transferStatus == "SUCCESS" || transferStatus == "COMPLETED") {
          if (mounted) {
            final amount = double.tryParse(amountCtrl.text.trim()) ?? 0;

            showSuccessDialog(
              context: context,
              title: "Transfer Successful",
              message:
                  "₦${NumberFormat("#,##0.00").format(amount)} "
                  "has been sent to "
                  "$resolvedName "
                  "(${accountCtrl.text}).",
            );
          }

          return const PinVerificationResult(
            status: PinVerificationStatus.success,
          );
        }

        // ======================================================
        // PENDING
        // ======================================================

        if (transferStatus == "PENDING" ||
            transferStatus == "AWAITING_PROCESSING" ||
            transferStatus == "IN_PROGRESS" ||
            transferStatus == "PENDING_RECONCILIATION") {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  backendMessage ??
                      "Transfer is being processed. Please check the transfer status before retrying.",
                ),
              ),
            );
          }

          return const PinVerificationResult(
            status: PinVerificationStatus.success,
          );
        }

        // ======================================================
        // MONNIFY PENDING AUTHORIZATION
        // ======================================================

        if (transferStatus == "PENDING_AUTHORIZATION") {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Transfer is awaiting Monnify authorization. OTP should only appear if MFA is enabled on your Monnify account.",
                ),
              ),
            );
          }

          return const PinVerificationResult(
            status: PinVerificationStatus.success,
          );
        }

        // ======================================================
        // OTHER HTTP 2xx FAILURE
        // ======================================================

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(backendMessage ?? "Transfer failed.")),
          );
        }

        return PinVerificationResult(
          status: PinVerificationStatus.error,
          message: backendMessage ?? "Transfer failed.",
        );
      }

      // ========================================================
      // NON-2xx RESPONSE
      //
      // PIN-specific errors were already handled above.
      // Any remaining error is a transfer/backend error.
      // ========================================================

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(backendMessage ?? "Transfer failed.")),
        );
      }

      return PinVerificationResult(
        status: PinVerificationStatus.error,
        message: backendMessage ?? "Transfer failed.",
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Unable to connect to GiftPay. Please try again."),
          ),
        );
      }

      return const PinVerificationResult(
        status: PinVerificationStatus.error,
        message: "Unable to connect to GiftPay. Please try again.",
      );
    } finally {
      if (mounted) {
        setState(() {
          submitting = false;
        });
      }
    }
  }

  // ============================================================
  // CONFIRM TRANSFER
  // ============================================================

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

  // ============================================================
  // AUTHENTICATION METHOD
  // ============================================================

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

  // ============================================================
  // PIN DIALOG
  // ============================================================

  void _showPinDialog() {
    showDialog<PinVerificationResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PinEntryDialog(
        onCompleted: _submitTransfer,
        onChangeMethod: _showAuthMethodDialog,
      ),
    );
  }

  // ============================================================
  // BANK SELECTOR
  // ============================================================

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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),

      appBar: const AppHeaderr(title: "Transfer to Bank"),

      body: Stack(
        children: [
          // ======================================================
          // BACKGROUND
          // ======================================================
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [Color(0x334FC3F7), Colors.transparent],
                  radius: 1.2,
                  center: Alignment.topCenter,
                ),
              ),
            ),
          ),

          // ======================================================
          // MAIN CONTENT
          // ======================================================
          AppResponsiveLayout(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8),

              child: Column(
                children: [
                  // ==================================================
                  // NOTICE
                  // ==================================================
                  const TransferNoticeCard(),

                  const SizedBox(height: 18),

                  // ==================================================
                  // PAYING FROM
                  // ==================================================
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Paying from",
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFE5E7EB),
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // ==================================================
                  // TRANSFER FROM
                  // ==================================================
                  const TransferFromCard(),

                  const SizedBox(height: 6),

                  // ==================================================
                  // TRANSFER TO
                  // ==================================================
                  TransferToCard(
                    selectedBankName: selectedBankName,
                    resolvedName: resolvedName,
                    resolving: resolving,
                    onSelectBank: _openBankSelector,
                    onAccountChanged: (_) => _resolveAccount(),
                    accountController: accountCtrl,
                  ),

                  // ==================================================
                  // AMOUNT
                  // ==================================================
                  AmountCard(controller: amountCtrl),

                  // ==================================================
                  // DESCRIPTION
                  // ==================================================
                  DescriptionCard(controller: descriptionCtrl),

                  const SizedBox(height: 32),

                  // ==================================================
                  // CONTINUE
                  // ==================================================
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

          // ======================================================
          // TRANSFER LOADING OVERLAY
          // ======================================================
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
