import 'package:flutter/material.dart';

import '../services/giftcard_trade_service.dart';

class GiftCardRateCalculatorScreen extends StatefulWidget {
  const GiftCardRateCalculatorScreen({super.key});

  @override
  State<GiftCardRateCalculatorScreen> createState() =>
      _GiftCardRateCalculatorScreenState();
}

class _GiftCardRateCalculatorScreenState
    extends State<GiftCardRateCalculatorScreen> {
  final GiftCardTradeService _service = GiftCardTradeService();

  final TextEditingController _amountController = TextEditingController();

  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> _giftcards = [];

  Map<String, dynamic>? _selectedGiftcard;

  double _amount = 0;

  @override
  void initState() {
    super.initState();
    _loadRates();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadRates() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await _service.getRateCalculatorData();

      final raw = response['data'];

      final data = raw is Map ? Map<String, dynamic>.from(raw) : response;

      final sellable = data['sellableGiftcards'];

      if (sellable is! List) {
        throw Exception('No live rates were returned.');
      }

      final list = sellable
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      if (!mounted) {
        return;
      }

      setState(() {
        _giftcards = list;
        _selectedGiftcard = list.isNotEmpty ? list.first : null;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  double get _rate {
    return double.tryParse(_selectedGiftcard?['rate']?.toString() ?? '') ?? 0;
  }

  double get _payout {
    return _amount * _rate;
  }

  void _calculate(String value) {
    setState(() {
      _amount = double.tryParse(value.trim()) ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rate Calculator')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadRates, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_giftcards.isEmpty) {
      return const Center(
        child: Text('No sell rates are currently available.'),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        DropdownButtonFormField<Map<String, dynamic>>(
          value: _selectedGiftcard,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Gift Card',
            border: OutlineInputBorder(),
          ),
          items: _giftcards.map((giftcard) {
            final name = giftcard['name']?.toString() ?? 'Gift Card';

            final country = giftcard['country']?.toString() ?? '';

            final rate = giftcard['rate']?.toString() ?? '';

            return DropdownMenuItem<Map<String, dynamic>>(
              value: giftcard,
              child: Text(
                '$name • $country • ₦$rate',
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedGiftcard = value;
            });
          },
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Card Amount',
            prefixText: '\$ ',
            border: OutlineInputBorder(),
          ),
          onChanged: _calculate,
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(.06),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              const Text('Current Rate', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              Text(
                '₦$_rate',
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Estimated payout',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                '₦${_payout.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Rates are provided by Prestmit and may change. The final payout is determined when Prestmit processes the submitted gift card.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.5),
        ),
      ],
    );
  }
}
