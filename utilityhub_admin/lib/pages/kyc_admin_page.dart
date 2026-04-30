import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/kyc_detail_modal.dart'; // ⭐ IMPORT MODAL

class KycAdminPage extends StatelessWidget {
  const KycAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "KYC Verification",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .where("kycStatus", isNotEqualTo: "unverified")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final users = snapshot.data!.docs;

                  if (users.isEmpty) {
                    return const Center(child: Text("No KYC submissions yet"));
                  }

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final data = users[index].data() as Map<String, dynamic>;
                      final userId = users[index].id;

                      // ⭐ FULL CARD WITH MODAL CLICK
                      return InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) =>
                                KycDetailModal(data: data, userId: userId),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ⭐ User Info
                                Text(
                                  data["name"] ?? "Unknown User",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(data["email"] ?? ""),
                                const SizedBox(height: 10),

                                Text("NIN/BVN: ${data["nin"] ?? "-"}"),
                                Text("Address: ${data["address"] ?? "-"}"),
                                Text("DOB: ${data["dob"] ?? "-"}"),

                                const SizedBox(height: 10),

                                // ⭐ Status Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: data["kycStatus"] == "verified"
                                        ? Colors.green.shade100
                                        : data["kycStatus"] == "pending"
                                        ? Colors.orange.shade100
                                        : Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    data["kycStatus"].toUpperCase(),
                                    style: TextStyle(
                                      color: data["kycStatus"] == "verified"
                                          ? Colors.green
                                          : data["kycStatus"] == "pending"
                                          ? Colors.orange
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // ⭐ Document Previews
                                if (data["kycDocuments"] != null)
                                  Row(
                                    children: [
                                      _docPreview(
                                        "ID Front",
                                        data["kycDocuments"]["idFront"],
                                      ),
                                      const SizedBox(width: 12),
                                      _docPreview(
                                        "ID Back",
                                        data["kycDocuments"]["idBack"],
                                      ),
                                      const SizedBox(width: 12),
                                      _docPreview(
                                        "Selfie",
                                        data["kycDocuments"]["selfie"],
                                      ),
                                    ],
                                  ),

                                const SizedBox(height: 20),

                                // ⭐ Tap to view full details
                                Text(
                                  "Tap to view full details",
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _docPreview(String label, String? url) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.black12,
              image: url != null
                  ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
