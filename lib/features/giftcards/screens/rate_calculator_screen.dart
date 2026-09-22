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

  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _sellableGiftcards = [];

  Map<String, dynamic>? _selectedCategory;
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

      final rawCategories = data['giftCardCategories'];

      final rawSellable = data['sellableGiftcards'];

      if (rawSellable is! List) {
        throw Exception('No live rates were returned.');
      }

      final sellable = rawSellable
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      final categories = <Map<String, dynamic>>[];

      if (rawCategories is List) {
        categories.addAll(
          rawCategories.whereType<Map>().map(
            (item) => Map<String, dynamic>.from(item),
          ),
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _categories = categories;
        _sellableGiftcards = sellable;

        _selectedCategory = categories.isNotEmpty ? categories.first : null;

        _selectedGiftcard = _cardsForCategory(
          categories.isNotEmpty ? categories.first : null,
        ).firstOrNull;

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

  List<Map<String, dynamic>> _cardsForCategory(Map<String, dynamic>? category) {
    if (category == null) {
      return <Map<String, dynamic>>[];
    }

    final categoryId = category['id']?.toString();

    final categoryName = category['name']?.toString().toLowerCase();

    return _sellableGiftcards.where((giftcard) {
      final nested = giftcard['category'];

      if (nested is Map) {
        final nestedId = nested['id']?.toString();

        final nestedName = nested['name']?.toString().toLowerCase();

        return (categoryId != null && nestedId == categoryId) ||
            (categoryName != null && nestedName == categoryName);
      }

      return false;
    }).toList();
  }

  double get _rate {
    return double.tryParse(_selectedGiftcard?['rate']?.toString() ?? '') ?? 0;
  }

  double get _payout {
    return _amount * _rate;
  }

  void _selectCategory(Map<String, dynamic>? category) {
    final cards = _cardsForCategory(category);

    setState(() {
      _selectedCategory = category;
      _selectedGiftcard = cards.isNotEmpty ? cards.first : null;
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadRates, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (_categories.isEmpty) {
      return const Center(
        child: Text('No gift card categories are currently available.'),
      );
    }

    final cards = _cardsForCategory(_selectedCategory);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Check Gift Card Rate',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        const Text(
          'Select your gift card to see the current Prestmit market rate.',
          style: TextStyle(color: Colors.white60, height: 1.5),
        ),
        const SizedBox(height: 24),
        DropdownButtonFormField<Map<String, dynamic>>(
          value: _selectedCategory,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Gift Card Category',
            border: OutlineInputBorder(),
          ),
          items: _categories
              .map(
                (category) => DropdownMenuItem<Map<String, dynamic>>(
                  value: category,
                  child: Text(category['name']?.toString() ?? 'Gift Card'),
                ),
              )
              .toList(),
          onChanged: _selectCategory,
        ),
        const SizedBox(height: 18),
        if (cards.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'No sellable card options are currently available for this category.',
              textAlign: TextAlign.center,
            ),
          )
        else
          DropdownButtonFormField<Map<String, dynamic>>(
            value: _selectedGiftcard,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Exact Gift Card',
              border: OutlineInputBorder(),
            ),
            items: cards
                .map(
                  (giftcard) => DropdownMenuItem<Map<String, dynamic>>(
                    value: giftcard,
                    child: Text(
                      '${giftcard['name']} • ${giftcard['country']} • ${giftcard['form']}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
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
          onChanged: (value) {
            setState(() {
              _amount = double.tryParse(value.trim()) ?? 0;
            });
          },
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF4A6BB8).withOpacity(.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF4A6BB8).withOpacity(.18)),
          ),
          child: Column(
            children: [
              const Text(
                'Current Rate',
                style: TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 8),
              Text(
                '₦${_rate.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Estimated payout',
                style: TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 8),
              Text(
                '₦${_payout.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF75A1FF),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Rates are provided by Prestmit and may change. The final payout is determined after Prestmit processes the submitted gift card.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.5),
        ),
      ],
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
