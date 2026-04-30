import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:utilityhub/features/wallet/services/virtual_account_service.dart';

class VirtualAccountCard extends StatefulWidget {
  const VirtualAccountCard({super.key});

  @override
  State<VirtualAccountCard> createState() => _VirtualAccountCardState();
}

class _VirtualAccountCardState extends State<VirtualAccountCard> {
  Map<String, dynamic>? va;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadVA();
  }

  Future<void> loadVA() async {
    final service = VirtualAccountService();
    final result = await service.fetchOrCreateVA();
    setState(() {
      va = result;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (va == null) {
      return const Text("Unable to load virtual account");
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your GiftPay Account Number",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                va!["accountNumber"],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: va!["accountNumber"]),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Account number copied")),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      // For web, you can use JS share or fallback
                      Clipboard.setData(
                        ClipboardData(text: va!["accountNumber"]),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Copied for sharing")),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 4),
          Text(va!["bankName"], style: const TextStyle(color: Colors.black54)),
          Text(
            va!["accountName"],
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
