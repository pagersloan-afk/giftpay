import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:utilityhub/config/api.dart';

import 'package:utilityhub/core/theme/giftpay_theme.dart';
import 'package:utilityhub/core/giftpay_api.dart';
import 'package:utilityhub/core/giftpay_toast.dart';
import 'package:utilityhub/core/widgets/app_responsive_layout.dart';
import 'package:utilityhub/core/widgets/giftpay_success_dialog.dart';

import 'sections/cable_header_section.dart';
import 'sections/cable_provider_section.dart';
import 'sections/cable_smartcard_section.dart';
import 'sections/cable_package_section.dart';
import 'sections/cable_summary_section.dart';

class CableScreen extends StatefulWidget {
  const CableScreen({super.key});

  @override
  State<CableScreen> createState() => _CableScreenState();
}

class _CableScreenState extends State<CableScreen> {
  String? provider;
  String? smartcard;
  String? phone;
  String? customerName;
  String? packageCode;
  int? packageAmount;

  bool verifying = false;
  bool loadingPackages = false;
  bool submitting = false;

  List<Map<String, dynamic>> packages = [];

  @override
  Widget build(BuildContext context) {
    int fee = 0;
    int cashback = 0;
    int totalPayable = 0;

    if (packageAmount != null) {
      fee = 20; // cable fee
      cashback = 10; // cable cashback
      totalPayable = packageAmount! + fee;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const AppHeaderr(title: "Cable TV Subscription"),

      body: AppResponsiveLayout(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CableHeaderSection(),
              const SizedBox(height: 16),

              CableProviderSection(
                selected: provider,
                onSelect: (v) {
                  setState(() {
                    provider = v;
                    packageCode = null;
                    customerName = null;
                    packages = [];
                  });
                  _fetchPackages();
                },
              ),

              const SizedBox(height: 16),

              CableSmartcardSection(
                provider: provider,
                verifying: verifying,
                customerName: customerName,
                onSmartcardChanged: (v) => smartcard = v,
                onPhoneChanged: (v) => phone = v,
                onVerify: _verifySmartcard,
              ),

              const SizedBox(height: 16),

              CablePackageSection(
                provider: provider,
                loading: loadingPackages,
                packages: packages,
                selectedCode: packageCode,
                onSelect: (code, amount) {
                  setState(() {
                    packageCode = code;
                    packageAmount = amount;
                  });
                },
              ),

              const SizedBox(height: 16),

              CableSummarySection(
                provider: provider,
                smartcard: smartcard,
                customerName: customerName,
                packageCode: packageCode,
                packageAmount: packageAmount,
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
        smartcard != null &&
        smartcard!.isNotEmpty &&
        phone != null &&
        phone!.isNotEmpty &&
        customerName != null &&
        packageCode != null &&
        packageAmount != null;

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
            : const Text("Pay from Wallet"),
      ),
    );
  }

  Future<void> _verifySmartcard() async {
    if (provider == null || smartcard == null || smartcard!.isEmpty) return;

    setState(() => verifying = true);

    try {
      final res = await GiftPayAPI.post("/api/cable/verify", {
        "cable": provider,
        "smartcard": smartcard,
      });

      setState(() {
        customerName = res["customerName"];
      });
    } catch (_) {
      GiftPayToast.error(context, "Verification failed");
    }

    setState(() => verifying = false);
  }

  Future<void> _fetchPackages() async {
    if (provider == null) return;

    setState(() => loadingPackages = true);

    try {
      final uri = Uri.parse(ApiConfig.api("/api/cable/packages"));
      final response = await http.get(uri);

      final data = jsonDecode(response.body);

      if (data["status"] == true && data["data"] != null) {
        final all = Map<String, dynamic>.from(data["data"]);

        setState(() {
          packages = List<Map<String, dynamic>>.from(all[provider] ?? []);
        });
      } else {
        GiftPayToast.error(context, "Failed to load packages");
      }
    } catch (_) {
      GiftPayToast.error(context, "Failed to load packages");
    }

    setState(() => loadingPackages = false);
  }

  Future<void> _pay() async {
    setState(() => submitting = true);

    try {
      final res = await GiftPayAPI.post("/api/cable/wallet/pay", {
        "userId": FirebaseAuth.instance.currentUser!.uid,
        "cable": provider,
        "packageCode": packageCode,
        "smartcard": smartcard,
        "phone": phone,
        "amount": packageAmount,
      });

      final requestId = res["requestId"];

      // Start background requery
      Future.delayed(const Duration(seconds: 5), () {
        _requery(requestId);
      });

      // ⭐ SUCCESS DIALOG
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => GiftPaySuccessDialog(
          title: "Success",
          message:
              "You have successfully subscribed ${provider!.toUpperCase()} for $customerName",
          details: {
            "Provider": provider!,
            "Smartcard": smartcard!,
            "Customer": customerName!,
            "Package": packageCode!,
            "Amount": "₦$packageAmount",
            "Fee": "₦20",
            "Cashback": "₦10",
            "Total Debited": "₦${packageAmount! + 20}",
            "Reference": requestId,
          },

          // ⭐ Optional upsell link
          linkLabel: "Click here to renew again",
          onLinkTap: () {
            Navigator.pop(context);
            // You can route to cable history or provider page
            Navigator.pushNamed(context, "/cable/history");
          },

          // ⭐ Optional MFA warning
          warning: packageAmount! > 200000
              ? "Multifactor Authentication is required for transactions above ₦200,000."
              : null,

          onOk: () => Navigator.pop(context),
        ),
      );
    } catch (_) {
      GiftPayToast.error(context, "Payment failed");
    }

    setState(() => submitting = false);
  }

  Future<void> _requery(String requestId) async {
    try {
      final res = await GiftPayAPI.post("/api/cable/requery", {
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
