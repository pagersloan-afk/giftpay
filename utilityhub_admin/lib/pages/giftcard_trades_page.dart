import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GiftCardTradesPage extends StatelessWidget {
  const GiftCardTradesPage({super.key});

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
              "Gift Card Trades",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("giftcard_trades")
                    .orderBy("createdAt", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text("No gift card trades found."),
                    );
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text("User")),
                        DataColumn(label: Text("Card Type")),
                        DataColumn(label: Text("Amount")),
                        DataColumn(label: Text("Status")),
                        DataColumn(label: Text("Actions")),
                      ],
                      rows: docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;

                        return DataRow(
                          cells: [
                            DataCell(Text(data["userEmail"] ?? "")),
                            DataCell(Text(data["cardType"] ?? "")),
                            DataCell(Text("\$${data["amount"]}")),
                            DataCell(_statusBadge(data["status"])),
                            DataCell(
                              ElevatedButton(
                                onPressed: () {
                                  _openTradeDetails(context, doc.id, data);
                                },
                                child: const Text("View"),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;

    switch (status) {
      case "approved":
        color = Colors.green;
        break;
      case "rejected":
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _openTradeDetails(BuildContext context, String id, Map data) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Trade Details"),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("User: ${data["userEmail"]}"),
              Text("Card Type: ${data["cardType"]}"),
              Text("Amount: \$${data["amount"]}"),
              Text("Status: ${data["status"]}"),

              const SizedBox(height: 16),

              if (data["imageUrl"] != null)
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) =>
                          Dialog(child: Image.network(data["imageUrl"])),
                    );
                  },
                  child: Image.network(
                    data["imageUrl"],
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),

              const SizedBox(height: 24),

              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection("giftcard_trades")
                          .doc(id)
                          .update({"status": "approved"});

                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text("Approve"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection("giftcard_trades")
                          .doc(id)
                          .update({"status": "rejected"});

                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text("Reject"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
