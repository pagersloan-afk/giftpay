import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:utilityhub/config/api.dart';

class BulkRecipient {
  final String name, accountNumber, bankCode, bankName;
  final double amount;
  final String narration;

  const BulkRecipient({
    required this.name,
    required this.accountNumber,
    required this.bankCode,
    required this.bankName,
    required this.amount,
    this.narration = '',
  });

  Map<String, dynamic> toJson() => {
    'accountName': name,
    'accountNumber': accountNumber,
    'bankCode': bankCode,
    'amount': amount,
    'narration': narration,
  };
}

class BulkTransferScreen extends StatefulWidget {
  const BulkTransferScreen({super.key});

  @override
  State<BulkTransferScreen> createState() => _BulkTransferScreenState();
}

class _BulkTransferScreenState extends State<BulkTransferScreen> {
  final _batchName = TextEditingController(text: 'GiftPay bulk transfer');
  final List<BulkRecipient> _recipients = [];
  final _money = NumberFormatHelper();

  bool _loading = false;
  double? _balance;
  String? _batchReference;
  Map<String, dynamic>? _lastResult;

  double get _total =>
      _recipients.fold(0, (sum, recipient) => sum + recipient.amount);

  // Preview estimate only. The backend calculates authoritative fees.
  double get _estimatedFees => _recipients.fold(
    0,
    (sum, recipient) =>
        sum +
        (recipient.amount <= 5000
            ? 10
            : recipient.amount <= 50000
            ? 25
            : 50),
  );

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  @override
  void dispose() {
    _batchName.dispose();
    super.dispose();
  }

  Future<void> _loadBalance() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('wallets')
          .doc(user.uid)
          .get();

      final value = doc.data()?['balance'];

      if (mounted) {
        setState(() {
          _balance = value is num
              ? value.toDouble()
              : double.tryParse('$value');
        });
      }
    } catch (_) {}
  }

  Future<String?> _token() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return user.getIdToken(true);
  }

  Future<void> _addRecipient() async {
    final result = await showDialog<BulkRecipient>(
      context: context,
      builder: (_) => const _RecipientDialog(),
    );

    if (result != null && mounted) {
      setState(() => _recipients.add(result));
    }
  }

  // Loads recipients from a previously saved batch.
  Future<void> _loadSavedBatch(String batchReference) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_loading) return;
    setState(() => _loading = true);

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('bulk_transfers')
          .doc(batchReference)
          .get();

      if (!doc.exists) {
        throw Exception('Saved batch not found.');
      }

      final data = doc.data()!;
      final rawItems = data['items'];

      if (rawItems is! List) {
        throw Exception(
          'This batch does not contain a recipient list. '
          'The saved batch format may be different.',
        );
      }

      final loadedRecipients = <BulkRecipient>[];

      for (final item in rawItems) {
        if (item is! Map) continue;

        final amountValue = item['amount'];
        final amount = amountValue is num
            ? amountValue.toDouble()
            : double.tryParse('$amountValue');

        final name = (item['accountName'] ?? item['name'] ?? '')
            .toString()
            .trim();
        final accountNumber = (item['accountNumber'] ?? '').toString().trim();
        final bankCode = (item['bankCode'] ?? '').toString().trim();
        final bankName = (item['bankName'] ?? '').toString().trim();
        final narration = (item['narration'] ?? '').toString();

        if (name.isEmpty ||
            accountNumber.isEmpty ||
            bankCode.isEmpty ||
            amount == null ||
            !amount.isFinite ||
            amount <= 0) {
          continue;
        }

        loadedRecipients.add(
          BulkRecipient(
            name: name,
            accountNumber: accountNumber,
            bankCode: bankCode,
            bankName: bankName,
            amount: amount,
            narration: narration,
          ),
        );
      }

      if (loadedRecipients.isEmpty) {
        throw Exception('No usable recipients were found in this batch.');
      }

      if (!mounted) return;

      setState(() {
        _recipients
          ..clear()
          ..addAll(loadedRecipients);

        _batchName.text = (data['batchName'] ?? 'GiftPay bulk transfer')
            .toString();

        _batchReference = null;
        _lastResult = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${loadedRecipients.length} recipients loaded from saved batch.',
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Displays saved batches belonging to the signed-in user.
  Widget _savedBatchSelector() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('bulk_transfers')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Card(
            child: ListTile(
              title: const Text('Saved batches'),
              subtitle: Text('Unable to load saved batches: ${snapshot.error}'),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: ListTile(
              title: Text('Saved batches'),
              trailing: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saved batches',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (docs.isEmpty)
                  const Text('No saved batches found.')
                else
                  DropdownButtonFormField<String>(
                    value: null,
                    isExpanded: true,
                    dropdownColor: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                    style: const TextStyle(color: Colors.white),
                    iconEnabledColor: Colors.white,
                    decoration: const InputDecoration(
                      labelText: 'Select a saved batch',
                      labelStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    items: docs.map((doc) {
                      final data = doc.data();
                      final name = (data['batchName'] ?? doc.id).toString();
                      final count = data['itemCount'];

                      return DropdownMenuItem<String>(
                        value: doc.id,
                        child: Container(
                          color: Colors.black,
                          width: double.infinity,
                          child: Text(
                            count == null ? name : '$name ($count recipients)',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: _loading
                        ? null
                        : (reference) {
                            if (reference != null) {
                              _loadSavedBatch(reference);
                            }
                          },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submit(String pin) async {
    if (_loading) return;
    setState(() => _loading = true);

    try {
      final token = await _token();
      if (token == null || token.isEmpty) {
        throw Exception('Please sign in again.');
      }

      final response = await http
          .post(
            Uri.parse(ApiConfig.api('/api/transfers/bulk-transfer')),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'batchName': _batchName.text.trim().isEmpty
                  ? 'GiftPay bulk transfer'
                  : _batchName.text.trim(),
              'transactionPin': pin,
              'recipients': _recipients.map((r) => r.toJson()).toList(),
            }),
          )
          .timeout(const Duration(seconds: 45));

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid server response.');
      }

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          decoded['batchReference'] != null) {
        if (mounted) {
          setState(() {
            _batchReference = decoded['batchReference'].toString();
            _lastResult = decoded;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                decoded['message']?.toString() ?? 'Batch submitted.',
              ),
            ),
          );
        }
      } else {
        throw Exception(
          decoded['message']?.toString() ??
              'Bulk transfer could not be submitted.',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirm() async {
    if (_recipients.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Review bulk transfer'),
        content: Text(
          '${_recipients.length} recipients\n'
          'Transfer amount: ₦${_money.format(_total)}\n'
          'Estimated fees: ₦${_money.format(_estimatedFees)}\n'
          'Estimated total: ₦${_money.format(_total + _estimatedFees)}\n\n'
          'Final fees and available balance are calculated by the server.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Back'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _PinDialog(onSubmit: (pin) => _submit(pin)),
    );
  }

  Future<void> _refreshStatus() async {
    final reference = _batchReference;
    if (reference == null) return;

    final token = await _token();
    if (token == null) return;

    try {
      final response = await http
          .get(
            Uri.parse(ApiConfig.api('/api/transfers/bulk-transfer/$reference')),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 30));

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid status response.');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (mounted) {
          setState(() {
            _lastResult = decoded['batch'] is Map<String, dynamic>
                ? decoded['batch'] as Map<String, dynamic>
                : decoded;
          });
        }
      } else {
        throw Exception(decoded['message'] ?? 'Unable to refresh status');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _reconcile() async {
    final reference = _batchReference;
    if (reference == null) return;

    final token = await _token();
    if (token == null) return;

    try {
      final response = await http
          .post(
            Uri.parse(
              ApiConfig.api(
                '/api/transfers/bulk-transfer/$reference/reconcile',
              ),
            ),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: '{}',
          )
          .timeout(const Duration(seconds: 30));

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Invalid reconciliation response.');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (mounted) setState(() => _lastResult = decoded);
      } else {
        throw Exception(decoded['message'] ?? 'Reconciliation failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final submitted = _batchReference != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Bulk transfer')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_balance != null)
            Card(
              child: ListTile(
                title: const Text('Primary wallet balance'),
                trailing: Text('₦${_money.format(_balance!)}'),
              ),
            ),
          if (!submitted) ...[
            _savedBatchSelector(),
            const SizedBox(height: 16),
            TextField(
              controller: _batchName,
              decoration: const InputDecoration(
                labelText: 'Batch name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Recipients (${_recipients.length})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                FilledButton.icon(
                  onPressed: _loading ? null : _addRecipient,
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('Add recipient'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_recipients.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('Add bank recipients to prepare a batch.'),
                ),
              ),
            ...List.generate(_recipients.length, (index) {
              final recipient = _recipients[index];

              return Card(
                child: ListTile(
                  title: Text(recipient.name),
                  subtitle: Text(
                    '${recipient.bankName} • ${recipient.accountNumber}\n'
                    '₦${_money.format(recipient.amount)}',
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: _loading
                        ? null
                        : () => setState(() => _recipients.removeAt(index)),
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _line('Transfer amount', '₦${_money.format(_total)}'),
                    _line(
                      'Estimated fees',
                      '₦${_money.format(_estimatedFees)}',
                    ),
                    const Divider(),
                    _line(
                      'Estimated total',
                      '₦${_money.format(_total + _estimatedFees)}',
                      bold: true,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Fee estimate is for preview only. '
                      'The backend is authoritative.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _recipients.isEmpty || _loading ? null : _confirm,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Review and continue'),
            ),
          ] else ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Batch submitted',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SelectableText('Reference: $_batchReference'),
                    Text(
                      'Status: ${_lastResult?['status'] ?? _lastResult?['providerStatus'] ?? 'Processing'}',
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _refreshStatus,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh status'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _reconcile,
                          icon: const Icon(Icons.sync),
                          label: const Text('Reconcile'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (_lastResult?['items'] is List)
              ...(_lastResult!['items'] as List).map((item) {
                final map = item is Map ? item : <String, dynamic>{};

                return Card(
                  child: ListTile(
                    title: Text('${map['accountName'] ?? 'Recipient'}'),
                    subtitle: Text(
                      '${map['accountNumber'] ?? ''} • '
                      '${map['failureReason'] ?? ''}',
                    ),
                    trailing: Text('${map['status'] ?? 'pending'}'),
                  ),
                );
              }),
            TextButton(
              onPressed: () {
                setState(() {
                  _batchReference = null;
                  _lastResult = null;
                  _recipients.clear();
                });
              },
              child: const Text('Start another batch'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _line(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipientDialog extends StatefulWidget {
  const _RecipientDialog();

  @override
  State<_RecipientDialog> createState() => _RecipientDialogState();
}

class _RecipientDialogState extends State<_RecipientDialog> {
  final _account = TextEditingController();
  final _accountName = TextEditingController();
  final _amount = TextEditingController();
  final _narration = TextEditingController();

  List<Map<String, dynamic>> _banks = [];
  String? _selectedBankCode;
  String? _selectedBankName;

  bool _loadingBanks = true;
  bool _resolving = false;
  bool _resolved = false;
  bool _saving = false;

  String? _bankError;
  String? _resolveError;
  int _resolveSequence = 0;

  @override
  void initState() {
    super.initState();
    _account.addListener(_onAccountChanged);
    _loadBanks();
  }

  @override
  void dispose() {
    _account.removeListener(_onAccountChanged);
    _account.dispose();
    _accountName.dispose();
    _amount.dispose();
    _narration.dispose();
    super.dispose();
  }

  void _clearResolution() {
    _resolveSequence++;
    _accountName.clear();
    _resolved = false;
    _resolving = false;
    _resolveError = null;
  }

  void _onAccountChanged() {
    if (!mounted) return;

    setState(_clearResolution);

    if (RegExp(r'^\d{10}$').hasMatch(_account.text.trim()) &&
        _selectedBankCode != null) {
      _resolveAccount();
    }
  }

  Future<String?> _authToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return user.getIdToken(true);
  }

  Future<void> _loadBanks() async {
    setState(() {
      _loadingBanks = true;
      _bankError = null;
    });

    try {
      final token = await _authToken();
      if (token == null || token.isEmpty) {
        throw Exception('Please sign in again.');
      }

      final response = await http
          .get(
            Uri.parse(ApiConfig.api('/api/transfer/banks')),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 25));

      final decoded = jsonDecode(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = decoded is Map ? decoded['message'] : null;
        throw Exception(message?.toString() ?? 'Unable to load banks.');
      }

      dynamic list;
      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map) {
        list = decoded['banks'] ?? decoded['data'] ?? decoded['responseBody'];
        if (list is Map) {
          list = list['banks'] ?? list['data'];
        }
      }

      if (list is! List) {
        throw Exception('Bank list response was invalid.');
      }

      final parsed = <Map<String, dynamic>>[];

      for (final item in list) {
        if (item is! Map) continue;

        final code = (item['code'] ?? item['bankCode'] ?? '').toString().trim();
        final name = (item['name'] ?? item['bankName'] ?? '').toString().trim();

        if (code.isNotEmpty && name.isNotEmpty) {
          parsed.add({'code': code, 'name': name});
        }
      }

      parsed.sort(
        (a, b) => (a['name'] as String).compareTo(b['name'] as String),
      );

      if (!mounted) return;

      setState(() {
        _banks = parsed;
        _loadingBanks = false;
        if (parsed.isEmpty) {
          _bankError = 'No banks were returned. Please try again.';
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingBanks = false;
        _bankError = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _onBankChanged(String? code) {
    Map<String, dynamic>? bank;

    for (final item in _banks) {
      if (item['code'] == code) {
        bank = item;
        break;
      }
    }

    setState(() {
      _selectedBankCode = code;
      _selectedBankName = bank?['name']?.toString();
      _clearResolution();
    });

    if (code != null && RegExp(r'^\d{10}$').hasMatch(_account.text.trim())) {
      _resolveAccount();
    }
  }

  Future<void> _resolveAccount() async {
    final account = _account.text.trim();
    final bankCode = _selectedBankCode;

    if (bankCode == null || !RegExp(r'^\d{10}$').hasMatch(account)) {
      return;
    }

    final sequence = ++_resolveSequence;

    setState(() {
      _resolving = true;
      _resolved = false;
      _resolveError = null;
      _accountName.clear();
    });

    try {
      final token = await _authToken();
      if (token == null || token.isEmpty) {
        throw Exception('Please sign in again.');
      }

      final response = await http
          .post(
            Uri.parse(ApiConfig.api('/api/transfer/resolve-account')),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'bankCode': bankCode, 'accountNumber': account}),
          )
          .timeout(const Duration(seconds: 30));

      final decoded = jsonDecode(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = decoded is Map ? decoded['message'] : null;
        throw Exception(
          message?.toString() ?? 'Could not verify this account.',
        );
      }

      Map<String, dynamic>? data;

      if (decoded is Map) {
        final candidate = decoded['data'] ?? decoded['responseBody'] ?? decoded;

        if (candidate is Map) {
          data = Map<String, dynamic>.from(candidate);
        }
      }

      final name =
          (data?['accountName'] ??
                  data?['account_name'] ??
                  data?['accountHolderName'] ??
                  '')
              .toString()
              .trim();

      if (name.isEmpty) {
        throw Exception('The bank did not return an account name.');
      }

      if (!mounted ||
          sequence != _resolveSequence ||
          account != _account.text.trim() ||
          bankCode != _selectedBankCode) {
        return;
      }

      setState(() {
        _accountName.text = name;
        _resolved = true;
        _resolving = false;
      });
    } catch (e) {
      if (!mounted || sequence != _resolveSequence) return;

      setState(() {
        _resolving = false;
        _resolved = false;
        _resolveError = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _save() {
    final amount = double.tryParse(_amount.text.trim().replaceAll(',', ''));

    if (_selectedBankCode == null ||
        _selectedBankName == null ||
        !_resolved ||
        _accountName.text.trim().isEmpty ||
        !RegExp(r'^\d{10}$').hasMatch(_account.text.trim()) ||
        amount == null ||
        !amount.isFinite ||
        amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Select a bank, verify the account, and enter a valid amount.',
          ),
        ),
      );
      return;
    }

    setState(() => _saving = true);

    Navigator.pop(
      context,
      BulkRecipient(
        name: _accountName.text.trim(),
        accountNumber: _account.text.trim(),
        bankCode: _selectedBankCode!,
        bankName: _selectedBankName!,
        amount: amount,
        narration: _narration.text.trim(),
      ),
    );
  }

  Future<void> _chooseBank() async {
    final selected = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        String query = '';

        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filtered = _banks
                .where(
                  (bank) => (bank['name'] as String).toLowerCase().contains(
                    query.trim().toLowerCase(),
                  ),
                )
                .toList();

            return AlertDialog(
              backgroundColor: Colors.black,
              surfaceTintColor: Colors.transparent,
              elevation: 24,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text('Choose a bank'),
              content: SizedBox(
                width: 420,
                height: 420,
                child: Column(
                  children: [
                    TextField(
                      autofocus: true,
                      onChanged: (value) => setDialogState(() => query = value),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search banks',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(child: Text('No matching banks'))
                          : ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final bank = filtered[index];

                                return ListTile(
                                  title: Text(bank['name'] as String),
                                  onTap: () =>
                                      Navigator.pop(dialogContext, bank),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );

    if (selected != null && mounted) {
      _onBankChanged(selected['code'] as String);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: Colors.black,
    surfaceTintColor: Colors.transparent,
    title: const Text('Add recipient'),
    content: SizedBox(
      width: 420,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_loadingBanks)
              const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(),
              )
            else if (_bankError != null)
              Column(
                children: [
                  Text(_bankError!, style: const TextStyle(color: Colors.red)),
                  TextButton(
                    onPressed: _loadBanks,
                    child: const Text('Retry loading banks'),
                  ),
                ],
              )
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: _chooseBank,
                  borderRadius: BorderRadius.circular(4),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Bank',
                      border: OutlineInputBorder(),
                      isDense: true,
                      suffixIcon: Icon(Icons.arrow_drop_down),
                    ),
                    child: Text(
                      _selectedBankName ?? 'Select or search for a bank',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _selectedBankName == null
                            ? Theme.of(context).hintColor
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextField(
                controller: _account,
                keyboardType: TextInputType.number,
                maxLength: 10,
                decoration: const InputDecoration(
                  labelText: '10-digit account number',
                  border: OutlineInputBorder(),
                  isDense: true,
                  counterText: '',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextField(
                controller: _accountName,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Verified account holder name',
                  border: const OutlineInputBorder(),
                  isDense: true,
                  suffixIcon: _resolving
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : _resolved
                      ? const Icon(Icons.verified, color: Colors.green)
                      : null,
                  helperText:
                      _resolveError ??
                      (_resolved
                          ? 'Account verified'
                          : 'Choose a bank and enter the account number to verify.'),
                  helperStyle: _resolveError == null
                      ? null
                      : const TextStyle(color: Colors.red),
                ),
              ),
            ),
            _field(
              _amount,
              'Amount (NGN)',
              keyboard: const TextInputType.numberWithOptions(decimal: true),
            ),
            _field(_narration, 'Narration (optional)'),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _saving || _loadingBanks || _resolving || !_resolved
            ? null
            : _save,
        child: const Text('Add recipient'),
      ),
    ],
  );

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType? keyboard,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    ),
  );
}

class _PinDialog extends StatefulWidget {
  final Future<void> Function(String) onSubmit;

  const _PinDialog({required this.onSubmit});

  @override
  State<_PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<_PinDialog> {
  final _pin = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _pin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Enter transaction PIN'),
    content: TextField(
      controller: _pin,
      keyboardType: TextInputType.number,
      obscureText: true,
      maxLength: 4,
      decoration: const InputDecoration(labelText: '4-digit PIN'),
    ),
    actions: [
      TextButton(
        onPressed: _busy ? null : () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _busy
            ? null
            : () async {
                if (!RegExp(r'^\d{4}$').hasMatch(_pin.text)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter your 4-digit PIN.')),
                  );
                  return;
                }

                setState(() => _busy = true);
                await widget.onSubmit(_pin.text);

                if (mounted) {
                  setState(() => _busy = false);
                }
              },
        child: _busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Submit'),
      ),
    ],
  );
}

class NumberFormatHelper {
  String format(double number) => number
      .toStringAsFixed(2)
      .replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+\.)'),
        (match) => '${match[1]},',
      );
}
