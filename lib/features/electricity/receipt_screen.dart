import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:utilityhub/config/api.dart';
import 'package:utilityhub/core/widgets/giftpay_background.dart';

class ReceiptScreen extends StatefulWidget {
  final String token;
  final String amount;
  final String customerName;
  final String customerAddress;
  final String meterNumber;
  final int timestamp;
  final String transactionReference;
  final String userId;
  final String units;

  const ReceiptScreen({
    super.key,
    required this.token,
    required this.amount,
    required this.customerName,
    required this.customerAddress,
    required this.meterNumber,
    required this.timestamp,
    this.transactionReference = "",
    this.userId = "",
    this.units = "",
  });

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  late String _token;
  late String _customerName;
  late String _address;
  late String _reference;
  late String _customerId;
  late String _units;
  late int _timestamp;

  bool _refreshing = false;
  bool _exporting = false;
  bool _loadingCustomerDetails = true;

  Timer? _retryTimer;
  Future<void>? _profileFuture;
  int _attempts = 0;

  @override
  void initState() {
    super.initState();

    _token = widget.token.trim();
    _customerName = '';
    _address = widget.customerAddress.trim();
    _reference = widget.transactionReference.trim();
    _customerId = '';
    _units = widget.units.trim();
    _timestamp = widget.timestamp;

    _profileFuture = _loadGiftPayCustomerDetails();

    if (_token.isEmpty || _address.isEmpty || _reference.isEmpty) {
      _refreshReceipt();

      _retryTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (_token.isEmpty && _attempts < 24) {
          _refreshReceipt();
        }
      });
    }
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  String get _userId {
    final explicit = widget.userId.trim();

    return explicit.isNotEmpty
        ? explicit
        : (FirebaseAuth.instance.currentUser?.uid ?? '');
  }

  Future<void> _loadGiftPayCustomerDetails() async {
    final uid = _userId;

    if (uid.isEmpty) {
      if (mounted) {
        setState(() {
          _loadingCustomerDetails = false;
        });
      }
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get()
          .timeout(const Duration(seconds: 8));

      if (!mounted) return;

      if (!snapshot.exists) {
        setState(() {
          _loadingCustomerDetails = false;
        });
        return;
      }

      final data = snapshot.data() ?? <String, dynamic>{};

      final verification = data['paystackBankVerification'];

      // Only trust the Paystack account name when verification
      // has a verifiedAt marker.
      final isPaystackNameVerified =
          verification is Map && verification['verifiedAt'] != null;

      final verifiedName = isPaystackNameVerified
          ? (verification['accountName'] ?? '').toString().trim()
          : '';

      // Registered name is the fallback.
      final firstName = (data['firstName'] ?? '').toString().trim();
      final lastName = (data['lastName'] ?? '').toString().trim();

      final registeredName = [
        firstName,
        lastName,
      ].where((part) => part.isNotEmpty).join(' ').trim();

      // Retrieve the actual dedicated virtual account ID.
      final virtualAccount = data['virtualAccount'];

      final virtualAccountMap = virtualAccount is Map
          ? virtualAccount
          : <String, dynamic>{};

      final virtualAccounts = data['virtualAccounts'];

      final virtualAccountsMap = virtualAccounts is Map
          ? virtualAccounts
          : <String, dynamic>{};

      final paystackAccount = virtualAccountsMap['paystack'];

      final paystackMap = paystackAccount is Map
          ? paystackAccount
          : <String, dynamic>{};

      final dedicatedId =
          virtualAccountMap['dedicatedAccountId'] ??
          paystackMap['dedicatedAccountId'] ??
          '';

      final customerId = dedicatedId.toString().trim();

      if (!mounted) return;

      setState(() {
        // Verified Paystack name takes priority.
        if (verifiedName.isNotEmpty) {
          _customerName = verifiedName;
        } else {
          _customerName = registeredName;
        }

        if (customerId.isNotEmpty) {
          _customerId = customerId;
        }

        _loadingCustomerDetails = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingCustomerDetails = false;
        });
      }
    }
  }

  Future<void> _refreshReceipt() async {
    if (_refreshing || _reference.isEmpty || _userId.isEmpty) {
      return;
    }

    _refreshing = true;
    _attempts++;

    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.api('/api/electricity/requery')),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'requestId': _reference, 'userId': _userId}),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map && decoded['status'] == true && mounted) {
          final raw = decoded['raw'];

          final rawMap = raw is Map ? raw : <String, dynamic>{};

          final nested = rawMap['responseBody'] is Map
              ? rawMap['responseBody'] as Map
              : rawMap;

          final token =
              (decoded['token'] ??
                      nested['metertoken'] ??
                      nested['MeterToken'] ??
                      nested['meterToken'] ??
                      nested['token'] ??
                      '')
                  .toString()
                  .trim();

          final address =
              (decoded['customerAddress'] ??
                      decoded['address'] ??
                      nested['customer_address'] ??
                      nested['customerAddress'] ??
                      '')
                  .toString()
                  .trim();

          setState(() {
            if (token.isNotEmpty) {
              _token = token;
            }

            if (address.isNotEmpty) {
              _address = address;
            }

            if ((decoded['units'] ?? '').toString().trim().isNotEmpty) {
              _units = decoded['units'].toString();
            }
          });

          if (token.isNotEmpty) {
            _retryTimer?.cancel();
          }
        }
      }
    } catch (_) {
      // Keep the locally available receipt visible.
      // Continue retrying while the token is pending.
    } finally {
      _refreshing = false;
    }
  }

  String _formatAmount() {
    final value = num.tryParse(widget.amount.replaceAll(',', ''));

    return value == null ? '₦${widget.amount}' : '₦${value.toStringAsFixed(2)}';
  }

  String _formatDate() {
    if (_timestamp <= 0) return 'Unknown';

    final date = DateTime.fromMillisecondsSinceEpoch(_timestamp);

    String two(int n) => n.toString().padLeft(2, '0');

    return '${two(date.day)}/${two(date.month)}/${date.year} '
        '${two(date.hour)}:${two(date.minute)}';
  }

  Future<Uint8List> _buildPdf() async {
    final pdf = pw.Document();

    final date = _formatDate();

    final qr =
        'GiftPay Electricity|Ref:$_reference|Meter:${widget.meterNumber}|Token:$_token|Amount:${widget.amount}';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'GiftPay',
                  style: pw.TextStyle(
                    fontSize: 25,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
                pw.Text(
                  'ELECTRICITY RECEIPT',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Digital Utility Services',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
            pw.Divider(),
            pw.SizedBox(height: 12),
            pw.Text(
              'Transaction details',
              style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 12),
            _pdfRow(
              'Customer Name',
              _customerName.isEmpty ? 'Not available' : _customerName,
            ),
            _pdfRow(
              'Transaction Reference',
              _reference.isEmpty ? 'Unavailable' : _reference,
            ),
            _pdfRow(
              'Customer ID',
              _customerId.isEmpty ? 'Unavailable' : _customerId,
            ),
            _pdfRow('Meter Number', widget.meterNumber),
            _pdfRow(
              'Meter Address',
              _address.isEmpty ? 'Not available' : _address,
            ),
            _pdfRow('Amount', _formatAmount()),
            _pdfRow('Units', _units.isEmpty ? '—' : '$_units kWh'),
            _pdfRow('Status', _token.isEmpty ? 'PROCESSING' : 'SUCCESSFUL'),
            _pdfRow('Date', date),
            pw.SizedBox(height: 20),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(18),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Electricity Token',
                    style: const pw.TextStyle(
                      fontSize: 11,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    _token.isEmpty ? 'Token is still being processed' : _token,
                    style: pw.TextStyle(
                      fontSize: 19,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: qr,
                  width: 76,
                  height: 76,
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Powered by Gift Technology Limited',
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Text(
                      'www.gifttechnologyltd.com',
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.blue800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  pw.Widget _pdfRow(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 8),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 145,
          child: pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
        ),
      ],
    ),
  );

  Future<void> _exportPdf() async {
    if (_exporting) return;

    setState(() {
      _exporting = true;
    });

    try {
      // Wait for the same customer identity used by the screen.
      await _profileFuture;

      // Refresh once before exporting.
      await _refreshReceipt();

      final bytes = await _buildPdf();

      if (kIsWeb) {
        await Printing.layoutPdf(
          name:
              'GiftPay_Electricity_Receipt_${_reference.isEmpty ? 'receipt' : _reference}.pdf',
          onLayout: (_) async => bytes,
        );
      } else {
        await Printing.sharePdf(
          bytes: bytes,
          filename: 'GiftPay_Electricity_Receipt.pdf',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to create receipt PDF: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _exporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedToken = _token.isEmpty ? '' : _token;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Electricity Receipt'),
        backgroundColor: Colors.transparent,
      ),
      body: GiftPayBackground(
        child: Center(
          child: Container(
            width: 520,
            constraints: const BoxConstraints(maxWidth: 520),
            margin: const EdgeInsets.all(18),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(.18)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.receipt_long,
                    size: 66,
                    color: Color(0xFF4FC3F7),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Electricity Receipt',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _token.isEmpty
                        ? 'Your payment is being confirmed. Your receipt will update when the token is available.'
                        : 'Your electricity purchase was completed successfully.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        _detail(
                          'Customer Name',
                          _loadingCustomerDetails
                              ? 'Loading...'
                              : _customerName.isEmpty
                              ? 'Not available'
                              : _customerName,
                        ),
                        _detail(
                          'Transaction Reference',
                          _reference.isEmpty ? '—' : _reference,
                        ),
                        _detail(
                          'Customer ID',
                          _customerId.isEmpty ? 'Loading…' : _customerId,
                        ),
                        _detail('Meter Number', widget.meterNumber),
                        _detail(
                          'Meter Address',
                          _address.isEmpty ? 'Retrieving address…' : _address,
                        ),
                        _detail('Amount', _formatAmount()),
                        if (_units.isNotEmpty) _detail('Units', '$_units kWh'),
                        _detail('Date', _formatDate()),
                        _detail(
                          'Status',
                          _token.isEmpty ? 'PROCESSING' : 'SUCCESSFUL',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Electricity Token',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (formattedToken.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        color: Color(0xFF4FC3F7),
                      ),
                    )
                  else
                    SelectableText(
                      formattedToken,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.4,
                        color: Colors.white,
                      ),
                    ),
                  if (_token.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    BarcodeWidget(
                      barcode: Barcode.qrCode(),
                      data:
                          'Ref:$_reference|Token:$_token|Meter:${widget.meterNumber}|Amount:${widget.amount}',
                      width: 130,
                      height: 130,
                      color: Colors.white,
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _exporting ? null : _exportPdf,
                      icon: _exporting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(kIsWeb ? Icons.download : Icons.share),
                      label: Text(
                        _exporting
                            ? 'Preparing receipt…'
                            : kIsWeb
                            ? 'Download PDF Receipt'
                            : 'Share PDF Receipt',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Close',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _detail(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 145,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            softWrap: true,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
