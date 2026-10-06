// lib/features/airtime/airtime_screen.dart

import 'package:flutter/material.dart';
import 'package:utilityhub/core/widgets/app_responsive_layout.dart';

import '../wallet/transfer/wigets/pin_entry_dialog.dart';

import 'controller/airtime_controller.dart';
import 'widgets/airtime_form.dart';

class AirtimeScreen extends StatefulWidget {
  const AirtimeScreen({super.key});

  @override
  State<AirtimeScreen> createState() => _AirtimeScreenState();
}

class _AirtimeScreenState extends State<AirtimeScreen> {
  late AirtimeController controller;

  bool _processing = false;

  @override
  void initState() {
    super.initState();

    controller = AirtimeController(
      phoneCtrl: TextEditingController(),
      amountCtrl: TextEditingController(),
    );

    _initialize();
  }

  Future<void> _initialize() async {
    await controller.initialize();

    if (!mounted) {
      return;
    }

    setState(() {});
  }

  void _selectRecentNumber(RecentAirtimeNumber recent) {
    controller.phoneCtrl.text = recent.phone;

    controller.phoneCtrl.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.phoneCtrl.text.length),
    );

    controller.autoDetectNetwork();

    if (!mounted) {
      return;
    }

    setState(() {});
  }

  void _removeRecentNumber(String phone) {
    controller.removeRecentNumber(phone);

    if (!mounted) {
      return;
    }

    setState(() {});
  }

  // ============================================================
  // BUY AIRTIME
  // ============================================================

  Future<void> _handlePurchase() async {
    if (controller.loading || _processing) {
      return;
    }

    if (!controller.validateForPurchase(context)) {
      return;
    }

    String enteredPin = "";

    // ----------------------------------------------------------
    // STEP 1:
    // Show the existing 4-digit PIN authentication dialog.
    // ----------------------------------------------------------

    final pinResult = await showDialog<PinVerificationResult>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PinEntryDialog(
          onCompleted: (pin) async {
            // Keep the verified PIN so it can be supplied to
            // the actual wallet purchase request.
            enteredPin = pin;

            return controller.verifyTransactionPin(dialogContext, pin);
          },

          // Airtime currently supports PIN authentication only.
          // The existing PinEntryDialog requires this callback.
          onChangeMethod: () {},
        );
      },
    );

    if (!mounted) {
      return;
    }

    // User closed the dialog without successful authentication.
    if (pinResult == null || !pinResult.isSuccess) {
      return;
    }

    if (!RegExp(r"^\d{4}$").hasMatch(enteredPin)) {
      return;
    }

    // ----------------------------------------------------------
    // STEP 2:
    // Immediately show visible processing state.
    // ----------------------------------------------------------

    setState(() {
      _processing = true;
    });

    try {
      // --------------------------------------------------------
      // STEP 3:
      // Perform the actual wallet → Monnify Airtime purchase.
      // --------------------------------------------------------

      await controller.payWithWallet(context, transactionPin: enteredPin);
    } finally {
      if (!mounted) {
        return;
      }

      setState(() {
        _processing = false;
      });
    }
  }

  @override
  void dispose() {
    controller.phoneCtrl.dispose();
    controller.amountCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = controller.themeColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Buy Airtime"),
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          AppResponsiveLayout(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  AirtimeForm(
                    phoneCtrl: controller.phoneCtrl,
                    amountCtrl: controller.amountCtrl,
                    networkMap: controller.networkMap,
                    selectedNetworkCode: controller.selectedNetworkCode,
                    themeColor: themeColor,
                    recentNumbers: controller.recentNumbers,

                    onRecentNumberSelected: _selectRecentNumber,

                    onRecentNumberRemoved: _removeRecentNumber,

                    onAutoDetectNetwork: () {
                      if (!mounted) {
                        return;
                      }

                      setState(() {
                        controller.autoDetectNetwork();
                      });
                    },

                    onNetworkChanged: (value) {
                      if (!mounted || value == null) {
                        return;
                      }

                      setState(() {
                        controller.selectedNetworkCode = value;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  // Wallet is the only payment source.
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: themeColor.withValues(alpha: 0.20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          color: themeColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Payment will be made from your GiftPay wallet.",
                            style: TextStyle(
                              color: themeColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.loading || _processing
                          ? null
                          : _handlePurchase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: controller.loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text("Buy Airtime"),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ====================================================
          // VISIBLE PROCESSING OVERLAY
          // ====================================================
          if (_processing)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.72),
                child: Center(
                  child: Container(
                    width: 300,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 28,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF171717),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.14)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.40),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(
                            strokeWidth: 4,
                            color: themeColor,
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "Processing Airtime Purchase",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "Your GiftPay wallet is being debited and your airtime purchase is being processed.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.65),
                            fontSize: 13,
                            height: 1.45,
                          ),
                        ),

                        const SizedBox(height: 18),

                        Text(
                          "Please do not close this screen.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: themeColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
