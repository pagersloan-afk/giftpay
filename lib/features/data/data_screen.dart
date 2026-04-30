import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack_plus/flutter_paystack_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import 'package:utilityhub/core/widgets/app_responsive_layout.dart';
import 'data_processing_screen.dart';
import 'data_success_screen.dart';

// SECTIONS
import 'sections/data_network_section.dart';
import 'sections/data_category_section.dart';
import 'sections/data_plan_grid_section.dart';
import 'sections/data_payment_section.dart';

class DataScreen extends StatefulWidget {
  const DataScreen({super.key});

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  final phoneCtrl = TextEditingController();

  String selectedNetworkCode = "01";
  String? selectedPlanId;

  bool loading = false;
  bool loadingPlans = false;
  bool payWithWallet = true;

  List<dynamic> plans = [];
  List<dynamic> filteredPlans = [];

  String activeCategory = "All";

  final List<String> categories = [
    "All",
    "Daily",
    "Weekly",
    "Monthly",
    "SME",
    "Awoof",
    "Direct",
  ];

  final Map<String, String> networkNames = {
    "01": "MTN",
    "02": "GLO",
    "03": "9mobile",
    "04": "Airtel",
  };

  final Map<String, String> networkLogos = {
    "01": "assets/networks/mtn.png",
    "02": "assets/networks/glo.jpg",
    "03": "assets/networks/9mobile.png",
    "04": "assets/networks/airtel.png",
  };

  final Map<String, Color> networkColors = {
    "01": Color(0xFFFFCC00),
    "02": Color(0xFF00A859),
    "03": Color(0xFF006E3A),
    "04": Color(0xFFE60000),
  };

  String get baseUrl => "http://localhost:4000";

  List<String> _getCategoriesForNetwork() {
    if (selectedNetworkCode == "02") {
      return ["All", "SME", "Awoof", "Direct"];
    }

    if (selectedNetworkCode == "04") {
      return ["All", "Awoof", "Direct"];
    }

    return categories;
  }

  Future<void> fetchPlans() async {
    setState(() {
      loadingPlans = true;
      plans = [];
      filteredPlans = [];
    });

    final networkName = networkNames[selectedNetworkCode] ?? "MTN";
    final url = Uri.parse("$baseUrl/api/data/plans/$networkName");

    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);

      if (data["status"] == true) {
        plans = (data["plans"] as List).map((p) {
          return {
            "id": p["PRODUCT_CODE"].toString(),
            "code": p["PRODUCT_CODE"].toString(),
            "name": p["PRODUCT_NAME"].toString(),
            "price": p["PRODUCT_AMOUNT"].toString(),
          };
        }).toList();

        _applyCategoryFilter();
      }
    } catch (e) {
      debugPrint("Error fetching plans: $e");
    }

    setState(() => loadingPlans = false);
  }

  void _applyCategoryFilter() {
    if (activeCategory == "All") {
      filteredPlans = List.from(plans);
    } else {
      filteredPlans = plans.where((p) {
        final name = p["name"].toLowerCase();
        return name.contains(activeCategory.toLowerCase());
      }).toList();
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    fetchPlans();
  }

  Future<void> _payWithWallet() async {
    if (phoneCtrl.text.isEmpty || selectedPlanId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select a plan and enter phone number")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final url = Uri.parse("$baseUrl/api/data/wallet/pay-data");

      final selectedPlan = filteredPlans.firstWhere(
        (p) => p["id"] == selectedPlanId,
      );

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": userId,
          "phone": phoneCtrl.text.trim(),
          "network": networkNames[selectedNetworkCode],
          "planId": selectedPlan["code"],
        }),
      );

      final data = jsonDecode(response.body);

      if (data["status"] == true) {
        if (data["pending"] == true) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DataProcessingScreen(
                requestId: data["requestId"],
                phone: phoneCtrl.text.trim(),
                planName: selectedPlan["name"],
                amount: selectedPlan["price"],
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DataSuccessScreen(
                phone: phoneCtrl.text.trim(),
                planName: selectedPlan["name"],
                amount: selectedPlan["price"],
                message: "Data purchase successful",
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Wallet payment failed")),
        );
      }
    } catch (e) {
      debugPrint("Wallet pay error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error processing wallet payment")),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> _payWithCard() async {
    if (phoneCtrl.text.isEmpty || selectedPlanId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select a plan and enter phone number")),
      );
      return;
    }

    final selectedPlan = filteredPlans.firstWhere(
      (p) => p["id"] == selectedPlanId,
    );

    final amount = double.tryParse(selectedPlan["price"]) ?? 0;
    final amountKobo = (amount * 100).toInt();

    if (kIsWeb) {
      html.window.localStorage["dataPhone"] = phoneCtrl.text.trim();
      html.window.localStorage["dataNetwork"] =
          networkNames[selectedNetworkCode]!;
      html.window.localStorage["dataPlanId"] = selectedPlan["code"];
      html.window.localStorage["dataAmount"] = amount.toString();

      final initUrl = Uri.parse("$baseUrl/paystack/init");

      final initRes = await http.post(
        initUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "amount": amountKobo,
          "email": "user@example.com",
          "reference": "data_${DateTime.now().millisecondsSinceEpoch}",
        }),
      );

      final initData = jsonDecode(initRes.body);

      if (initData["status"] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(initData["message"] ?? "Payment init failed")),
        );
        return;
      }

      html.window.open(initData["authorization_url"], "_blank");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment page opened in new tab")),
      );

      return;
    }

    bool paymentSuccess = false;

    await FlutterPaystackPlus.openPaystackPopup(
      context: context,
      publicKey: "pk_test_xxx",
      secretKey: "",
      customerEmail: "user@example.com",
      amount: amountKobo.toString(),
      reference: "data_${DateTime.now().millisecondsSinceEpoch}",
      currency: "NGN",
      onClosed: () {
        if (!paymentSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Payment failed or cancelled")),
          );
        }
      },
      onSuccess: () async {
        paymentSuccess = true;
        await _payWithWallet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = networkColors[selectedNetworkCode]!;
    final isWeb = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Buy Data"),
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
      ),
      body: AppResponsiveLayout(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // NETWORK DROPDOWN
              DataNetworkSection(
                selectedNetworkCode: selectedNetworkCode,
                networkNames: networkNames,
                onChanged: (v) {
                  setState(() {
                    selectedNetworkCode = v!;
                    selectedPlanId = null;
                    activeCategory = "All";
                  });
                  fetchPlans();
                },
              ),

              const SizedBox(height: 20),

              // NETWORK LOGO
              Center(
                child: Image.asset(
                  networkLogos[selectedNetworkCode]!,
                  height: 48,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 20),

              if (loadingPlans || plans.isEmpty) ...[
                const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 20),
              ] else ...[
                // CATEGORY PILLS
                DataCategorySection(
                  activeCategory: activeCategory,
                  categories: _getCategoriesForNetwork(),
                  themeColor: themeColor,
                  onSelect: (cat) {
                    setState(() {
                      activeCategory = cat;
                      selectedPlanId = null;
                      _applyCategoryFilter();
                    });
                  },
                ),

                const SizedBox(height: 20),

                // PLAN GRID
                DataPlanGridSection(
                  plans: filteredPlans,
                  selectedPlanId: selectedPlanId,
                  themeColor: themeColor,
                  isWeb: isWeb,
                  onSelect: (id) {
                    setState(() => selectedPlanId = id);
                  },
                ),
              ],

              const SizedBox(height: 20),

              // PAYMENT SECTION
              DataPaymentSection(
                phoneCtrl: phoneCtrl,
                payWithWallet: payWithWallet,
                themeColor: themeColor,
                loading: loading,
                onPaymentMethodChanged: (v) =>
                    setState(() => payWithWallet = v),
                onPay: () {
                  if (payWithWallet) {
                    _payWithWallet();
                  } else {
                    _payWithCard();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
