import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:utilityhub/config/api.dart';
import 'package:utilityhub/core/widgets/app_responsive_layout.dart';

class FlutterwaveTransferReceiptScreen extends StatefulWidget {
  final String reference;
  final Map<String, dynamic>? initialTransaction;

  const FlutterwaveTransferReceiptScreen({
    super.key,
    required this.reference,
    this.initialTransaction,
  });

  @override
  State<FlutterwaveTransferReceiptScreen> createState() =>
      _FlutterwaveTransferReceiptScreenState();
}

class _FlutterwaveTransferReceiptScreenState
    extends State<FlutterwaveTransferReceiptScreen> {
  Map<String, dynamic> details = {};
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    details = Map<String, dynamic>.from(widget.initialTransaction ?? {});
    _loadReceipt();
  }

  String _text(dynamic value, [String fallback = '—']) {
    final result = value?.toString().trim() ?? '';
    return result.isEmpty || result == 'null' ? fallback : result;
  }

  double _number(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _money(dynamic value) =>
      '₦${NumberFormat('#,##0.00').format(_number(value))}';

  String _date(dynamic value) {
    DateTime? date;
    if (value is DateTime) date = value;
    if (value is num) {
      final raw = value.toInt();
      date = DateTime.fromMillisecondsSinceEpoch(
        raw < 1000000000000 ? raw * 1000 : raw,
      );
    }
    if (value is String) {
      date = DateTime.tryParse(value);
      final millis = int.tryParse(value);
      if (date == null && millis != null) {
        date = DateTime.fromMillisecondsSinceEpoch(
          millis < 1000000000000 ? millis * 1000 : millis,
        );
      }
    }
    return date == null
        ? '—'
        : DateFormat('dd MMM yyyy, h:mm a').format(date.toLocal());
  }

  Future<void> _loadReceipt() async {
    if (mounted)
      setState(() {
        loading = true;
        error = null;
      });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Please sign in again.');
      final token = await user.getIdToken(true);
      if (token == null || token.isEmpty)
        throw Exception('Authentication expired.');
      final response = await http
          .get(
            Uri.parse(
              ApiConfig.api(
                '/api/transfer/flutterwave-transfer-status/${Uri.encodeComponent(widget.reference)}',
              ),
            ),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 25));
      dynamic decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        decoded = null;
      }
      if (decoded is! Map)
        throw Exception('GiftPay returned an invalid receipt response.');
      final body = Map<String, dynamic>.from(decoded);
      final remote = body['data'] is Map
          ? Map<String, dynamic>.from(body['data'] as Map)
          : <String, dynamic>{};
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          body['status'] != true) {
        throw Exception(
          body['message']?.toString() ??
              'Could not retrieve this transfer receipt.',
        );
      }
      if (mounted)
        setState(() {
          details = {...details, ...remote, 'reference': widget.reference};
          loading = false;
          error = null;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          loading = false;
          error = e.toString().replaceFirst('Exception: ', '');
        });
    }
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'SUCCESS':
      case 'SUCCESSFUL':
      case 'COMPLETED':
        return const Color(0xFF34D399);
      case 'FAILED':
      case 'REVERSED':
      case 'CANCELLED':
        return const Color(0xFFF87171);
      default:
        return const Color(0xFFFBBF24);
    }
  }

  Widget _detail(String label, String value, {bool selectable = false}) {
    final style = const TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
          Expanded(
            child: selectable
                ? SelectableText(
                    value,
                    textAlign: TextAlign.right,
                    style: style,
                  )
                : Text(value, textAlign: TextAlign.right, style: style),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = _text(details['status'], 'PENDING').toUpperCase();
    final amount = details['amount'] ?? details['withdrawalAmount'] ?? 0;
    final fee = details['fee'] ?? 0;
    final providerFee = details['providerFee'] ?? fee;
    final vat = details['vat'] ?? 0;
    final totalDebited =
        details['totalDebited'] ?? (_number(amount) + _number(fee));
    final reference = _text(details['reference'], widget.reference);
    final bank = _text(details['bankName'] ?? details['bank_name']);
    final beneficiary = _text(
      details['beneficiaryName'] ??
          details['full_name'] ??
          details['accountName'],
    );
    final account = _text(
      details['accountNumber'] ?? details['account_number'],
    );
    final date = _date(
      details['createdAt'] ?? details['created_at'] ?? details['timestamp'],
    );
    final narration = _text(details['narration'] ?? details['reason']);
    final providerId = _text(details['providerTransferId'] ?? details['id']);
    final statusMessage = _text(details['complete_message'], '');

    return Scaffold(
      backgroundColor: const Color(0xFF0B1018),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1018),
        foregroundColor: Colors.white,
        title: const Text(
          'Transfer Receipt',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: loading ? null : _loadReceipt,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh from Flutterwave',
          ),
        ],
      ),
      body: AppResponsiveLayout(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : error != null && details.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.receipt_long,
                        color: Colors.white54,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadReceipt,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadReceipt,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141E2B),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(.08),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            status == 'SUCCESS' ||
                                    status == 'SUCCESSFUL' ||
                                    status == 'COMPLETED'
                                ? Icons.check_circle
                                : status == 'FAILED'
                                ? Icons.cancel
                                : Icons.hourglass_top,
                            size: 54,
                            color: _statusColor(status),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'BANK TRANSFER',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _money(amount),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: _statusColor(status).withOpacity(.12),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: _statusColor(status),
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (statusMessage.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              statusMessage,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141E2B),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'BENEFICIARY DETAILS',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _detail('Beneficiary', beneficiary),
                          const Divider(color: Colors.white12, height: 1),
                          _detail('Bank', bank),
                          const Divider(color: Colors.white12, height: 1),
                          _detail('Account Number', account),
                          const Divider(color: Colors.white12, height: 1),
                          _detail('Narration', narration),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141E2B),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PAYMENT DETAILS',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _detail('Transfer Amount', _money(amount)),
                          const Divider(color: Colors.white12, height: 1),
                          _detail('Fee', _money(providerFee)),
                          const Divider(color: Colors.white12, height: 1),
                          _detail('VAT', _money(vat)),
                          const Divider(color: Colors.white12, height: 1),
                          _detail('Total Fees', _money(fee)),
                          const Divider(color: Colors.white12, height: 1),
                          _detail('Total Debited', _money(totalDebited)),
                          const Divider(color: Colors.white12, height: 1),
                          _detail('Date', date),
                          const Divider(color: Colors.white12, height: 1),
                          _detail(
                            'GiftPay Reference',
                            reference,
                            selectable: true,
                          ),
                          const Divider(color: Colors.white12, height: 1),
                          _detail('Flutterwave ID', providerId),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () =>
                          Clipboard.setData(ClipboardData(text: reference)),
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy Transfer Reference'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Latest refresh warning: $error',
                        style: const TextStyle(
                          color: Colors.orangeAccent,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    const Text(
                      'This receipt displays transfer information retrieved through GiftPay from Flutterwave.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
