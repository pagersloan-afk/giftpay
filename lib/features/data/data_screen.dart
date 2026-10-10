import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack_plus/flutter_paystack_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

// Web-only import (safe)
import 'package:universal_html/html.dart' as html;
import 'package:utilityhub/config/api.dart';

import 'package:utilityhub/core/widgets/app_responsive_layout.dart';
import 'data_processing_screen.dart';
import 'success_dialog.dart';

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

  // This is now a Monnify biller code, not a hard-coded
  // ClubKonnect-style network code.
  String selectedNetworkCode = "";

  String? selectedPlanId;

  bool loading = false;
  bool loadingNetworks = false;
  bool loadingPlans = false;
  bool payWithWallet = true;

  List<dynamic> plans = [];
  List<dynamic> filteredPlans = [];

  // Monnify DATA billers returned by the backend.
  // key   = Monnify biller code
  // value = Monnify biller name
  Map<String, String> networkNames = {};

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

  String get baseUrl => ApiConfig.baseUrl;

  // ============================================================
  // PRESENTATION ONLY
  //
  // These mappings do NOT decide which networks are available.
  // Monnify decides availability. These are only used to retain
  // the existing network-specific visual theme for known names.
  // ============================================================

  Color _themeColorForNetwork(String name) {
    final normalized = name.toLowerCase();

    if (normalized.contains("mtn")) {
      return const Color(0xFFFFCC00);
    }

    if (normalized.contains("glo")) {
      return const Color(0xFF00A859);
    }

    if (normalized.contains("airtel")) {
      return const Color(0xFFE60000);
    }

    if (normalized.contains("9mobile") ||
        normalized.contains("9 mobile") ||
        normalized.contains("etisalat")) {
      return const Color(0xFF006E3A);
    }

    // Generic fallback for a new Monnify biller.
    return Colors.blue;
  }

  String _networkNameForSelectedCode() {
    return networkNames[selectedNetworkCode] ?? "";
  }

  Color get themeColor => _themeColorForNetwork(_networkNameForSelectedCode());

  // ============================================================
  // MONNIFY DATA BILLER DISCOVERY
  // ============================================================
  Future<void> fetchNetworks() async {
    if (!mounted) {
      return;
    }

    setState(() {
      loadingNetworks = true;
      loadingPlans = false;
      selectedNetworkCode = "";
      selectedPlanId = null;
      plans = [];
      filteredPlans = [];
      networkNames = {};
    });

    try {
      final url = Uri.parse("$baseUrl/api/data/networks");
      final response = await http.get(url);

      final data = jsonDecode(response.body);

      if (data["status"] != true) {
        throw Exception(data["message"] ?? "Unable to fetch DATA networks");
      }

      final rawNetworks = data["networks"];

      if (rawNetworks is! List) {
        throw Exception("Invalid DATA network response");
      }

      final parsed = <String, String>{};

      for (final item in rawNetworks) {
        if (item is! Map) {
          continue;
        }

        final code = item["code"]?.toString().trim() ?? "";
        final name = item["name"]?.toString().trim() ?? "";

        if (code.isNotEmpty && name.isNotEmpty) {
          parsed[code] = name;
        }
      }

      if (!mounted) {
        return;
      }

      setState(() {
        networkNames = parsed;

        if (parsed.isNotEmpty) {
          selectedNetworkCode = parsed.keys.first;
        }
      });

      if (parsed.isNotEmpty) {
        await fetchPlans();
      }
    } catch (e) {
      debugPrint("[DATA] Error fetching Monnify networks: $e");

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst("Exception: ", ""))),
      );
    } finally {
      if (!mounted) {
        return;
      }

      setState(() {
        loadingNetworks = false;
      });
    }
  }

  // ============================================================
  // MONNIFY DATA PLANS
  // ============================================================
  Future<void> fetchPlans() async {
    if (selectedNetworkCode.isEmpty) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      loadingPlans = true;
      plans = [];
      filteredPlans = [];
      selectedPlanId = null;
    });

    try {
      final url = Uri.parse(
        "$baseUrl/api/data/plans/${Uri.encodeComponent(selectedNetworkCode)}",
      );

      final response = await http.get(url);
      final data = jsonDecode(response.body);

      if (data["status"] != true) {
        throw Exception(data["message"] ?? "Unable to fetch data plans");
      }

      final rawPlans = data["plans"];

      if (rawPlans is! List) {
        throw Exception("Invalid data plan response");
      }

      final parsedPlans = rawPlans
          .whereType<Map>()
          .map<Map<String, dynamic>>((p) {
            return {
              "id": p["id"]?.toString() ?? p["code"]?.toString() ?? "",
              "code": p["code"]?.toString() ?? p["id"]?.toString() ?? "",
              "name":
                  p["name"]?.toString() ?? p["PRODUCT_NAME"]?.toString() ?? "",
              "price":
                  p["price"]?.toString() ??
                  p["PRODUCT_AMOUNT"]?.toString() ??
                  "",
              "priceType": p["priceType"],
              "metadata": p["metadata"] ?? {},
            };
          })
          .where((p) => p["id"].toString().isNotEmpty)
          .toList();

      if (!mounted) {
        return;
      }

      setState(() {
        plans = parsedPlans;
      });

      _applyCategoryFilter();
    } catch (e) {
      debugPrint("[DATA] Error fetching Monnify plans: $e");

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst("Exception: ", ""))),
      );
    } finally {
      if (!mounted) {
        return;
      }

      setState(() {
        loadingPlans = false;
      });
    }
  }

  void _applyCategoryFilter() {
    if (!mounted) {
      return;
    }

    if (activeCategory == "All") {
      setState(() {
        filteredPlans = List.from(plans);
      });
      return;
    }

    final category = activeCategory.toLowerCase();

    final result = plans.where((p) {
      final name = p["name"]?.toString().toLowerCase() ?? "";

      final metadata = p["metadata"];
      final metadataMap = metadata is Map
          ? Map<String, dynamic>.from(metadata)
          : {};

      final productCategory =
          metadataMap["productCategory"]?.toString().toLowerCase() ?? "";

      final durationUnit =
          metadataMap["durationUnit"]?.toString().toLowerCase() ?? "";

      return name.contains(category) ||
          productCategory.contains(category) ||
          durationUnit.contains(category);
    }).toList();

    setState(() {
      filteredPlans = result;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchNetworks();
  }

  // ============================================================
  // WALLET PAYMENT
  // ============================================================
  Future<void> _payWithWallet() async {
    if (phoneCtrl.text.trim().isEmpty || selectedPlanId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select a plan and enter phone number")),
      );
      return;
    }

    if (selectedNetworkCode.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Select a network first")));
      return;
    }

    setState(() => loading = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception("Please sign in again");
      }

      final userId = currentUser.uid;
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

          // IMPORTANT:
          // This is the actual Monnify biller code.
          "network": selectedNetworkCode,

          // This is the actual Monnify product code.
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
          showDataSuccessDialog(
            context: context,
            phone: phoneCtrl.text.trim(),
            planName: selectedPlan["name"],
            amount: selectedPlan["price"],
            message: data["message"]?.toString() ?? "Data purchase successful",
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Wallet payment failed")),
        );
      }
    } catch (e) {
      debugPrint("[DATA] Wallet pay error: $e");

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst("Exception: ", ""))),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  // ============================================================
  // CARD PAYMENT
  //
  // Existing card flow retained. The network saved to local
  // storage is now the Monnify biller code.
  // ============================================================
  Future<void> _payWithCard() async {
    if (phoneCtrl.text.trim().isEmpty || selectedPlanId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select a plan and enter phone number")),
      );
      return;
    }

    final selectedPlan = filteredPlans.firstWhere(
      (p) => p["id"] == selectedPlanId,
    );

    final amount =
        double.tryParse(selectedPlan["price"]?.toString() ?? "") ?? 0;

    final amountKobo = (amount * 100).toInt();

    if (amountKobo <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("This plan does not have a valid fixed price."),
        ),
      );
      return;
    }

    // WEB-ONLY PAYSTACK FLOW
    if (kIsWeb) {
      html.window.localStorage["dataPhone"] = phoneCtrl.text.trim();
      html.window.localStorage["dataNetwork"] = selectedNetworkCode;
      html.window.localStorage["dataPlanId"] =
          selectedPlan["code"]?.toString() ?? "";
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

    // MOBILE PAYSTACK FLOW
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
  void dispose() {
    phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentThemeColor = _themeColorForNetwork(
      _networkNameForSelectedCode(),
    );

    final isWeb = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Buy Data"),
        backgroundColor: currentThemeColor,
        foregroundColor: Colors.white,
      ),
      body: AppResponsiveLayout(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DataNetworkSection(
                selectedNetworkCode: selectedNetworkCode,
                networkNames: networkNames,
                onChanged: (value) async {
                  if (value == null || value.isEmpty) {
                    return;
                  }

                  setState(() {
                    selectedNetworkCode = value;
                    selectedPlanId = null;
                    activeCategory = "All";
                    plans = [];
                    filteredPlans = [];
                  });

                  await fetchPlans();
                },
              ),

              const SizedBox(height: 20),

              if (loadingNetworks || loadingPlans) ...[
                const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 20),
              ] else if (networkNames.isEmpty) ...[
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      "No DATA billers are currently available from Monnify.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ] else if (plans.isEmpty) ...[
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      "No data plans are currently available for this biller.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ] else ...[
                DataCategorySection(
                  activeCategory: activeCategory,
                  categories: categories,
                  themeColor: currentThemeColor,
                  onSelect: (cat) {
                    setState(() {
                      activeCategory = cat;
                      selectedPlanId = null;
                    });

                    _applyCategoryFilter();
                  },
                ),

                const SizedBox(height: 20),

                if (filteredPlans.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        "No plans match this category.",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  DataPlanGridSection(
                    plans: filteredPlans,
                    selectedPlanId: selectedPlanId,
                    themeColor: currentThemeColor,
                    isWeb: isWeb,
                    onSelect: (id) {
                      setState(() => selectedPlanId = id);
                    },
                  ),
              ],

              const SizedBox(height: 20),

              DataPaymentSection(
                phoneCtrl: phoneCtrl,
                payWithWallet: payWithWallet,
                themeColor: currentThemeColor,
                loading: loading,
                onPaymentMethodChanged: (value) {
                  setState(() => payWithWallet = value);
                },
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
