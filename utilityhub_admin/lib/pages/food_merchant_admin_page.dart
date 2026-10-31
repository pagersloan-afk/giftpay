import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/food_merchant_admin_api.dart';

class FoodMerchantAdminPage extends StatelessWidget {
  const FoodMerchantAdminPage({super.key});

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
              'Food Merchant Applications',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Review business registration details before enabling merchant access.',
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('foodMerchants')
                    .orderBy('appliedAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Unable to load applications: ${snapshot.error}'),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(
                      child: Text('No food merchant applications found.'),
                    );
                  }
                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data();
                      final status = (data['status'] ?? 'unknown').toString();
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          title: Text(
                            (data['restaurantName'] ?? 'Unnamed business').toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              '${data['legalOwnerName'] ?? '-'}  •  ${data['registrationNumber'] ?? '-'}\n${data['phone'] ?? '-'}',
                            ),
                          ),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _StatusChip(status: status),
                              const SizedBox(width: 8),
                              const Icon(Icons.chevron_right, color: Colors.blueGrey),
                            ],
                          ),
                          onTap: () => showDialog(
                            context: context,
                            builder: (_) => _MerchantReviewDialog(
                              uid: doc.id,
                              data: data,
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
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status == 'approved'
        ? Colors.green
        : status == 'rejected'
            ? Colors.red
            : Colors.orange;
    return Chip(
      label: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
      backgroundColor: color.withOpacity(.10),
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _MerchantReviewDialog extends StatefulWidget {
  final String uid;
  final Map<String, dynamic> data;

  const _MerchantReviewDialog({required this.uid, required this.data});

  @override
  State<_MerchantReviewDialog> createState() => _MerchantReviewDialogState();
}

class _MerchantReviewDialogState extends State<_MerchantReviewDialog> {
  final notesCtrl = TextEditingController();
  bool registrationChecked = false;
  bool foodSafetyChecked = false;
  bool saving = false;
  String? error;

  @override
  void dispose() {
    notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _review(String decision) async {
    final notes = notesCtrl.text.trim();
    if (decision == 'rejected' && notes.isEmpty) {
      setState(() => error = 'Enter a reason before rejecting this application.');
      return;
    }
    if (decision == 'approved' &&
        (!registrationChecked || !foodSafetyChecked)) {
      setState(() => error =
          'Confirm both registration and food-safety review before approval.');
      return;
    }

    setState(() {
      saving = true;
      error = null;
    });

    try {
      final result = await FoodMerchantAdminApi.review(
        merchantUid: widget.uid,
        decision: decision,
        registrationChecked: registrationChecked,
        foodSafetyChecked: foodSafetyChecked,
        notes: notes,
      );

      if (!mounted) return;
      Navigator.of(context).pop();

      final emailStatus = decision == 'approved'
          ? (result.emailSent == true
              ? ' Approval email sent.'
              : ' Approval succeeded, but the email could not be sent. Check backend logs and SMTP settings.')
          : '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${result.message}$emailStatus')),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString().replaceFirst('Exception: ', '');
          saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final status = (d['status'] ?? 'pending').toString();
    final verification = d['verification'] is Map
        ? Map<String, dynamic>.from(d['verification'] as Map)
        : <String, dynamic>{};

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 780),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Merchant Application Review',
                      style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                    ),
                  ),
                  _StatusChip(status: status),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _section('Business & owner', [
                        _line('Business name', d['restaurantName']),
                        _line('Legal owner', d['legalOwnerName']),
                        _line('Business type', d['businessType']),
                        _line('Description', d['description']),
                      ]),
                      _section('Registration', [
                        _line('Registration authority', d['registrationType']),
                        _line('Registration number', d['registrationNumber']),
                        _line('Food safety / operating permit',
                            d['foodSafetyPermitNumber']),
                      ]),
                      _section('Contact & location', [
                        _line('Phone', d['phone']),
                        _line('Business email', d['businessEmail']),
                        _line('Physical address', d['address']),
                      ]),
                      if (status == 'pending') ...[
                        const Divider(height: 28),
                        const Text(
                          'Verification checklist',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        CheckboxListTile(
                          value: registrationChecked,
                          onChanged: saving
                              ? null
                              : (v) => setState(
                                  () => registrationChecked = v ?? false),
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'I have independently checked the business registration details.',
                          ),
                        ),
                        CheckboxListTile(
                          value: foodSafetyChecked,
                          onChanged: saving
                              ? null
                              : (v) => setState(
                                  () => foodSafetyChecked = v ?? false),
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'I have checked the food-safety permit or confirmed it is not applicable.',
                          ),
                        ),
                        TextField(
                          controller: notesCtrl,
                          maxLines: 3,
                          enabled: !saving,
                          decoration: const InputDecoration(
                            labelText: 'Review notes / rejection reason',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                        ),
                        if (error != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                      ] else if ((verification['reviewNotes'] ?? '')
                          .toString()
                          .isNotEmpty)
                        Text('Review notes: ${verification['reviewNotes']}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: saving ? null : () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                  if (status == 'pending') ...[
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: saving ? null : () => _review('rejected'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Reject'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: saving ? null : () => _review('approved'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Approve'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      );

  Widget _line(String label, dynamic value) => Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 190,
              child: Text(label, style: const TextStyle(color: Colors.black54)),
            ),
            Expanded(
              child: SelectableText(
                (value == null || value.toString().trim().isEmpty)
                    ? '-'
                    : value.toString(),
              ),
            ),
          ],
        ),
      );
}
