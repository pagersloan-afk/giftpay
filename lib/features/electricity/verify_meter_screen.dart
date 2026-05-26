// lib/features/electricity/verify_meter_screen.dart

import 'package:flutter/material.dart';
import 'package:utilityhub/core/widgets/app_responsive_layout.dart';
import 'package:utilityhub/core/widgets/giftpay_card.dart';
import 'package:utilityhub/core/widgets/giftpay_textfield.dart';
import 'package:utilityhub/core/widgets/giftpay_dropdown.dart';
import 'package:utilityhub/features/electricity/models/saved_meter.dart';
import 'package:utilityhub/features/electricity/purchase_screen.dart';
import 'package:utilityhub/features/electricity/services/clubkonnect_service.dart';

// ⭐ NEW IMPORTS
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:utilityhub/features/electricity/services/saved_meter_service.dart';
import 'package:utilityhub/features/electricity/widgets/saved_meters_list.dart';

class VerifyMeterScreen extends StatefulWidget {
  final String discoCode;
  final String userId; // ⭐ REQUIRED FOR SAVED METERS

  const VerifyMeterScreen({
    super.key,
    required this.discoCode,
    required this.userId,
  });

  @override
  State<VerifyMeterScreen> createState() => _VerifyMeterScreenState();
}

class _VerifyMeterScreenState extends State<VerifyMeterScreen> {
  final meterCtrl = TextEditingController();
  bool loading = false;

  String meterType = "01"; // Prepaid default

  final electricity = ElectricityService();

  // ⭐ NEW: Saved meters
  late SavedMeterService savedMeterService;
  List<SavedMeter> savedMeters = [];

  @override
  void initState() {
    super.initState();

    // ⭐ Initialize saved meter service
    savedMeterService = SavedMeterService(widget.userId);

    // ⭐ Listen for saved meters
    savedMeterService.getSavedMeters().listen((list) {
      setState(() => savedMeters = list);
    });
  }

  Future<void> verifyMeter() async {
    if (meterCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid meter number")),
      );
      return;
    }

    setState(() => loading = true);

    final response = await electricity.verifyMeter(
      meterNumber: meterCtrl.text.trim(),
      discoCode: widget.discoCode,
      meterType: meterType,
    );

    setState(() => loading = false);

    if (response["status"] == true) {
      final customerName = response["customerName"] ?? "Customer";

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PurchaseElectricityScreen(
            meterNumber: meterCtrl.text.trim(),
            customerName: customerName,
            discoCode: widget.discoCode,
            meterType: meterType,
          ),
        ),
      );
    } else {
      final raw = response["raw"];
      final rawMsg = raw != null ? raw.toString() : "No raw data";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Verification failed\n$rawMsg", maxLines: 6)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Verify Meter")),
      body: AppResponsiveLayout(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // ⭐ SHOW SAVED METERS FIRST
              if (savedMeters.isNotEmpty)
                SavedMetersList(
                  meters: savedMeters,
                  onSelect: (meter) {
                    meterCtrl.text = meter.meterNumber;
                    meterType = meter.meterType;

                    // discoCode is fixed for this screen, so no change needed
                    setState(() {});
                  },
                ),

              const SizedBox(height: 20),

              GiftPayCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.flash_on,
                      size: 50,
                      color: theme.colorScheme.primary,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      widget.discoCode.toUpperCase(),
                      style: theme.textTheme.titleLarge,
                    ),

                    const SizedBox(height: 24),

                    GiftPayTextField(
                      controller: meterCtrl,
                      label: "Meter Number",
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 24),

                    GiftPayDropdown(
                      label: "Meter Type",
                      value: meterType,
                      items: const [
                        DropdownMenuItem(value: "01", child: Text("Prepaid")),
                        DropdownMenuItem(value: "02", child: Text("Postpaid")),
                      ],
                      onChanged: (v) => setState(() => meterType = v!),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loading ? null : verifyMeter,
                        child: loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text("Verify Meter"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
