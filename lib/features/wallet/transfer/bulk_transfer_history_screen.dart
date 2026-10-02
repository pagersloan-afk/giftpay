import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:utilityhub/config/api.dart';

class BulkTransferHistoryScreen extends StatefulWidget {
  const BulkTransferHistoryScreen({super.key});

  @override
  State<BulkTransferHistoryScreen> createState() =>
      _BulkTransferHistoryScreenState();
}

class _BulkTransferHistoryScreenState extends State<BulkTransferHistoryScreen> {
  final _db = FirebaseFirestore.instance;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  String _money(dynamic value) {
    final amount = value is num
        ? value.toDouble()
        : double.tryParse('$value') ?? 0;
    return amount
        .toStringAsFixed(2)
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+\.)'), (m) => '${m[1]},');
  }

  DateTime? _date(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  String _formatDate(dynamic value) {
    final date = _date(value);
    if (date == null) return 'Date unavailable';
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '$day/$month/${local.year} • '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  String _status(dynamic value) {
    final status = '${value ?? 'unknown'}'
        .trim()
        .replaceAll('_', ' ')
        .toLowerCase();
    if (status.isEmpty) return 'Unknown';
    return status[0].toUpperCase() + status.substring(1);
  }

  Color _statusColor(dynamic value) {
    switch ('${value ?? ''}'.toLowerCase()) {
      case 'success':
      case 'completed':
        return Colors.green;
      case 'failed':
      case 'reversed':
      case 'expired':
        return Colors.red;
      case 'processing':
      case 'submitting':
      case 'pending':
      case 'pending_authorization':
      case 'unknown':
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
  }

  Future<String?> _token() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return user.getIdToken(true);
  }

  Future<Map<String, dynamic>> _refreshBatch(String reference) async {
    final token = await _token();
    if (token == null || token.isEmpty) {
      throw Exception('Please sign in again.');
    }

    final response = await http
        .get(
          Uri.parse(ApiConfig.api('/api/transfers/bulk-transfer/$reference')),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 30));

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw Exception('Invalid status response.');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        decoded['message']?.toString() ?? 'Unable to refresh batch status.',
      );
    }

    final batch = decoded['batch'];
    if (batch is Map) {
      return Map<String, dynamic>.from(batch);
    }
    throw Exception('Batch details were not returned.');
  }

  void _openDetails(String reference, Map<String, dynamic> data) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BulkTransferBatchDetailsScreen(
          batchReference: reference,
          initialData: data,
          refreshBatch: _refreshBatch,
          money: _money,
          formatDate: _formatDate,
          statusLabel: _status,
          statusColor: _statusColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = _userId;

    return Scaffold(
      appBar: AppBar(title: const Text('Bulk transfer history')),
      body: userId == null
          ? const Center(child: Text('Please sign in to view history.'))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _db
                  .collection('users')
                  .doc(userId)
                  .collection('bulk_transfers')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Could not load bulk transfer history.\n'
                        '${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs.toList() ?? [];

                docs.sort((a, b) {
                  final dateA =
                      _date(a.data()['createdAt']) ??
                      DateTime.fromMillisecondsSinceEpoch(0);
                  final dateB =
                      _date(b.data()['createdAt']) ??
                      DateTime.fromMillisecondsSinceEpoch(0);
                  return dateB.compareTo(dateA);
                });

                if (docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 56,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'No saved bulk transfers yet',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Submitted batches will appear here.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await _db
                        .collection('users')
                        .doc(userId)
                        .collection('bulk_transfers')
                        .get(const GetOptions(source: Source.server));
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data();
                      final reference = (data['batchReference'] ?? doc.id)
                          .toString();
                      final items = data['items'] is List
                          ? data['items'] as List
                          : const [];
                      final itemCount = data['itemCount'] is num
                          ? (data['itemCount'] as num).toInt()
                          : items.length;
                      final status = data['status'];
                      final title =
                          '${data['title'] ?? data['batchName'] ?? 'Bulk transfer'}';
                      final total = data['totalAmount'];
                      final debited = data['totalDebited'];

                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => _openDetails(reference, data),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    _StatusChip(
                                      label: _status(status),
                                      color: _statusColor(status),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  reference,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(_formatDate(data['createdAt'])),
                                const Divider(height: 22),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _SummaryValue(
                                        label: 'Recipients',
                                        value: '$itemCount',
                                      ),
                                    ),
                                    Expanded(
                                      child: _SummaryValue(
                                        label: 'Transfer amount',
                                        value: '₦${_money(total)}',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Total debited: ₦${_money(debited)}',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class BulkTransferBatchDetailsScreen extends StatefulWidget {
  final String batchReference;
  final Map<String, dynamic> initialData;
  final Future<Map<String, dynamic>> Function(String) refreshBatch;
  final String Function(dynamic) money;
  final String Function(dynamic) formatDate;
  final String Function(dynamic) statusLabel;
  final Color Function(dynamic) statusColor;

  const BulkTransferBatchDetailsScreen({
    super.key,
    required this.batchReference,
    required this.initialData,
    required this.refreshBatch,
    required this.money,
    required this.formatDate,
    required this.statusLabel,
    required this.statusColor,
  });

  @override
  State<BulkTransferBatchDetailsScreen> createState() =>
      _BulkTransferBatchDetailsScreenState();
}

class _BulkTransferBatchDetailsScreenState
    extends State<BulkTransferBatchDetailsScreen> {
  late Map<String, dynamic> _batch;
  bool _refreshing = false;
  String? _refreshError;

  @override
  void initState() {
    super.initState();
    _batch = Map<String, dynamic>.from(widget.initialData);
  }

  Future<void> _refresh() async {
    if (_refreshing) return;
    setState(() {
      _refreshing = true;
      _refreshError = null;
    });

    try {
      final updated = await widget.refreshBatch(widget.batchReference);
      if (!mounted) return;
      setState(() => _batch = updated);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _refreshError = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _batch['items'] is List
        ? (_batch['items'] as List)
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList()
        : <Map<String, dynamic>>[];

    final status = _batch['status'];
    final refunded = _batch['refunded'] == true;
    final partialRefund = _batch['partialRefundAmount'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Batch details'),
        actions: [
          IconButton(
            tooltip: 'Refresh status',
            onPressed: _refreshing ? null : _refresh,
            icon: _refreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_batch['title'] ?? _batch['batchName'] ?? 'Bulk transfer'}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  SelectableText(widget.batchReference),
                  const SizedBox(height: 12),
                  _StatusChip(
                    label: widget.statusLabel(status),
                    color: widget.statusColor(status),
                  ),
                  const Divider(height: 24),
                  _detailRow('Created', widget.formatDate(_batch['createdAt'])),
                  _detailRow(
                    'Submitted',
                    widget.formatDate(_batch['submittedAt']),
                  ),
                  _detailRow(
                    'Recipients',
                    '${_batch['itemCount'] ?? items.length}',
                  ),
                  _detailRow(
                    'Transfer amount',
                    '₦${widget.money(_batch['totalAmount'])}',
                  ),
                  _detailRow('Fees', '₦${widget.money(_batch['totalFees'])}'),
                  _detailRow(
                    'Total debited',
                    '₦${widget.money(_batch['totalDebited'])}',
                  ),
                  if (_batch['providerStatus'] != null)
                    _detailRow(
                      'Provider status',
                      '${_batch['providerStatus']}',
                    ),
                  if (_batch['failureReason'] != null)
                    _detailRow('Failure reason', '${_batch['failureReason']}'),
                  if (refunded) ...[
                    const Divider(height: 20),
                    _detailRow('Refund status', 'Refund recorded'),
                    _detailRow(
                      'Refund amount',
                      '₦${widget.money(_batch['refundAmount'])}',
                    ),
                    if (_batch['refundReason'] != null)
                      _detailRow('Refund reason', '${_batch['refundReason']}'),
                  ],
                  if (partialRefund is num && partialRefund > 0) ...[
                    const Divider(height: 20),
                    _detailRow(
                      'Partial refund',
                      '₦${widget.money(partialRefund)}',
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_refreshError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _refreshError!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          const SizedBox(height: 18),
          Text(
            'Recipients (${items.length})',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No recipient details were saved for this batch.'),
              ),
            ),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final itemStatus = item['status'];

            final accountName =
                item['accountName'] ?? item['name'] ?? 'Recipient ${index + 1}';
            final accountNumber = item['accountNumber'] ?? '';
            final bankCode = item['bankCode'] ?? '';
            final amount = item['amount'];
            final fee = item['fee'];
            final debitAmount = item['debitAmount'];
            final failure = item['failureReason'];

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            '$accountName',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        _StatusChip(
                          label: widget.statusLabel(itemStatus),
                          color: widget.statusColor(itemStatus),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('Account: $accountNumber'),
                    if ('$bankCode'.isNotEmpty) Text('Bank code: $bankCode'),
                    const Divider(height: 20),
                    _detailRow('Amount', '₦${widget.money(amount)}'),
                    _detailRow('Fee', '₦${widget.money(fee)}'),
                    _detailRow('Debit amount', '₦${widget.money(debitAmount)}'),
                    if (failure != null && '$failure'.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Failure: $failure',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    if (item['reference'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: SelectableText(
                          'Reference: ${item['reference']}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _refreshing ? null : _refresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh batch status'),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
