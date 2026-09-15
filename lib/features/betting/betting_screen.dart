import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:utilityhub/core/giftpay_api.dart';
import 'package:utilityhub/core/giftpay_toast.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';
import 'package:utilityhub/core/widgets/app_responsive_layout.dart';
import 'package:utilityhub/core/widgets/giftpay_success_dialog.dart';

import 'sections/betting_header_section.dart';
import 'sections/betting_provider_section.dart';
import 'sections/betting_customer_section.dart';
import 'sections/betting_amount_section.dart';
import 'sections/betting_summary_section.dart';

class BettingScreen extends StatefulWidget {
  const BettingScreen({super.key});

  @override
  State<BettingScreen> createState() => _BettingScreenState();
}

class _BettingScreenState extends State<BettingScreen> {
  String? provider;
  String? customerId;
  String? customerName;
  int? amount;

  bool verifying = false;
  bool submitting = false;

  @override
  Widget build(BuildContext context) {
    // Betting is currently FREE to the customer.
    const int fee = 0;
    const int cashback = 0;

    final int totalPayable = amount ?? 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const AppHeaderr(title: "Betting Wallet Funding"),
      body: AppResponsiveLayout(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const BettingHeaderSection(),
              const SizedBox(height: 16),

              BettingProviderSection(
                selected: provider,
                onSelect: (v) {
                  setState(() {
                    provider = v;
                    customerName = null;
                    customerId = null;
                  });
                },
              ),

              const SizedBox(height: 16),

              BettingCustomerSection(
                provider: provider,
                verifying: verifying,
                customerName: customerName,
                onCustomerChanged: (v) {
                  setState(() {
                    customerId = v;
                    customerName = null;
                  });
                },
                onVerify: _verifyCustomer,
              ),

              const SizedBox(height: 16),

              BettingAmountSection(
                amount: amount,
                onChanged: (v) {
                  setState(() {
                    amount = v;
                  });
                },
              ),

              const SizedBox(height: 16),

              BettingSummarySection(
                provider: provider,
                customerId: customerId,
                customerName: customerName,
                amount: amount,
                fee: fee,
                cashback: cashback,
                totalPayable: totalPayable,
              ),

              const SizedBox(height: 24),

              _buildPayButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPayButton() {
    final canPay =
        provider != null &&
        customerId != null &&
        customerId!.isNotEmpty &&
        customerName != null &&
        customerName!.isNotEmpty &&
        amount != null &&
        amount! >= 100;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canPay && !submitting ? _pay : null,
        style: Theme.of(context).elevatedButtonTheme.style,
        child: submitting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text("Fund Wallet"),
      ),
    );
  }

  // ============================================================
  // VERIFY CUSTOMER
  // ============================================================

  Future<void> _verifyCustomer() async {
    if (provider == null || customerId == null || customerId!.trim().isEmpty) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      verifying = true;
      customerName = null;
    });

    try {
      final res = await GiftPayAPI.post("/api/betting/verify", {
        "bettingCompany": provider,
        "customerId": customerId!.trim(),
      });

      if (!mounted) return;

      final bool success = res["status"] == true;
      final String? verifiedName = res["customerName"]?.toString();

      if (success && verifiedName != null && verifiedName.isNotEmpty) {
        setState(() {
          customerName = verifiedName;
        });

        GiftPayToast.success(context, "Customer verified");
      } else {
        setState(() {
          customerName = null;
        });

        GiftPayToast.error(
          context,
          res["message"]?.toString() ?? "Unable to validate Customer ID.",
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        customerName = null;
      });

      GiftPayToast.error(context, "Unable to validate Customer ID.");
    } finally {
      if (mounted) {
        setState(() {
          verifying = false;
        });
      }
    }
  }

  // ============================================================
  // FUND BETTING WALLET
  // ============================================================

  Future<void> _pay() async {
    if (provider == null ||
        customerId == null ||
        customerName == null ||
        amount == null) {
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      GiftPayToast.error(context, "Please sign in again.");
      return;
    }

    setState(() {
      submitting = true;
    });

    try {
      final res = await GiftPayAPI.post("/api/betting/wallet/fund", {
        "userId": currentUser.uid,
        "bettingCompany": provider,
        "customerId": customerId!.trim(),
        "amount": amount,
      });

      if (!mounted) return;

      final bool success = res["status"] == true;
      final bool pending = res["pending"] == true;

      final String requestId = res["requestId"]?.toString() ?? "";

      final int fee = int.tryParse(res["fee"]?.toString() ?? "0") ?? 0;

      final int debited =
          int.tryParse(res["debited"]?.toString() ?? amount.toString()) ??
          amount!;

      final int cashback =
          int.tryParse(res["cashback"]?.toString() ?? "0") ?? 0;

      // ==========================================================
      // ORDER RECEIVED / PENDING
      // ==========================================================

      if (success && pending) {
        GiftPayToast.success(context, "Betting funding request received.");

        // Requery after ClubKonnect has had time to process it.
        if (requestId.isNotEmpty) {
          Future.delayed(const Duration(seconds: 5), () {
            if (mounted) {
              _requery(requestId);
            }
          });
        }

        // Show a pending dialog rather than falsely saying
        // the betting wallet has already been funded.
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => GiftPaySuccessDialog(
            title: "Processing",
            message:
                "Your request to fund ₦$amount to $customerName ($provider) has been received and is being processed.",
            details: {
              "Provider": provider!,
              "Customer ID": customerId!,
              "Amount": "₦$amount",
              "Fee": "₦$fee",
              "Cashback": "₦$cashback",
              "Total Debited": "₦$debited",
              "Reference": requestId,
              "Status": "PROCESSING",
            },
            linkLabel: "Click here to view betting history",
            onLinkTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, "/betting/history");
            },
            warning: amount! > 200000
                ? "Multifactor Authentication is required for transactions above ₦200,000."
                : null,
            onOk: () => Navigator.pop(context),
          ),
        );

        return;
      }

      // ==========================================================
      // IMMEDIATE SUCCESS
      // ==========================================================

      if (success && !pending) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => GiftPaySuccessDialog(
            title: "Success",
            message:
                "You have successfully funded ₦$amount to $customerName ($provider)",
            details: {
              "Provider": provider!,
              "Customer ID": customerId!,
              "Amount": "₦$amount",
              "Fee": "₦$fee",
              "Cashback": "₦$cashback",
              "Total Debited": "₦$debited",
              "Reference": requestId,
              "Status": "SUCCESS",
            },
            linkLabel: "Click here to view betting history",
            onLinkTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, "/betting/history");
            },
            warning: amount! > 200000
                ? "Multifactor Authentication is required for transactions above ₦200,000."
                : null,
            onOk: () => Navigator.pop(context),
          ),
        );

        return;
      }

      // ==========================================================
      // FAILURE
      // ==========================================================

      GiftPayToast.error(
        context,
        res["message"]?.toString() ?? "Betting wallet funding failed.",
      );
    } catch (e) {
      if (!mounted) return;

      GiftPayToast.error(
        context,
        "Funding request failed. Please check your transaction history.",
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
  // REQUERY
  // ============================================================

  Future<void> _requery(String requestId) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) return;

      final res = await GiftPayAPI.post("/api/betting/requery", {
        "userId": currentUser.uid,
        "requestId": requestId,
      });

      if (!mounted) return;

      if (res["status"] == true && res["pending"] != true) {
        GiftPayToast.success(context, "Betting transaction completed.");
      } else if (res["pending"] == true) {
        GiftPayToast.error(context, "Betting transaction is still processing.");
      } else {
        GiftPayToast.error(
          context,
          res["message"]?.toString() ?? "Betting transaction failed.",
        );
      }
    } catch (_) {
      if (!mounted) return;

      GiftPayToast.error(
        context,
        "Unable to check betting transaction status.",
      );
    }
  }
}
