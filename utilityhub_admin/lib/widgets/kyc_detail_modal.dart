import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KycDetailModal extends StatefulWidget {
  final Map<String, dynamic> data;
  final String userId;

  const KycDetailModal({super.key, required this.data, required this.userId});

  @override
  State<KycDetailModal> createState() => _KycDetailModalState();
}

class _KycDetailModalState extends State<KycDetailModal> {
  final TextEditingController reasonCtrl = TextEditingController();
  bool rejecting = false;

  @override
  Widget build(BuildContext context) {
    final docs = widget.data["kycDocuments"] ?? {};

    return Dialog(
      insetPadding: const EdgeInsets.all(40),
      child: Container(
        width: 700,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ⭐ Title
              const Text(
                "KYC Details",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              // ⭐ User Info
              Text("Name: ${widget.data["name"] ?? "-"}"),
              Text("Email: ${widget.data["email"] ?? "-"}"),
              Text("NIN/BVN: ${widget.data["nin"] ?? "-"}"),
              Text("Address: ${widget.data["address"] ?? "-"}"),
              Text("DOB: ${widget.data["dob"] ?? "-"}"),

              const SizedBox(height: 20),

              // ⭐ Documents
              const Text(
                "Uploaded Documents",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  _docPreview("ID Front", docs["idFront"]),
                  const SizedBox(width: 12),
                  _docPreview("ID Back", docs["idBack"]),
                  const SizedBox(width: 12),
                  _docPreview("Selfie", docs["selfie"]),
                ],
              ),

              const SizedBox(height: 30),

              // ⭐ Approve / Reject Buttons
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection("users")
                          .doc(widget.userId)
                          .update({
                            "kycStatus": "verified",
                            "kycRejectionReason": null,
                          });

                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                    ),
                    child: const Text("Approve"),
                  ),

                  const SizedBox(width: 12),

                  ElevatedButton(
                    onPressed: () {
                      _openRejectReasonDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
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

  // ⭐ Reject Reason Dialog
  void _openRejectReasonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Reject KYC"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Please provide a reason for rejection."),
              const SizedBox(height: 12),
              TextField(
                controller: reasonCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Enter rejection reason...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: rejecting
                  ? null
                  : () async {
                      if (reasonCtrl.text.trim().isEmpty) return;

                      setState(() => rejecting = true);

                      await FirebaseFirestore.instance
                          .collection("users")
                          .doc(widget.userId)
                          .update({
                            "kycStatus": "rejected",
                            "kycRejectionReason": reasonCtrl.text.trim(),
                          });

                      setState(() => rejecting = false);

                      Navigator.pop(context); // close reason dialog
                      Navigator.pop(context); // close main modal
                    },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: rejecting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text("Reject"),
            ),
          ],
        );
      },
    );
  }

  Widget _docPreview(String label, String? url) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Container(
            height: 160,
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
