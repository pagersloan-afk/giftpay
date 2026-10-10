import 'package:flutter/material.dart';
import 'package:utilityhub/core/widgets/app_responsive_layout.dart';
import 'package:utilityhub/core/widgets/giftpay_card.dart';
import 'package:utilityhub/core/widgets/giftpay_textfield.dart';
import 'package:utilityhub/core/widgets/giftpay_dropdown.dart';
import 'package:utilityhub/features/electricity/models/saved_meter.dart';
import 'package:utilityhub/features/electricity/purchase_screen.dart';
import 'package:utilityhub/features/electricity/services/electricity_service.dart';
import 'package:utilityhub/features/electricity/services/saved_meter_service.dart';
import 'package:utilityhub/features/electricity/widgets/saved_meters_list.dart';
import 'package:utilityhub/features/electricity/saved_meters_screen.dart';

class VerifyMeterScreen extends StatefulWidget {
  final String discoCode;
  final String userId;

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
  final electricity = ElectricityService();
  late SavedMeterService savedMeterService;

  bool loading = true;
  bool verifying = false;
  String? selectedProductCode;
  String meterType = "";
  List<Map<String, dynamic>> products = [];
  List<SavedMeter> savedMeters = [];

  @override
  void initState() {
    super.initState();
    savedMeterService = SavedMeterService(widget.userId);
    savedMeterService.getSavedMeters().listen((list) {
      if (mounted) setState(() => savedMeters = list);
    });
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => loading = true);
    try {
      final result = await electricity.fetchProducts(billerCode: widget.discoCode);
      if (!mounted) return;
      setState(() {
        products = result;
        selectedProductCode = result.length == 1 ? result.first["code"]?.toString() : null;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst("Exception: ", ""))),
      );
    }
  }

  Future<void> _verifyMeter() async {
    if (meterCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid meter number")),
      );
      return;
    }
    if (selectedProductCode == null || selectedProductCode!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select an electricity product")),
      );
      return;
    }

    setState(() => verifying = true);
    try {
      final response = await electricity.verifyMeter(
        meterNumber: meterCtrl.text.trim(),
        billerCode: widget.discoCode,
        productCode: selectedProductCode!,
        meterType: meterType,
      );

      if (!mounted) return;
      if (response["status"] == true) {
        final customerName = (response["customerName"] ?? "Customer").toString();

        await savedMeterService.saveMeter(
          SavedMeter(
            meterNumber: meterCtrl.text.trim(),
            meterType: meterType,
            discoCode: widget.discoCode,
            customerName: customerName,
            lastUsed: DateTime.now().millisecondsSinceEpoch,
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PurchaseElectricityScreen(
              meterNumber: meterCtrl.text.trim(),
              customerName: customerName,
              discoCode: widget.discoCode,
              meterType: meterType,
              productCode: selectedProductCode!,
              validationReference: (response["validationReference"] ?? "").toString(),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response["message"] ?? "Meter verification failed")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst("Exception: ", ""))),
        );
      }
    } finally {
      if (mounted) setState(() => verifying = false);
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
              if (savedMeters.isNotEmpty)
                SavedMetersList(
                  meters: savedMeters,
                  onSelect: (meter) {
                    meterCtrl.text = meter.meterNumber;
                    setState(() => meterType = meter.meterType);
                  },
                  userId: widget.userId,
                  onViewAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SavedMetersScreen(userId: widget.userId)),
                    );
                  },
                ),
              const SizedBox(height: 20),
              GiftPayCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.flash_on, size: 50, color: theme.colorScheme.primary),
                    const SizedBox(height: 12),
                    Text(widget.discoCode.toUpperCase(), style: theme.textTheme.titleLarge),
                    const SizedBox(height: 24),
                    GiftPayTextField(
                      controller: meterCtrl,
                      label: "Meter Number",
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    if (loading)
                      const CircularProgressIndicator()
                    else if (products.isEmpty)
                      const Text("Monnify returned no electricity products for this provider.")
                    else
                      DropdownButtonFormField<String>(
                        value: selectedProductCode,
                        decoration: const InputDecoration(labelText: "Electricity Product"),
                        items: products.map((product) {
                          return DropdownMenuItem<String>(
                            value: product["code"].toString(),
                            child: Text(product["name"].toString()),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => selectedProductCode = value),
                      ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loading || verifying || products.isEmpty ? null : _verifyMeter,
                        child: verifying
                            ? const CircularProgressIndicator(color: Colors.white)
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

  @override
  void dispose() {
    meterCtrl.dispose();
    super.dispose();
  }
}
