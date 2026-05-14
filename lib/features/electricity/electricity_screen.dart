import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:utilityhub/config/api.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';
import 'package:utilityhub/core/widgets/app_responsive_layout.dart';
import 'verify_meter_screen.dart';

class ElectricityScreen extends StatefulWidget {
  const ElectricityScreen({super.key});

  @override
  State<ElectricityScreen> createState() => _ElectricityScreenState();
}

class _ElectricityScreenState extends State<ElectricityScreen> {
  bool loading = true;
  List<dynamic> discos = [];
  String? selectedDiscoCode;

  @override
  void initState() {
    super.initState();
    fetchDiscos();
  }

  Future<void> fetchDiscos() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.api("/api/electricity/discos")),
      );

      print("Backend RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (!mounted) return;
        setState(() {
          discos = decoded["data"] ?? [];
          loading = false;
        });
      } else {
        if (!mounted) return;
        setState(() => loading = false);
      }
    } catch (e) {
      print("Error fetching discos: $e");
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeaderr(title: "Buy Electricity"), // ⭐ APPLY HEADER HERE

      body: AppResponsiveLayout(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: loading
              ? const Center(child: CircularProgressIndicator())
              : discos.isEmpty
              ? const Center(
                  child: Text(
                    "Unable to load discos. Please try again.",
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : Column(
                  children: [
                    DropdownButtonFormField<String>(
                      hint: const Text("Select Disco"),
                      initialValue: selectedDiscoCode,

                      // ⭐ FIX: dark dropdown menu
                      dropdownColor: const Color(0xFF1F2937),

                      // ⭐ FIX: remove transparent override
                      decoration: const InputDecoration(labelText: "Disco"),

                      items: discos.map<DropdownMenuItem<String>>((d) {
                        return DropdownMenuItem(
                          value: d["code"],
                          child: Text(d["name"]),
                        );
                      }).toList(),

                      onChanged: (value) {
                        setState(() => selectedDiscoCode = value);
                      },
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: selectedDiscoCode == null
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => VerifyMeterScreen(
                                      discoCode: selectedDiscoCode!,
                                    ),
                                  ),
                                );
                              },
                        child: const Text("Start Purchase"),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
