import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/kyc_admin_api.dart';

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
  bool reviewing = false;
  bool loadingDocuments = true;
  String? documentError;
  Map<String, String?> urls = {'idFront': null, 'idBack': null, 'selfie': null};

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  @override
  void dispose() {
    reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDocuments() async {
    setState(() { loadingDocuments = true; documentError = null; });
    try {
      final result = await KycAdminApi.getDocumentUrls(widget.userId);
      if (!mounted) return;
      setState(() { urls = result; loadingDocuments = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        documentError = e.toString().replaceFirst('Exception: ', '');
        loadingDocuments = false;
      });
    }
  }

  Future<void> _approve() async {
    if (reviewing) return;
    setState(() => reviewing = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        'kycStatus': 'verified',
        'kycRejectionReason': null,
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => reviewing = false);
      _message('Could not approve KYC: $e');
    }
  }

  Future<void> _reject() async {
    final reason = reasonCtrl.text.trim();
    if (reason.isEmpty) { _message('Please enter a rejection reason.'); return; }
    if (rejecting) return;
    setState(() => rejecting = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        'kycStatus': 'rejected',
        'kycRejectionReason': reason,
      });
      if (!mounted) return;
      Navigator.pop(context);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => rejecting = false);
      _message('Could not reject KYC: $e');
    }
  }

  void _message(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 850, maxHeight: 850),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              const Expanded(child: Text('KYC Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ]),
            _detail('User UID', widget.userId),
            _detail('Name', widget.data['name']?.toString() ?? '-'),
            _detail('Email', widget.data['email']?.toString() ?? '-'),
            _detail('NIN/BVN', widget.data['nin']?.toString() ?? '-'),
            _detail('Address', widget.data['address']?.toString() ?? '-'),
            _detail('DOB', widget.data['dob']?.toString() ?? '-'),
            _detail('Status', widget.data['kycStatus']?.toString() ?? '-'),
            const SizedBox(height: 20),
            const Text('Uploaded Documents', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            const Text('Secure temporary viewing links expire after 10 minutes.', style: TextStyle(fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 12),
            if (loadingDocuments)
              const Center(child: Padding(padding: EdgeInsets.all(28), child: CircularProgressIndicator()))
            else if (documentError != null)
              Container(width: double.infinity, padding: const EdgeInsets.all(14), color: Colors.red.shade50, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(documentError!, style: TextStyle(color: Colors.red.shade800)),
                TextButton.icon(onPressed: _loadDocuments, icon: const Icon(Icons.refresh), label: const Text('Retry')),
              ]))
            else
              LayoutBuilder(builder: (context, constraints) {
                final w = constraints.maxWidth >= 600 ? (constraints.maxWidth - 24) / 3 : (constraints.maxWidth - 12) / 2;
                return Wrap(spacing: 12, runSpacing: 12, children: [
                  _preview('ID Front', urls['idFront'], w),
                  _preview('ID Back', urls['idBack'], w),
                  _preview('Selfie', urls['selfie'], w),
                ]);
              }),
            const SizedBox(height: 26),
            Wrap(spacing: 12, children: [
              ElevatedButton(
                onPressed: reviewing ? null : _approve,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                child: reviewing ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Approve'),
              ),
              ElevatedButton(
                onPressed: reviewing ? null : () => _openRejectDialog(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                child: const Text('Reject'),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _detail(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Text('$label: $value'),
  );

  Widget _preview(String label, String? url, double width) => SizedBox(
    width: width,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 7),
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 180,
          width: double.infinity,
          color: Colors.black12,
          child: url == null || url.isEmpty
              ? const Center(child: Text('Document not found', style: TextStyle(color: Colors.red)))
              : Image.network(url, fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) => progress == null
                      ? child
                      : const Center(child: CircularProgressIndicator()),
                  errorBuilder: (_, __, ___) => const Center(child: Text('Image could not load', style: TextStyle(color: Colors.red)))),
        ),
      ),
    ]),
  );

  void _openRejectDialog(BuildContext context) {
    showDialog(context: context, builder: (dialogContext) => AlertDialog(
      title: const Text('Reject KYC'),
      content: SizedBox(width: 420, child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Please provide a reason for rejection.'),
        const SizedBox(height: 12),
        TextField(controller: reasonCtrl, maxLines: 3, decoration: InputDecoration(
          hintText: 'Enter rejection reason...',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        )),
      ])),
      actions: [
        TextButton(onPressed: rejecting ? null : () => Navigator.pop(dialogContext), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: rejecting ? null : _reject,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: rejecting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Reject', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }
}
