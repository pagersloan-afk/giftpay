import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'bookkeeping_report_file_stub.dart'
    if (dart.library.html) 'bookkeeping_report_file_web.dart'
    if (dart.library.io) 'bookkeeping_report_file_io.dart' as report_file;
import 'package:utilityhub/core/widgets/app_responsive_layout.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';
import 'package:utilityhub/features/bookkeeping/models/bookkeeping_entry.dart';
import 'package:utilityhub/features/bookkeeping/services/bookkeeping_api_service.dart';
import 'bookkeeping_planning_section.dart';

class BookkeepingScreen extends StatefulWidget {
  const BookkeepingScreen({super.key});

  @override
  State<BookkeepingScreen> createState() => _BookkeepingScreenState();
}

class _BookkeepingScreenState extends State<BookkeepingScreen> {
  static const Color _surface = Color(0xFF101827);
  static const Color _line = Color(0x24FFFFFF);
  static const Color _muted = Color(0xFF9CA8B8);
  static const Color _cyan = Color(0xFF4FC3F7);
  static const Color _green = Color(0xFF4ADE80);
  static const Color _red = Color(0xFFF87171);

  final BookkeepingApiService _service = BookkeepingApiService();
  bool _loading = true;
  bool _saving = false;
  bool _settingsConfigured = false;
  String? _error;
  Map<String, dynamic> _summary = {};
  Map<String, dynamic> _dailySummary = {};
  List<BookkeepingEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  int _asInt(dynamic value) =>
      value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;

  Future<void> _loadDashboard() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _service.getDashboard(date: _dateKey(DateTime.now()));
      final summary = data['summary'] is Map
          ? Map<String, dynamic>.from(data['summary'] as Map)
          : <String, dynamic>{};
      final dailySummary = data['dailySummary'] is Map
          ? Map<String, dynamic>.from(data['dailySummary'] as Map)
          : <String, dynamic>{};
      final rawEntries = data['entries'] is List ? data['entries'] as List : [];
      if (!mounted) return;
      setState(() {
        _summary = summary;
        _dailySummary = dailySummary;
        _settingsConfigured = data['settingsConfigured'] == true;
        _entries = rawEntries
            .whereType<Map>()
            .map(
              (item) =>
                  BookkeepingEntry.fromMap(Map<String, dynamic>.from(item)),
            )
            .toList();
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = _friendlyError(error);
        _loading = false;
      });
    }
  }


  Future<void> _exportBookkeepingReport({required bool pdfFormat}) async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5, 12, 31),
      initialDateRange: DateTimeRange(
        start: DateTime(now.year, now.month, 1),
        end: DateTime(now.year, now.month, now.day),
      ),
      helpText: 'Choose statement period',
      saveText: 'GENERATE',
      builder: (pickerContext, child) {
        final base = Theme.of(pickerContext);
        return Theme(
          data: base.copyWith(
            dialogTheme: base.dialogTheme.copyWith(
              backgroundColor: const Color(0xFF101827),
              surfaceTintColor: Colors.transparent,
            ),
            datePickerTheme: base.datePickerTheme.copyWith(
              backgroundColor: const Color(0xFF101827),
              surfaceTintColor: Colors.transparent,
              headerBackgroundColor: const Color(0xFF172235),
              headerForegroundColor: Colors.white,
              rangePickerBackgroundColor: const Color(0xFF101827),
              rangePickerHeaderBackgroundColor: const Color(0xFF172235),
              rangePickerHeaderForegroundColor: Colors.white,
              dayForegroundColor: const WidgetStatePropertyAll(Colors.white),
              yearForegroundColor: const WidgetStatePropertyAll(Colors.white),
            ),
            colorScheme: base.colorScheme.copyWith(
              surface: const Color(0xFF101827),
              onSurface: Colors.white,
              primary: const Color(0xFF4FC3F7),
            ),
          ),
          child: child!,
        );
      },
    );
    if (range == null || !mounted) return;

    final from = _dateKey(range.start);
    final to = _dateKey(range.end);
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Preparing your bookkeeping report...')),
    );

    try {
      final report = await _service.getReport(from: from, to: to);
      final raw = report['entries'] is List ? report['entries'] as List : [];
      final rows = raw.whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item)).toList();
      final dateLabel = '${DateFormat('dd MMM yyyy').format(range.start)}_to_${DateFormat('dd MMM yyyy').format(range.end)}';

      if (pdfFormat) {
        final document = pw.Document();
        final amountFormatter = NumberFormat('#,##0.00', 'en_NG');
        String formatAmount(num value) => amountFormatter.format(value);
        String naira(dynamic value) =>
            'NGN ${formatAmount(_asInt(value) / 100)}';
        document.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(32),
            build: (context) => [
              pw.Text('GiftPay Bookkeeping Statement',
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              pw.Text('$from to $to', style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 18),
              pw.Text('Cashbook summary',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Table.fromTextArray(
                headers: ['Description', 'Amount'],
                data: [
                  ['Opening cash balance', naira(report['openingCashKobo'])],
                  ['Income', naira(report['incomeKobo'])],
                  ['Expenses', naira(report['expenseKobo'])],
                  ['Savings contributions', naira(report['savingsDepositsKobo'])],
                  ['Savings withdrawals', naira(report['savingsWithdrawalsKobo'])],
                  ['Closing cash balance', naira(report['closingCashKobo'])],
                  ['Opening savings', naira(report['openingSavingsKobo'])],
                  ['Closing savings', naira(report['closingSavingsKobo'])],
                ],
              ),
              pw.SizedBox(height: 18),
              pw.Text('Transaction details',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              if (rows.isEmpty)
                pw.Text('No transactions were recorded during this period.')
              else
                pw.Table.fromTextArray(
                  headers: ['Date', 'Description', 'Type', 'Category', 'Credit (NGN)', 'Debit (NGN)', 'Cash balance (NGN)'],
                  headerStyle: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
                  cellStyle: const pw.TextStyle(fontSize: 7),
                  data: rows.map((entry) {
                    final type = entry['type']?.toString() ?? '';
                    final amount = _asInt(entry['amountKobo']) / 100;
                    final credit = type == 'income' || type == 'savings_withdrawal';
                    final debit = type == 'expense' || type == 'savings_deposit';
                    return [
                      entry['entryDate']?.toString() ?? '',
                      entry['description']?.toString() ?? '',
                      _typeLabel(type),
                      entry['category']?.toString() ?? '',
                      credit ? formatAmount(amount) : '-',
                      debit ? formatAmount(amount) : '-',
                      formatAmount(_asInt(entry['cashBalanceAfterKobo']) / 100),
                    ];
                  }).toList(),
                ),
              pw.SizedBox(height: 12),
              pw.Text('This report is based on records entered in GiftPay Smart Bookkeeping. It is not a bank statement.',
                  style: const pw.TextStyle(fontSize: 8)),
            ],
          ),
        );
        final bytes = await document.save();
        await report_file.saveReportFile(
          bytes,
          'GiftPay_Bookkeeping_$dateLabel.pdf',
          'application/pdf',
        );
        if (!mounted) return;
        await Printing.layoutPdf(
          onLayout: (_) async => bytes,
          name: 'GiftPay_Bookkeeping_$dateLabel.pdf',
        );
      } else {
        String csvCell(dynamic value) {
          final text = value?.toString() ?? '';
          return '"${text.replaceAll('"', '""')}"';
        }
        final buffer = StringBuffer();
        buffer.writeln(['Date', 'Description', 'Type', 'Category', 'Notes', 'Amount (NGN)', 'Credit (NGN)', 'Debit (NGN)', 'Cash balance (NGN)', 'Savings balance (NGN)'].map(csvCell).join(','));
        for (final entry in rows) {
          final type = entry['type']?.toString() ?? '';
          final amount = _asInt(entry['amountKobo']) / 100;
          final credit = type == 'income' || type == 'savings_withdrawal';
          final debit = type == 'expense' || type == 'savings_deposit';
          buffer.writeln([
            entry['entryDate'], entry['description'], _typeLabel(type),
            entry['category'], entry['notes'], amount.toStringAsFixed(2),
            credit ? amount.toStringAsFixed(2) : '',
            debit ? amount.toStringAsFixed(2) : '',
            (_asInt(entry['cashBalanceAfterKobo']) / 100).toStringAsFixed(2),
            (_asInt(entry['savingsBalanceAfterKobo']) / 100).toStringAsFixed(2),
          ].map(csvCell).join(','));
        }
        await report_file.saveReportFile(
          utf8.encode(buffer.toString()),
          'GiftPay_Bookkeeping_$dateLabel.csv',
          'text/csv;charset=utf-8',
        );
      }
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(_friendlyError(error))));
    }
  }

  Widget _reportsCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _line),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(children: [
          Icon(Icons.description_outlined, color: _cyan),
          SizedBox(width: 9),
          Text('Reports & statements', style: TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 7),
        const Text(
          'Create a dated cashbook statement with opening and closing balances, income, expenses, savings activity and transaction details.',
          style: TextStyle(color: _muted, height: 1.4, fontSize: 12),
        ),
        const SizedBox(height: 14),
        Wrap(spacing: 10, runSpacing: 10, children: [
          OutlinedButton.icon(
            onPressed: _saving ? null : () => _exportBookkeepingReport(pdfFormat: true),
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Text('PDF / Print'),
          ),
          OutlinedButton.icon(
            onPressed: _saving ? null : () => _exportBookkeepingReport(pdfFormat: false),
            icon: const Icon(Icons.table_view_outlined),
            label: const Text('Excel / CSV'),
          ),
        ]),
      ],
    ),
  );

  String _friendlyError(Object error) =>
      error.toString().replaceFirst('Exception: ', '').trim();

  String _money(int kobo) {
    final negative = kobo < 0;
    final absolute = kobo.abs();
    final naira = absolute ~/ 100;
    final fraction = (absolute % 100).toString().padLeft(2, '0');
    final digits = naira.toString();
    final grouped = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) grouped.write(',');
      grouped.write(digits[i]);
    }
    return '${negative ? '-' : ''}₦$grouped.$fraction';
  }

  int? _parseKobo(String value) {
    final cleaned = value.replaceAll(',', '').replaceAll('₦', '').trim();
    if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(cleaned)) return null;
    final parts = cleaned.split('.');
    final naira = int.tryParse(parts[0]);
    if (naira == null) return null;
    final kobo = parts.length == 1 ? 0 : int.parse(parts[1].padRight(2, '0'));
    final total = naira * 100 + kobo;
    return total > 0 ? total : null;
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'income':
        return 'Income';
      case 'expense':
        return 'Expense';
      case 'savings_deposit':
        return 'Savings deposit';
      case 'savings_withdrawal':
        return 'Savings withdrawal';
      default:
        return 'Transaction';
    }
  }

  Future<void> _showOpeningBalanceDialog() async {
    final cashController = TextEditingController(
      text: _settingsConfigured
          ? (_asInt(_summary['openingCashKobo']) / 100).toStringAsFixed(2)
          : '',
    );
    final savingsController = TextEditingController(
      text: _settingsConfigured
          ? (_asInt(_summary['openingSavingsKobo']) / 100).toStringAsFixed(2)
          : '',
    );
    final formKey = GlobalKey<FormState>();

    // Capture this while the screen is active, before opening the dialog.
    final messenger = ScaffoldMessenger.of(context);

    try {
      final shouldSave = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: const Color(0xFF111827),
          title: Text(
            _settingsConfigured
                ? 'Edit opening balances'
                : 'Set up your cashbook',
            style: const TextStyle(color: Colors.white),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Enter the money you already have before recording your first transaction. You can start from zero if you are beginning today.',
                  style: TextStyle(color: _muted, height: 1.45),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: cashController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Opening cash / bank balance (₦)',
                  ),
                  validator: (value) {
                    final text = (value ?? '').trim();
                    return text.isEmpty ||
                            text == '0' ||
                            _parseKobo(text) != null
                        ? null
                        : 'Enter a valid amount or 0';
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: savingsController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Existing savings balance (₦)',
                  ),
                  validator: (value) {
                    final text = (value ?? '').trim();
                    return text.isEmpty ||
                            text == '0' ||
                            _parseKobo(text) != null
                        ? null
                        : 'Enter a valid amount or 0';
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;

                // Only close the dialog here. Do not save inside this callback.
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Save and continue'),
            ),
          ],
        ),
      );

      if (shouldSave != true || !mounted) return;

      final cashText = cashController.text.trim();
      final savingsText = savingsController.text.trim();

      final cash = cashText.isEmpty || cashText == '0'
          ? 0
          : _parseKobo(cashText)!;

      final savings = savingsText.isEmpty || savingsText == '0'
          ? 0
          : _parseKobo(savingsText)!;

      // Save only after the dialog has closed.
      await _saveOpeningBalances(cash, savings, messenger: messenger);
    } finally {
      // Keep controllers alive until the save flow has finished.
      cashController.dispose();
      savingsController.dispose();
    }
  }

  Future<void> _saveOpeningBalances(
    int cash,
    int savings, {
    required ScaffoldMessengerState messenger,
  }) async {
    if (!mounted) return;

    setState(() => _saving = true);

    try {
      await _service.setOpeningBalances(
        openingCashKobo: cash,
        openingSavingsKobo: savings,
      );

      if (!mounted) return;

      messenger.showSnackBar(
        const SnackBar(content: Text('Your cashbook is ready.')),
      );

      await _loadDashboard();
    } catch (error) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(_friendlyError(error))));
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _resetBookkeeping() async {
    final confirmationController = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF111827),
        title: const Text(
          'Reset bookkeeping?',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This will clear your current opening balances and remove all transactions from your active cashbook. You will start again with a fresh cashbook.',
              style: TextStyle(color: _muted, height: 1.45),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your old bookkeeping entries are retained as inactive audit records. Your GiftPay wallet, wallet balance and actual financial transactions will not be affected.',
              style: TextStyle(color: _muted, height: 1.45),
            ),
            const SizedBox(height: 16),
            const Text(
              'Type RESET to confirm.',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: confirmationController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(hintText: 'RESET'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _red),
            onPressed: () => Navigator.of(
              dialogContext,
            ).pop(confirmationController.text.trim() == 'RESET'),
            child: const Text('Reset bookkeeping'),
          ),
        ],
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 250));
    confirmationController.dispose();

    if (confirmed != true || !mounted) return;

    setState(() => _saving = true);
    try {
      await _service.resetBookkeeping();
      if (!mounted) return;
      setState(() {
        _summary = {};
        _dailySummary = {};
        _entries = [];
        _settingsConfigured = false;
      });
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Bookkeeping reset. Enter your new opening balances to begin again.',
          ),
        ),
      );
      await _loadDashboard();
    } catch (error) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(_friendlyError(error))));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _showEntryDialog({BookkeepingEntry? existing}) async {
    final descriptionController = TextEditingController(
      text: existing?.description ?? '',
    );
    final amountController = TextEditingController(
      text: existing == null
          ? ''
          : '${existing.amountKobo ~/ 100}.${(existing.amountKobo % 100).toString().padLeft(2, '0')}',
    );
    final categoryController = TextEditingController(
      text: existing?.category ?? '',
    );
    final notesController = TextEditingController(text: existing?.notes ?? '');

    final formKey = GlobalKey<FormState>();

    String type = existing?.type ?? 'expense';
    DateTime selectedDate = existing == null
        ? DateTime.now()
        : DateTime.tryParse(existing.entryDate) ?? DateTime.now();

    BookkeepingEntry? entryToSave;

    try {
      entryToSave = await showModalBottomSheet<BookkeepingEntry>(
        context: context,
        isScrollControlled: true,
        backgroundColor: const Color(0xFF111827),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (sheetContext) => StatefulBuilder(
          builder: (context, setSheetState) => Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              MediaQuery.viewInsetsOf(context).bottom + 20,
            ),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      existing == null
                          ? 'Add cashbook entry'
                          : 'Edit cashbook entry',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 18),
                    DropdownButtonFormField<String>(
                      value: type,
                      dropdownColor: const Color(0xFF1F2937),
                      decoration: const InputDecoration(
                        labelText: 'Transaction type',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'income',
                          child: Text('Income'),
                        ),
                        DropdownMenuItem(
                          value: 'expense',
                          child: Text('Expense'),
                        ),
                        DropdownMenuItem(
                          value: 'savings_deposit',
                          child: Text('Savings contribution'),
                        ),
                        DropdownMenuItem(
                          value: 'savings_withdrawal',
                          child: Text('Savings withdrawal'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setSheetState(() => type = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descriptionController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Transaction description',
                      ),
                      validator: (value) => (value ?? '').trim().isEmpty
                          ? 'Enter a description'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Amount (₦)',
                        hintText: 'e.g. 15000.00',
                      ),
                      validator: (value) => _parseKobo(value ?? '') == null
                          ? 'Enter an amount greater than zero (up to 2 decimals)'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: categoryController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Category (optional)',
                        hintText: 'Food, salary, transport...',
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );

                        if (picked != null) {
                          setSheetState(() => selectedDate = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Transaction date',
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 17,
                              color: _cyan,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _dateLabel(selectedDate),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: notesController,
                      minLines: 1,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _saving
                            ? null
                            : () {
                                if (!formKey.currentState!.validate()) {
                                  return;
                                }

                                final entry = BookkeepingEntry(
                                  id: existing?.id ?? '',
                                  type: type,
                                  description: descriptionController.text
                                      .trim(),
                                  category: categoryController.text.trim(),
                                  notes: notesController.text.trim(),
                                  entryDate: _dateKey(selectedDate),
                                  amountKobo: _parseKobo(
                                    amountController.text,
                                  )!,
                                  cashBalanceAfterKobo: 0,
                                  savingsBalanceAfterKobo: 0,
                                );

                                Navigator.of(sheetContext).pop(entry);
                              },
                        icon: const Icon(Icons.save_outlined),
                        label: Text(
                          existing == null
                              ? 'Save transaction'
                              : 'Update transaction',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    } finally {
      // showModalBottomSheet completes when the route is popped, but its
      // reverse transition can still be running. Keep the TextField
      // controllers alive until that transition has finished so Flutter
      // cannot rebuild a closing TextFormField with a disposed controller.
      await Future<void>.delayed(const Duration(milliseconds: 250));
      descriptionController.dispose();
      amountController.dispose();
      categoryController.dispose();
      notesController.dispose();
    }

    // Save only after the bottom sheet has closed and its controllers have
    // safely outlived the reverse animation.
    if (entryToSave != null && mounted) {
      await _saveEntry(entryToSave, isEdit: existing != null);
    }
  }

  Future<void> _saveEntry(
    BookkeepingEntry entry, {
    required bool isEdit,
  }) async {
    if (!mounted) return;

    // Capture the messenger while this screen is active. Do not look it up
    // again through context after the asynchronous API request.
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _saving = true);
    try {
      if (isEdit) {
        await _service.updateEntry(entry);
      } else {
        await _service.addEntry(entry);
      }
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(isEdit ? 'Transaction updated.' : 'Transaction added.'),
        ),
      );
      await _loadDashboard();
    } catch (error) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(_friendlyError(error))));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _removeEntry(BookkeepingEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111827),
        title: const Text(
          'Remove transaction?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '“${entry.description}” will be removed from your active cashbook. The record is retained for audit purposes.',
          style: const TextStyle(color: _muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _saving = true);
    try {
      await _service.removeEntry(entry.id);
      await _loadDashboard();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_friendlyError(error))));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  static String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static String _dateLabel(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  @override
  Widget build(BuildContext context) {
    final cash = _asInt(_summary['cashBalanceKobo']);
    final savings = _asInt(_summary['savingsBalanceKobo']);
    final income = _asInt(_summary['totalIncomeKobo']);
    final expenses = _asInt(_summary['totalExpenseKobo']);
    final deposits = _asInt(_summary['savingsDepositsKobo']);
    final withdrawals = _asInt(_summary['savingsWithdrawalsKobo']);

    return Scaffold(
      backgroundColor: const Color(0xFF05070A),
      appBar: const AppHeaderr(title: 'Smart Bookkeeping'),
      body: AppResponsiveLayout(
        child: RefreshIndicator(
          onRefresh: _loadDashboard,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your money, clearly accounted for.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Record income, expenses and savings. GiftPay keeps the balances for you.',
                          style: TextStyle(color: _muted, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Bookkeeping options',
                    enabled: !_loading && !_saving,
                    icon: const Icon(Icons.more_vert, color: _cyan),
                    onSelected: (value) {
                      if (value == 'opening') _showOpeningBalanceDialog();
                      if (value == 'reset') _resetBookkeeping();
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'opening',
                        child: Text(
                          _settingsConfigured
                              ? 'Edit opening balances'
                              : 'Set opening balances',
                        ),
                      ),
                      if (_settingsConfigured)
                        const PopupMenuItem(
                          value: 'reset',
                          child: Text('Reset bookkeeping'),
                        ),
                    ],
                  ),
                  IconButton(
                    tooltip: 'Refresh',
                    onPressed: _loading ? null : _loadDashboard,
                    icon: const Icon(Icons.refresh, color: _cyan),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (!_settingsConfigured && !_loading) _setupBanner(),
              if (_error != null && !_loading) _errorBanner(_error!),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 80),
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                _balanceHero(cash, savings),
                const SizedBox(height: 14),
                _dailyClosingCard(),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _metricCard(
                      'Total income',
                      income,
                      _green,
                      Icons.south_west,
                    ),
                    _metricCard('Expenses', expenses, _red, Icons.north_east),
                    _metricCard(
                      'Saved',
                      deposits - withdrawals,
                      _cyan,
                      Icons.savings_outlined,
                    ),
                    _metricCard(
                      'Savings contributions',
                      deposits,
                      Colors.amber,
                      Icons.add_circle_outline,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _reportsCard(),
                const SizedBox(height: 20),
                BookkeepingPlanningSection(
                  onChanged: () {
                    _loadDashboard();
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Cashbook',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: _saving || !_settingsConfigured
                          ? null
                          : () => _showEntryDialog(),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add entry'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Date · Transaction · Credit · Debit · Running balance',
                  style: TextStyle(color: _muted, fontSize: 12),
                ),
                const SizedBox(height: 12),
                if (_entries.isEmpty) _emptyState() else _cashbookTable(),
                const SizedBox(height: 20),
                _savingsInfo(deposits, withdrawals, savings),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _setupBanner() => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: const Color(0xFF12304A),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _cyan.withOpacity(.35)),
    ),
    child: Row(
      children: [
        const Icon(Icons.account_balance_wallet_outlined, color: _cyan),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Set your starting cash and savings balances before recording your first entry.',
            style: TextStyle(color: Colors.white, fontSize: 13, height: 1.35),
          ),
        ),
        TextButton(
          onPressed: _saving ? null : _showOpeningBalanceDialog,
          child: const Text('Set up'),
        ),
      ],
    ),
  );

  Widget _errorBanner(String message) => Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: _red.withOpacity(.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _red.withOpacity(.3)),
    ),
    child: Text(message, style: const TextStyle(color: Colors.white)),
  );

  Widget _balanceHero(int cash, int savings) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF123B67), Color(0xFF101827)],
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _cyan.withOpacity(.28)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.18),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available cash balance',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 7),
        Text(
          _money(cash),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            const Icon(Icons.savings_outlined, color: _green, size: 19),
            const SizedBox(width: 8),
            const Text(
              'Tracked savings',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const Spacer(),
            Text(
              _money(savings),
              style: const TextStyle(
                color: _green,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          'Savings are kept separate from ordinary expenses.',
          style: TextStyle(color: Colors.white54, fontSize: 11),
        ),
      ],
    ),
  );

  Widget _dailyClosingCard() {
    final date = _dailySummary['date']?.toString() ?? _dateKey(DateTime.now());
    final openingCash = _asInt(_dailySummary['openingCashKobo']);
    final closingCash = _asInt(_dailySummary['closingCashKobo']);
    final income = _asInt(_dailySummary['incomeKobo']);
    final expenses = _asInt(_dailySummary['expenseKobo']);
    final savingsIn = _asInt(_dailySummary['savingsDepositsKobo']);
    final savingsOut = _asInt(_dailySummary['savingsWithdrawalsKobo']);
    final openingSavings = _asInt(_dailySummary['openingSavingsKobo']);
    final closingSavings = _asInt(_dailySummary['closingSavingsKobo']);

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Daily account closing',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(date, style: const TextStyle(color: _muted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 13),
          _summaryLine(
            'Opening cash balance',
            _money(openingCash),
            Colors.white70,
          ),
          const SizedBox(height: 8),
          _summaryLine('Income received', _money(income), _green),
          const SizedBox(height: 8),
          _summaryLine('Ordinary expenses', _money(expenses), _red),
          const SizedBox(height: 8),
          _summaryLine('Savings contributed', _money(savingsIn), _cyan),
          const SizedBox(height: 8),
          _summaryLine('Savings withdrawn', _money(savingsOut), Colors.amber),
          const Divider(color: _line, height: 22),
          _summaryLine(
            'Closing cash balance',
            _money(closingCash),
            _green,
            bold: true,
          ),
          const SizedBox(height: 8),
          _summaryLine(
            'Savings balance',
            '${_money(openingSavings)} → ${_money(closingSavings)}',
            _cyan,
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String label, int amount, Color color, IconData icon) =>
      SizedBox(
        width: 220,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(color: _muted, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _money(amount),
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _cashbookTable() => Container(
    decoration: BoxDecoration(
      color: _surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _line),
    ),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(Colors.white.withOpacity(.04)),
        dataRowMinHeight: 58,
        dataRowMaxHeight: 72,
        columnSpacing: 24,
        columns: const [
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Transaction')),
          DataColumn(
            label: Text('Credit', style: TextStyle(color: _green)),
          ),
          DataColumn(
            label: Text('Debit', style: TextStyle(color: _red)),
          ),
          DataColumn(label: Text('Balance')),
          DataColumn(label: Text('')),
        ],
        rows: _entries.map((entry) {
          final credit =
              entry.type == 'income' || entry.type == 'savings_withdrawal';
          final debit =
              entry.type == 'expense' || entry.type == 'savings_deposit';
          return DataRow(
            cells: [
              DataCell(
                Text(
                  entry.entryDate,
                  style: const TextStyle(color: _muted, fontSize: 12),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 180,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${_typeLabel(entry.type)}${entry.category.isEmpty ? '' : ' · ${entry.category}'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: _muted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
              DataCell(
                Text(
                  credit ? _money(entry.amountKobo) : '—',
                  style: const TextStyle(color: _green),
                ),
              ),
              DataCell(
                Text(
                  debit ? _money(entry.amountKobo) : '—',
                  style: const TextStyle(color: _red),
                ),
              ),
              DataCell(
                Text(
                  _money(entry.cashBalanceAfterKobo),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              DataCell(
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: _muted, size: 19),
                  onSelected: (value) {
                    if (value == 'edit') _showEntryDialog(existing: entry);
                    if (value == 'remove') _removeEntry(entry);
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'remove', child: Text('Remove')),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    ),
  );

  Widget _emptyState() => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
    decoration: BoxDecoration(
      color: _surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _line),
    ),
    child: const Column(
      children: [
        Icon(Icons.menu_book_outlined, color: _cyan, size: 38),
        SizedBox(height: 12),
        Text(
          'Your cashbook is empty',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 6),
        Text(
          'Add your first income, expense or savings transaction. GiftPay will calculate the balances automatically.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _muted, height: 1.4),
        ),
      ],
    ),
  );

  Widget _savingsInfo(int deposits, int withdrawals, int balance) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _line),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Savings activity',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        _summaryLine('Contributions', _money(deposits), _green),
        const SizedBox(height: 8),
        _summaryLine('Withdrawals', _money(withdrawals), _red),
        const Divider(color: _line, height: 20),
        _summaryLine(
          'Current savings balance',
          _money(balance),
          _cyan,
          bold: true,
        ),
      ],
    ),
  );

  Widget _summaryLine(
    String label,
    String value,
    Color color, {
    bool bold = false,
  }) => Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: TextStyle(
            color: bold ? Colors.white : _muted,
            fontSize: 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
      Text(
        value,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}
