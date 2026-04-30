import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:utilityhub/core/theme/giftpay_theme.dart';
import 'package:utilityhub/core/giftpay_api.dart';
import 'package:utilityhub/core/giftpay_toast.dart';
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
    int fee = 0;
    int cashback = 0;
    int totalPayable = 0;

    if (amount != null) {
      fee = 20;
      cashback = 10;
      totalPayable = amount! + fee;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const AppHeaderr(title: "Betting Wallet Funding"),

      body: AppResponsiveLayout(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              BettingHeaderSection(),
              const SizedBox(height: 16),

              BettingProviderSection(
                selected: provider,
                onSelect: (v) {
                  setState(() {
                    provider = v;
                    customerName = null;
                  });
                },
              ),

              const SizedBox(height: 16),

              BettingCustomerSection(
                provider: provider,
                verifying: verifying,
                customerName: customerName,
                onCustomerChanged: (v) => customerId = v,
                onVerify: _verifyCustomer,
              ),

              const SizedBox(height: 16),

              BettingAmountSection(
                amount: amount,
                onChanged: (v) {
                  setState(() => amount = v);
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

  Future<void> _verifyCustomer() async {
    if (provider == null || customerId == null || customerId!.isEmpty) return;

    setState(() => verifying = true);

    try {
      final res = await GiftPayAPI.post("/api/betting/verify", {
        "bettingCompany": provider,
        "customerId": customerId,
      });

      setState(() {
        customerName = res["customerName"];
      });
    } catch (_) {
      GiftPayToast.error(context, "Verification failed");
    }

    setState(() => verifying = false);
  }

  // ⭐ UPDATED: Success Dialog Integration
  Future<void> _pay() async {
    setState(() => submitting = true);

    try {
      final res = await GiftPayAPI.post("/api/betting/wallet/fund", {
        "userId": FirebaseAuth.instance.currentUser!.uid,
        "bettingCompany": provider,
        "customerId": customerId,
        "amount": amount,
      });

      final requestId = res["requestId"];

      // Start background requery
      Future.delayed(const Duration(seconds: 5), () {
        _requery(requestId);
      });

      // ⭐ Show Success Dialog
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
            "Fee": "₦20",
            "Cashback": "₦10",
            "Reference": requestId,
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
    } catch (_) {
      GiftPayToast.error(context, "Funding failed");
    }

    setState(() => submitting = false);
  }

  Future<void> _requery(String requestId) async {
    try {
      final res = await GiftPayAPI.post("/api/betting/requery", {
        "userId": FirebaseAuth.instance.currentUser!.uid,
        "requestId": requestId,
      });

      if (res["status"] == true) {
        GiftPayToast.success(context, "Transaction completed");
      } else if (res["message"].toString().contains("Refunded")) {
        GiftPayToast.error(context, "Transaction failed. Refunded.");
      } else {
        GiftPayToast.error(context, "Still pending");
      }
    } catch (_) {
      GiftPayToast.error(context, "Requery failed");
    }
  }
}
