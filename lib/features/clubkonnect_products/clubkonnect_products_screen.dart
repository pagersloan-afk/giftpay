import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:utilityhub/config/api.dart';
import 'package:utilityhub/core/widgets/app_responsive_layout.dart';
import 'package:utilityhub/features/wallet/transfer/wigets/pin_entry_dialog.dart';

class ClubKonnectProductsScreen extends StatefulWidget {
  final String initialProduct;
  final List<String> allowedProducts;
  final String screenTitle;

  const ClubKonnectProductsScreen({
    super.key,
    this.initialProduct = 'airtime-pin',
    this.allowedProducts = const ['airtime-pin', 'data-pin', 'smile', 'waec', 'jamb'],
    this.screenTitle = 'Services',
  });

  @override
  State<ClubKonnectProductsScreen> createState() =>
      _ClubKonnectProductsScreenState();
}

class _ClubKonnectProductsScreenState extends State<ClubKonnectProductsScreen> {
  static const _products = <String, String>{
    'airtime-pin': 'Recharge Card Printing — Airtime',
    'data-pin': 'Recharge Card Printing — Data',
    'smile': 'Smile Data Bundle',
    'waec': 'WAEC e-PIN',
    'jamb': 'JAMB e-PIN',
  };

  final _recipientCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController(text: '1');
  final _profileCtrl = TextEditingController();
  late String _product;
  String _network = '';
  String _value = '100';
  String _planCode = '';
  List<Map<String, dynamic>> _airtimeNetworks = [];
  List<Map<String, dynamic>> _dataNetworks = [];
  List<Map<String, dynamic>> _packages = [];
  List<Map<String, dynamic>> _dataPlans = [];
  bool _loading = true;
  bool _loadingPlans = false;
  bool _submitting = false;
  String? _pendingReference;
  String? _verifiedName;

  Uri _uri(String path) => Uri.parse(ApiConfig.api(path));

  Future<String> _token() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Please sign in again.');
    final token = await user.getIdToken();
    if (token == null || token.isEmpty) throw Exception('Please sign in again.');
    return token;
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final token = await _token();
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    final response = method == 'GET'
        ? await http.get(_uri(path), headers: headers).timeout(
            const Duration(seconds: 30),
          )
        : await http.post(
            _uri(path),
            headers: headers,
            body: jsonEncode(body ?? {}),
          ).timeout(const Duration(seconds: 45));
    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      throw Exception('The server returned an invalid response. Please try again.');
    }
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected server response.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300 ||
        decoded['status'] != true) {
      throw Exception(
        decoded['message']?.toString() ?? 'The request could not be completed.',
      );
    }
    return decoded;
  }

  List<Map<String, dynamic>> _mapList(dynamic value) {
    if (value is! List) return [];
    return value.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  @override
  void initState() {
    super.initState();
    _product = widget.allowedProducts.contains(widget.initialProduct)
        ? widget.initialProduct
        : widget.allowedProducts.first;
    _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    setState(() => _loading = true);
    try {
      final result = await _request('GET', '/api/clubkonnect-products/catalog');
      final catalog = Map<String, dynamic>.from(result['catalog'] ?? {});
      _airtimeNetworks = _mapList(catalog['airtimeNetworks']);
      _dataNetworks = _mapList(catalog['dataNetworks']);
      _packages = _packagesFor(_product, catalog);
      if (_network.isEmpty) {
        final networks = _product == 'airtime-pin' ? _airtimeNetworks : _dataNetworks;
        if (networks.isNotEmpty) _network = networks.first['code'].toString();
      }
      if (_product == 'data-pin' && _network.isNotEmpty) await _loadDataPlans();
    } catch (error) {
      _showMessage(_cleanError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> _packagesFor(
    String product,
    Map<String, dynamic> catalog,
  ) {
    switch (product) {
      case 'smile':
        return _mapList(catalog['smilePackages']);
      case 'waec':
        return _mapList(catalog['waecPackages']);
      case 'jamb':
        return _mapList(catalog['jambPackages']);
      default:
        return [];
    }
  }

  Future<void> _loadDataPlans() async {
    if (_network.isEmpty) return;
    setState(() {
      _loadingPlans = true;
      _dataPlans = [];
      _planCode = '';
    });
    try {
      final result = await _request(
        'GET',
        '/api/clubkonnect-products/data-pin-plans/${Uri.encodeComponent(_network)}',
      );
      _dataPlans = _mapList(result['plans']);
      if (_dataPlans.isNotEmpty) _planCode = _dataPlans.first['code'].toString();
    } catch (error) {
      _showMessage(_cleanError(error));
    } finally {
      if (mounted) setState(() => _loadingPlans = false);
    }
  }

  Future<void> _changeProduct(String? value) async {
    if (value == null) return;
    if (value == 'smile' || value == 'waec' || value == 'jamb') _quantityCtrl.text = '1';
    setState(() {
      _product = value;
      _network = '';
      _planCode = '';
      _verifiedName = null;
      _packages = [];
      _dataPlans = [];
    });
    try {
      final result = await _request('GET', '/api/clubkonnect-products/catalog');
      final catalog = Map<String, dynamic>.from(result['catalog'] ?? {});
      _packages = _packagesFor(value, catalog);
      if (value == 'airtime-pin' || value == 'data-pin') {
        final networks = value == 'airtime-pin' ? _airtimeNetworks : _dataNetworks;
        if (networks.isNotEmpty) _network = networks.first['code'].toString();
      }
      if (value == 'data-pin') await _loadDataPlans();
      if (mounted) setState(() {});
    } catch (error) {
      _showMessage(_cleanError(error));
    }
  }

  Future<void> _verifyAccount() async {
    try {
      final account = _recipientCtrl.text.trim();
      final result = await _request(
        'POST',
        _product == 'smile'
            ? '/api/clubkonnect-products/verify-smile'
            : '/api/clubkonnect-products/verify-jamb',
        body: _product == 'smile'
            ? {'account': account}
            : {'examType': _planCode, 'profileId': _profileCtrl.text.trim()},
      );
      setState(() => _verifiedName = result['customerName']?.toString());
      _showMessage('Verified: ${_verifiedName ?? 'Account confirmed'}');
    } catch (error) {
      _showMessage(_cleanError(error));
    }
  }

  Future<void> _purchase() async {
    if (_submitting) return;
    final quantity = int.tryParse(_quantityCtrl.text.trim()) ?? 0;
    if (quantity < 1 || quantity > 100) {
      _showMessage('Quantity must be between 1 and 100.');
      return;
    }
    if ((_product == 'airtime-pin' || _product == 'data-pin') && _network.isEmpty) {
      _showMessage('Select a mobile network.');
      return;
    }
    if (_product == 'data-pin' && _planCode.isEmpty) {
      _showMessage('Select a data PIN plan.');
      return;
    }
    if (_product == 'smile' && _recipientCtrl.text.trim().isEmpty) {
      _showMessage('Enter your Smile account number.');
      return;
    }
    if ((_product == 'waec' || _product == 'jamb') &&
        (_recipientCtrl.text.trim().isEmpty || _planCode.isEmpty)) {
      _showMessage('Select an exam package and enter the recipient phone number.');
      return;
    }
    String pin = '';
    final pinResult = await showDialog<PinVerificationResult>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PinEntryDialog(
        onCompleted: (value) async {
          pin = value;
          return const PinVerificationResult(status: PinVerificationStatus.success);
        },
        onChangeMethod: () {},
      ),
    );
    if (!mounted || pinResult == null || !pinResult.isSuccess ||
        !RegExp(r'^\d{4}$').hasMatch(pin)) return;

    setState(() => _submitting = true);
    try {
      final body = <String, dynamic>{
        'product': _product,
        'quantity': quantity,
        'transactionPin': pin,
      };
      if (_product == 'airtime-pin') {
        body.addAll({'network': _network, 'value': int.parse(_value)});
      } else if (_product == 'data-pin') {
        body.addAll({'network': _network, 'planCode': _planCode});
      } else {
        body.addAll({'planCode': _planCode, 'recipient': _recipientCtrl.text.trim()});
        if (_product == 'jamb' && _profileCtrl.text.trim().isNotEmpty) {
          body['profileId'] = _profileCtrl.text.trim();
        }
      }
      final result = await _request('POST', '/api/clubkonnect-products/purchase', body: body);
      final reference = result['reference']?.toString();
      if (result['pending'] == true) {
        setState(() => _pendingReference = reference);
        _showMessage('Purchase is pending confirmation. Reference: $reference');
      } else {
        _showDelivery(result['delivery'], reference);
      }
    } catch (error) {
      _showMessage(_cleanError(error));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _checkPending() async {
    final reference = _pendingReference;
    if (reference == null) return;
    setState(() => _submitting = true);
    try {
      final result = await _request(
        'GET',
        '/api/clubkonnect-products/requery/${Uri.encodeComponent(reference)}',
      );
      final status = result['transactionStatus']?.toString();
      if (status == 'SUCCESS') {
        setState(() => _pendingReference = null);
        _showDelivery(result['delivery'], reference);
      } else if (status == 'FAILED') {
        setState(() => _pendingReference = null);
        _showMessage('The purchase failed. Your wallet refund has been processed.');
      } else {
        _showMessage('Still pending. Your wallet debit remains held safely while the provider processes the order.');
      }
    } catch (error) {
      _showMessage(_cleanError(error));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showDelivery(dynamic delivery, String? reference) {
    final map = delivery is Map ? Map<String, dynamic>.from(delivery) : <String, dynamic>{};
    final pins = map['pins'];
    final cardDetails = map['cardDetails'];
    final content = pins is List && pins.isNotEmpty
        ? const JsonEncoder.withIndent('  ').convert(pins)
        : (cardDetails?.toString() ?? 'Your purchase was completed successfully.');
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Purchase successful'),
        content: SingleChildScrollView(
          child: SelectableText('$content\n\nReference: ${reference ?? '—'}'),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done'))],
      ),
    );
  }

  String _cleanError(Object error) => error.toString().replaceFirst('Exception: ', '');

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _recipientCtrl.dispose();
    _quantityCtrl.dispose();
    _profileCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNetworkProduct = _product == 'airtime-pin' || _product == 'data-pin';
    final networks = _product == 'airtime-pin' ? _airtimeNetworks : _dataNetworks;
    final plans = _product == 'data-pin' ? _dataPlans : _packages;
    return AppResponsiveLayout(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Text(widget.screenTitle), backgroundColor: Colors.transparent),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(
                        _product == 'waec' || _product == 'jamb'
                            ? 'Purchase examination e-PINs securely using your GiftPay wallet.'
                            : _product == 'smile'
                                ? 'Choose a Smile data bundle and fund your Smile account using your GiftPay wallet.'
                                : 'Print airtime and data recharge cards using your GiftPay wallet.',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 20),
                      if (widget.allowedProducts.length > 1) ...[
                        _fieldLabel('Product'),
                        DropdownButtonFormField<String>(
                          value: _product,
                          dropdownColor: const Color(0xFF1C2433),
                          decoration: _decoration('Choose a product'),
                          items: widget.allowedProducts
                              .where(_products.containsKey)
                              .map((key) => DropdownMenuItem(
                                    value: key,
                                    child: Text(_products[key]!),
                                  ))
                              .toList(),
                          onChanged: _submitting ? null : _changeProduct,
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (isNetworkProduct) ...[
                        _fieldLabel('Mobile network'),
                        DropdownButtonFormField<String>(
                          value: networks.any((e) => e['code'].toString() == _network) ? _network : null,
                          dropdownColor: const Color(0xFF1C2433),
                          decoration: _decoration('Select network'),
                          items: networks.map((e) => DropdownMenuItem(value: e['code'].toString(), child: Text(e['name'].toString()))).toList(),
                          onChanged: _submitting ? null : (value) async {
                            if (value == null) return;
                            setState(() => _network = value);
                            if (_product == 'data-pin') await _loadDataPlans();
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (_product == 'airtime-pin') ...[
                        _fieldLabel('Recharge card value'),
                        DropdownButtonFormField<String>(
                          value: _value,
                          dropdownColor: const Color(0xFF1C2433),
                          decoration: _decoration('Select value'),
                          items: [100, 200, 500].map((v) => DropdownMenuItem(value: '$v', child: Text('₦$v'))).toList(),
                          onChanged: _submitting ? null : (v) => setState(() => _value = v ?? '100'),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (_product == 'data-pin' || _product == 'smile' || _product == 'waec' || _product == 'jamb') ...[
                        _fieldLabel(_product == 'waec' || _product == 'jamb' ? 'Exam package' : 'Package'),
                        if (_loadingPlans)
                          const LinearProgressIndicator()
                        else
                          DropdownButtonFormField<String>(
                            value: plans.any((e) => e['code'].toString() == _planCode) ? _planCode : null,
                            dropdownColor: const Color(0xFF1C2433),
                            decoration: _decoration('Select package'),
                            items: plans.map((e) => DropdownMenuItem(
                              value: e['code'].toString(),
                              child: Text('${e['name']} — ₦${e['amount']}'),
                            )).toList(),
                            onChanged: _submitting ? null : (v) => setState(() => _planCode = v ?? ''),
                          ),
                        const SizedBox(height: 16),
                      ],
                      if (_product == 'smile' || _product == 'waec' || _product == 'jamb') ...[
                        _fieldLabel(_product == 'smile' ? 'Smile account number' : 'Recipient phone number'),
                        TextField(controller: _recipientCtrl, keyboardType: _product == 'smile' ? TextInputType.text : TextInputType.phone, style: const TextStyle(color: Colors.white), decoration: _decoration(_product == 'smile' ? 'Enter Smile account number' : 'Enter phone number')),
                        if (_product == 'jamb') ...[
                          const SizedBox(height: 12),
                          _fieldLabel('JAMB profile ID (optional verification)'),
                          TextField(controller: _profileCtrl, style: const TextStyle(color: Colors.white), decoration: _decoration('Enter JAMB profile ID')),
                        ],
                        if (_verifiedName != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text('Verified: $_verifiedName', style: const TextStyle(color: Colors.greenAccent))),
                        if (_product == 'smile' || _product == 'jamb') Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(onPressed: _submitting ? null : _verifyAccount, child: Text(_product == 'smile' ? 'Verify Smile account' : 'Verify JAMB profile')),
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (_product == 'airtime-pin' || _product == 'data-pin') ...[
                        _fieldLabel('Quantity'),
                        TextField(controller: _quantityCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: _decoration('1–100')),
                        const SizedBox(height: 22),
                      ],
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _submitting ? null : _purchase,
                          child: _submitting ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Continue to payment'),
                        ),
                      ),
                      if (_pendingReference != null) ...[
                        const SizedBox(height: 14),
                        OutlinedButton.icon(
                          onPressed: _submitting ? null : _checkPending,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Check pending transaction'),
                        ),
                        SelectableText('Reference: $_pendingReference', style: const TextStyle(color: Colors.white70)),
                      ],
                      const SizedBox(height: 16),
                      const Text('Your transaction PIN is verified securely by GiftPay before your wallet is debited. If the provider response is delayed, the transaction remains pending until confirmed; failed purchases are refunded automatically.', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
  );

  InputDecoration _decoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.white38),
    filled: true,
    fillColor: const Color(0xFF111827),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF38BDF8))),
  );
}
