// lib/features/airtime/airtime_screen.dart
import 'package:flutter/material.dart';
import 'package:utilityhub/core/widgets/app_responsive_layout.dart';

import 'controller/airtime_controller.dart';
import 'widgets/airtime_form.dart';
import 'widgets/airtime_payment_selector.dart';

class AirtimeScreen extends StatefulWidget {
  const AirtimeScreen({super.key});

  @override
  State<AirtimeScreen> createState() => _AirtimeScreenState();
}

class _AirtimeScreenState extends State<AirtimeScreen> {
  late AirtimeController controller;

  @override
  void initState() {
    super.initState();
    controller = AirtimeController(
      phoneCtrl: TextEditingController(),
      amountCtrl: TextEditingController(),
    );
    controller.fetchNetworks().then((_) {
      setState(() {});
    });
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
      body: AppResponsiveLayout(
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
                onAutoDetectNetwork: () {
                  setState(() => controller.autoDetectNetwork());
                },
                onNetworkChanged: (v) {
                  setState(() {
                    if (controller.phoneCtrl.text.trim().length >= 4) {
                      controller.autoDetectNetwork();
                    } else if (v != null) {
                      controller.selectedNetworkCode = v;
                    }
                  });
                },
              ),
              const SizedBox(height: 24),
              AirtimePaymentSelector(
                useWallet: controller.useWallet,
                themeColor: themeColor,
                onChanged: (v) {
                  setState(() => controller.useWallet = v);
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.loading
                      ? null
                      : () async {
                          setState(() => controller.loading = true);
                          if (controller.useWallet) {
                            await controller.payWithWallet(context);
                          } else {
                            await controller.payWithCard(context);
                          }
                          setState(() => controller.loading = false);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: controller.loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Buy Airtime"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
