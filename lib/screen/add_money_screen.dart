import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:utilityhub/core/widgets/app_responsive_layout.dart';
import 'package:utilityhub/features/wallet/services/virtual_account_service.dart';
import 'package:utilityhub/features/wallet/models/virtual_account.dart';

class AddMoneyScreen extends StatefulWidget {
  const AddMoneyScreen({super.key});

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  VirtualAccount? va;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadVA();
  }

  Future<void> loadVA() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => loading = false);
      return;
    }

    final service = VirtualAccountService();

    // ⭐ STEP 1 — Fetch user profile from Firestore
    final userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    final userData = userDoc.data() ?? {};

    final name = "${userData["firstName"]} ${userData["lastName"]}".trim();
    final email = userData["email"];
    final phone = userData["phone"]; // ⭐ REAL phone number

    // ⭐ STEP 2 — Check Firestore for existing VA
    var result = await service.getVirtualAccount(user.uid);

    // ⭐ STEP 3 — Only call backend if VA does NOT exist
    if (result == null) {
      result = await service.fetchOrCreateFromBackend(
        userId: user.uid,
        name: name.isNotEmpty ? name : "GiftPay User",
        email: email ?? "no-email@giftpay.app",
        phone: phone ?? "",
      );
    }

    setState(() {
      va = result;
      loading = false;
    });
  }

  Widget _sectionDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: const [
          Expanded(child: Divider(color: Colors.white24)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text("OR", style: TextStyle(color: Colors.white70)),
          ),
          Expanded(child: Divider(color: Colors.white24)),
        ],
      ),
    );
  }

  Widget _optionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 26),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Money")),
      body: AppResponsiveLayout(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ⭐ Virtual Account Card (GiftPay style)
              if (loading)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: LinearProgressIndicator(),
                )
              else if (va != null)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4FC3F7).withOpacity(0.12),
                        blurRadius: 22,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Bank Transfer",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // ⭐ Account Number
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            va!.accountNumber,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.copy,
                                  color: Colors.white70,
                                ),
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: va!.accountNumber),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Account number copied"),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.share,
                                  color: Colors.white70,
                                ),
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: va!.accountNumber),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Copied for sharing"),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),
                      Text(
                        va!.bankName,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        va!.accountName,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 12),
                      const Text(
                        "FREE Instant funding within 10s",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

              _sectionDivider(),

              // ⭐ Other Payment Options (PalmPay style)
              _optionTile(
                icon: Icons.store_mall_directory,
                title: "Cash Deposit",
                subtitle: "Fund your account with nearby agents",
                onTap: () {},
              ),

              _optionTile(
                icon: Icons.credit_card,
                title: "Top-up with Card/Account",
                subtitle: "Add money from your bank card/account",
                onTap: () {
                  Navigator.pushNamed(context, "/fund");
                },
              ),

              _optionTile(
                icon: Icons.send,
                title: "Receive Money",
                subtitle: "Share your account and ask for transfer",
                onTap: () {},
              ),

              _optionTile(
                icon: Icons.phone_android,
                title: "USSD",
                subtitle: "Use your other bank’s USSD code",
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
