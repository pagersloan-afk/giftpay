import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:utilityhub/features/bookkeeping/services/bookkeeping_api_service.dart';

class BookkeepingPlanningSection extends StatefulWidget {
  final VoidCallback onChanged;

  const BookkeepingPlanningSection({super.key, required this.onChanged});

  @override
  State<BookkeepingPlanningSection> createState() =>
      _BookkeepingPlanningSectionState();
}

class _BookkeepingPlanningSectionState
    extends State<BookkeepingPlanningSection> {
  static const Color _surface = Color(0xFF101827);
  static const Color _line = Color(0x24FFFFFF);
  static const Color _muted = Color(0xFF9CA8B8);
  static const Color _cyan = Color(0xFF4FC3F7);
  static const Color _green = Color(0xFF4ADE80);
  static const Color _amber = Color(0xFFFBBF24);
  final BookkeepingApiService _api = BookkeepingApiService();
  bool _loading = true;
  bool _busy = false;
  String? _error;
  List<Map<String, dynamic>> _budgets = [];
  List<Map<String, dynamic>> _goals = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  int _int(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;

  String _money(int kobo) {
    final value = (kobo.abs() / 100);
    final formatted = NumberFormat('#,##0.00', 'en_NG').format(value);
    return '${kobo < 0 ? '-' : ''}₦$formatted';
  }

  int? _parseKobo(String value) {
    final cleaned = value.replaceAll(',', '').replaceAll('₦', '').trim();
    if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(cleaned)) return null;
    final parts = cleaned.split('.');
    final whole = int.tryParse(parts[0]);
    if (whole == null) return null;
    final fraction = parts.length == 1 ? 0 : int.parse(parts[1].padRight(2, '0'));
    final result = whole * 100 + fraction;
    return result > 0 ? result : null;
  }

  Future<void> _load() async {
    if (mounted) setState(() { _loading = true; _error = null; });
    try {
      final now = DateTime.now();
      final date = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final data = await _api.getPlanning(date: date);
      if (!mounted) return;
      setState(() {
        _budgets = (data['budgets'] as List? ?? [])
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
        _goals = (data['goals'] as List? ?? [])
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() { _error = error.toString().replaceFirst('Exception: ', ''); _loading = false; });
    }
  }

  Future<void> _run(Future<void> Function() action, String success) async {
    if (_busy) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(success)));
      await _load();
      widget.onChanged();
    } catch (error) {
      if (mounted) messenger.showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _budgetDialog({Map<String, dynamic>? existing}) async {
    final name = TextEditingController(text: existing?['name']?.toString() ?? '');
    final category = TextEditingController(text: existing?['category']?.toString() == 'all' ? '' : existing?['category']?.toString() ?? '');
    final amount = TextEditingController(
      text: existing == null ? '' : (_int(existing['limitKobo']) / 100).toStringAsFixed(2),
    );
    String period = existing?['period']?.toString() ?? 'monthly';
    final key = GlobalKey<FormState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF111827),
          title: Text(existing == null ? 'Create budget' : 'Edit budget',
              style: const TextStyle(color: Colors.white)),
          content: Form(
            key: key,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextFormField(
                  controller: name,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Budget name'),
                  validator: (v) => (v ?? '').trim().isEmpty ? 'Enter a name' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: category,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Expense category (leave blank for all)',
                    hintText: 'Food, Transport, Fuel...',
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: period,
                  dropdownColor: const Color(0xFF172235),
                  decoration: const InputDecoration(labelText: 'Budget period'),
                  items: const [
                    DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                    DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                  ],
                  onChanged: (v) { if (v != null) setDialogState(() => period = v); },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: amount,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Spending limit (NGN)'),
                  validator: (v) => _parseKobo(v ?? '') == null ? 'Enter a valid amount' : null,
                ),
                const SizedBox(height: 8),
                const Text('Spending is calculated from active expense entries in this category.',
                    style: TextStyle(color: _muted, fontSize: 12)),
              ]),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
            FilledButton(onPressed: () {
              if (key.currentState!.validate()) Navigator.pop(dialogContext, true);
            }, child: const Text('Save budget')),
          ],
        ),
      ),
    );
    try {
      if (ok == true && mounted) {
        final payload = () => _api.createBudget(
          name: name.text.trim(),
          category: category.text.trim().isEmpty ? 'all' : category.text.trim(),
          period: period,
          limitKobo: _parseKobo(amount.text)!,
        );
        if (existing == null) {
          await _run(payload, 'Budget created.');
        } else {
          await _run(() => _api.updateBudget(
            id: existing['id'].toString(),
            name: name.text.trim(),
            category: category.text.trim().isEmpty ? 'all' : category.text.trim(),
            period: period,
            limitKobo: _parseKobo(amount.text)!,
          ), 'Budget updated.');
        }
      }
    } finally {
      name.dispose(); category.dispose(); amount.dispose();
    }
  }

  Future<void> _goalDialog({Map<String, dynamic>? existing}) async {
    final name = TextEditingController(text: existing?['name']?.toString() ?? '');
    final amount = TextEditingController(
      text: existing == null ? '' : (_int(existing['targetKobo']) / 100).toStringAsFixed(2),
    );
    final date = TextEditingController(text: existing?['targetDate']?.toString() ?? '');
    String status = existing?['status']?.toString() ?? 'active';
    final key = GlobalKey<FormState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF111827),
          title: Text(existing == null ? 'Create savings target' : 'Edit savings target',
              style: const TextStyle(color: Colors.white)),
          content: Form(
            key: key,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextFormField(controller: name, style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Goal name'),
                validator: (v) => (v ?? '').trim().isEmpty ? 'Enter a name' : null),
              const SizedBox(height: 10),
              TextFormField(controller: amount,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Target amount (NGN)'),
                validator: (v) => _parseKobo(v ?? '') == null ? 'Enter a valid amount' : null),
              const SizedBox(height: 10),
              TextFormField(controller: date, style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Target date (YYYY-MM-DD, optional)'),
                validator: (v) {
                  final value = (v ?? '').trim();
                  if (value.isEmpty) return null;
                  return RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value) ? null : 'Use YYYY-MM-DD';
                }),
              if (existing != null) ...[
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: status, dropdownColor: const Color(0xFF172235),
                  decoration: const InputDecoration(labelText: 'Goal status'),
                  items: const [
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(value: 'paused', child: Text('Paused')),
                    DropdownMenuItem(value: 'completed', child: Text('Completed')),
                  ],
                  onChanged: (v) { if (v != null) setDialogState(() => status = v); },
                ),
              ],
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
            FilledButton(onPressed: () {
              if (key.currentState!.validate()) Navigator.pop(dialogContext, true);
            }, child: const Text('Save target')),
          ],
        ),
      ),
    );
    try {
      if (ok == true && mounted) {
        if (existing == null) {
          await _run(() => _api.createSavingsGoal(
            name: name.text.trim(), targetKobo: _parseKobo(amount.text)!,
            targetDate: date.text.trim(),
          ), 'Savings target created.');
        } else {
          await _run(() => _api.updateSavingsGoal(
            id: existing['id'].toString(), name: name.text.trim(),
            targetKobo: _parseKobo(amount.text)!, targetDate: date.text.trim(),
            status: status,
          ), 'Savings target updated.');
        }
      }
    } finally {
      name.dispose(); amount.dispose(); date.dispose();
    }
  }

  Future<void> _movementDialog(String movement) async {
    final activeGoals = _goals.where((g) => movement == 'contribution'
        ? g['status'] == 'active'
        : _int(g['savedKobo']) > 0).toList();
    if (activeGoals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(movement == 'contribution'
          ? 'Create an active savings target first.'
          : 'There is no savings balance available in your targets to withdraw.')),
      );
      return;
    }
    final controllers = <String, TextEditingController>{
      for (final goal in activeGoals) goal['id'].toString(): TextEditingController(),
    };
    final key = GlobalKey<FormState>();
    final date = DateTime.now();
    final dateKey = '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final total = controllers.values.fold<int>(
            0, (sum, c) => sum + (_parseKobo(c.text) ?? 0),
          );
          return AlertDialog(
            backgroundColor: const Color(0xFF111827),
            title: Text(movement == 'contribution' ? 'Allocate savings contribution' : 'Allocate savings withdrawal',
                style: const TextStyle(color: Colors.white)),
            content: Form(
              key: key,
              child: SizedBox(
                width: 440,
                child: SingleChildScrollView(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(
                      movement == 'contribution'
                        ? 'Enter how much of this single savings deposit belongs to each goal. The total becomes one cashbook savings contribution.'
                        : 'Enter how much to withdraw from each goal. The total becomes one cashbook savings withdrawal.',
                      style: const TextStyle(color: _muted, fontSize: 12, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    for (final goal in activeGoals) ...[
                      TextFormField(
                        controller: controllers[goal['id'].toString()],
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: '${goal['name']} · available ${_money(_int(goal['savedKobo']))}',
                          prefixText: '₦',
                        ),
                        onChanged: (_) => setDialogState(() {}),
                        validator: (v) {
                          if ((v ?? '').trim().isEmpty) return null;
                          if (_parseKobo(v!) == null) return 'Enter a valid amount';
                          if (movement == 'withdrawal') {
                            final entered = _parseKobo(v)!;
                            if (entered > _int(goal['savedKobo'])) return 'Exceeds this goal balance';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 9),
                    ],
                    const Divider(color: _line),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Total transaction', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      Text(_money(total), style: const TextStyle(color: _green, fontWeight: FontWeight.w700)),
                    ]),
                  ]),
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
              FilledButton(onPressed: () {
                if (total <= 0 || !key.currentState!.validate()) return;
                Navigator.pop(dialogContext, true);
              }, child: Text(movement == 'contribution' ? 'Record contribution' : 'Record withdrawal')),
            ],
          );
        },
      ),
    );
    try {
      if (ok == true && mounted) {
        final allocations = <Map<String, dynamic>>[];
        for (final goal in activeGoals) {
          final value = _parseKobo(controllers[goal['id'].toString()]!.text);
          if (value != null) allocations.add({'goalId': goal['id'], 'amountKobo': value});
        }
        final total = allocations.fold<int>(0, (sum, item) => sum + (item['amountKobo'] as int));
        await _run(() => _api.createSavingsGoalMovement(
          movement: movement,
          description: movement == 'contribution' ? 'Savings goal contribution' : 'Savings goal withdrawal',
          entryDate: dateKey,
          amountKobo: total,
          allocations: allocations,
        ), movement == 'contribution' ? 'Savings contribution recorded.' : 'Savings withdrawal recorded.');
      }
    } finally {
      for (final controller in controllers.values) {
        controller.dispose();
      }
    }
  }

  Future<void> _deleteBudget(Map<String, dynamic> budget) async {
    final ok = await _confirm('Delete budget?', 'This removes the budget and its tracking. Your bookkeeping transactions will not be deleted.');
    if (ok) await _run(() => _api.deleteBudget(budget['id'].toString()), 'Budget deleted.');
  }

  Future<void> _deleteGoal(Map<String, dynamic> goal) async {
    final ok = await _confirm('Delete savings target?', 'A target with contribution history cannot be deleted. You can pause it instead. No cashbook transactions will be deleted.');
    if (ok) await _run(() => _api.deleteSavingsGoal(goal['id'].toString()), 'Savings target deleted.');
  }

  Future<bool> _confirm(String title, String message) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF111827),
          title: Text(title, style: const TextStyle(color: Colors.white)),
          content: Text(message, style: const TextStyle(color: _muted)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Continue')),
          ],
        ),
      ) ?? false;

  Widget _sectionTitle(String title, String subtitle, VoidCallback onAdd) =>
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 3),
          Text(subtitle, style: const TextStyle(color: _muted, fontSize: 11)),
        ])),
        OutlinedButton.icon(onPressed: _busy ? null : onAdd,
          icon: const Icon(Icons.add, size: 16), label: const Text('Add')),
      ]);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.track_changes, color: _cyan),
          SizedBox(width: 9),
          Text('Budgets & savings targets', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 6),
        const Text('Plan spending, monitor limits and allocate savings contributions across your goals.',
          style: TextStyle(color: _muted, fontSize: 12, height: 1.4)),
        if (_loading) const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()))
        else if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: Colors.redAccent)),
          TextButton(onPressed: _load, child: const Text('Try again')),
        ] else ...[
          const SizedBox(height: 18),
          _sectionTitle('Spending budgets', 'Weekly or monthly limits by expense category', () => _budgetDialog()),
          const SizedBox(height: 10),
          if (_budgets.isEmpty)
            const Text('No budgets yet. Create one to start tracking spending.', style: TextStyle(color: _muted, fontSize: 12))
          else
            for (final budget in _budgets) _budgetTile(budget),
          const Divider(color: _line, height: 28),
          _sectionTitle('Savings targets', 'One contribution can be split across several goals', () => _goalDialog()),
          const SizedBox(height: 10),
          if (_goals.isEmpty)
            const Text('No savings targets yet. Create a goal such as rent, emergency fund or a new device.', style: TextStyle(color: _muted, fontSize: 12))
          else
            for (final goal in _goals) _goalTile(goal),
          if (_goals.any((g) => g['status'] == 'active') || _goals.any((g) => _int(g['savedKobo']) > 0)) ...[
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              OutlinedButton.icon(
                onPressed: _busy || !_goals.any((g) => g['status'] == 'active')
                    ? null : () => _movementDialog('contribution'),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Allocate contribution'),
              ),
              OutlinedButton.icon(
                onPressed: _busy || !_goals.any((g) => _int(g['savedKobo']) > 0)
                    ? null : () => _movementDialog('withdrawal'),
                icon: const Icon(Icons.remove_circle_outline),
                label: const Text('Allocate withdrawal'),
              ),
            ]),
          ],
        ],
      ]),
    );
  }

  Widget _budgetTile(Map<String, dynamic> budget) {
    final limit = _int(budget['limitKobo']);
    final spent = _int(budget['spentKobo']);
    final ratio = limit <= 0 ? 0.0 : (spent / limit).clamp(0.0, 1.0).toDouble();
    final exceeded = spent > limit;
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF0B1220), borderRadius: BorderRadius.circular(12), border: Border.all(color: _line)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(budget['name']?.toString() ?? 'Budget', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
          Text(_money(spent), style: TextStyle(color: exceeded ? Colors.redAccent : _green, fontWeight: FontWeight.w700)),
          PopupMenuButton<String>(onSelected: (v) {
            if (v == 'edit') _budgetDialog(existing: budget);
            if (v == 'delete') _deleteBudget(budget);
          }, itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ]),
        ]),
        const SizedBox(height: 3),
        Text('${budget['period']} · ${budget['category'] == 'all' ? 'All categories' : budget['category']} · ${budget['periodStart']} to ${budget['periodEnd']}',
          style: const TextStyle(color: _muted, fontSize: 11)),
        const SizedBox(height: 8),
        ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(
          value: ratio, minHeight: 8, backgroundColor: Colors.white12,
          valueColor: AlwaysStoppedAnimation<Color>(exceeded ? Colors.redAccent : ratio >= .8 ? _amber : _green),
        )),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Limit ${_money(limit)}', style: const TextStyle(color: _muted, fontSize: 11)),
          Text(exceeded ? 'Over by ${_money(spent - limit)}' : '${_money(limit - spent)} remaining',
            style: TextStyle(color: exceeded ? Colors.redAccent : _muted, fontSize: 11)),
        ]),
      ]),
    );
  }

  Widget _goalTile(Map<String, dynamic> goal) {
    final target = _int(goal['targetKobo']);
    final saved = _int(goal['savedKobo']);
    final ratio = target <= 0 ? 0.0 : (saved / target).clamp(0.0, 1.0).toDouble();
    final status = goal['status']?.toString() ?? 'active';
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF0B1220), borderRadius: BorderRadius.circular(12), border: Border.all(color: _line)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(goal['name']?.toString() ?? 'Savings target', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
          Text(_money(saved), style: const TextStyle(color: _green, fontWeight: FontWeight.w700)),
          PopupMenuButton<String>(onSelected: (v) {
            if (v == 'edit') _goalDialog(existing: goal);
            if (v == 'delete') _deleteGoal(goal);
          }, itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ]),
        ]),
        Text('Target ${_money(target)} · ${status.toUpperCase()}${goal['targetDate'] == null ? '' : ' · Due ${goal['targetDate']}'}',
          style: const TextStyle(color: _muted, fontSize: 11)),
        const SizedBox(height: 8),
        ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(
          value: ratio, minHeight: 8, backgroundColor: Colors.white12,
          valueColor: const AlwaysStoppedAnimation<Color>(_green),
        )),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${(ratio * 100).toStringAsFixed(1)}% completed', style: const TextStyle(color: _muted, fontSize: 11)),
          Text('${_money((target - saved).clamp(0, target).toInt())} to go', style: const TextStyle(color: _muted, fontSize: 11)),
        ]),
      ]),
    );
  }
}
