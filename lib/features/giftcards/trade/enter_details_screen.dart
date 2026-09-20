import 'package:flutter/material.dart';

import 'upload_card_screen.dart';

class EnterTradeDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> giftcard;

  const EnterTradeDetailsScreen({super.key, required this.giftcard});

  @override
  State<EnterTradeDetailsScreen> createState() =>
      _EnterTradeDetailsScreenState();
}

class _EnterTradeDetailsScreenState extends State<EnterTradeDetailsScreen> {
  final TextEditingController _amountController = TextEditingController();

  double _amount = 0;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get _rate {
    return double.tryParse(widget.giftcard['rate']?.toString() ?? '') ?? 0;
  }

  double get _minimum {
    return double.tryParse(widget.giftcard['minimum']?.toString() ?? '') ?? 0;
  }

  double get _payout {
    return _amount * _rate;
  }

  bool get _isEcode {
    final form = widget.giftcard['form']?.toString().toLowerCase() ?? '';

    return form.contains('ecode') ||
        form.contains('e-code') ||
        form.contains('digital');
  }

  void _continue() {
    if (_amount <= 0) {
      _showError('Enter the card amount.');
      return;
    }

    if (_minimum > 0 && _amount < _minimum) {
      _showError('The minimum amount for this gift card is $_minimum.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UploadCardScreen(
          giftcard: widget.giftcard,
          amount: _amount.toString(),
          rate: _rate.toString(),
          payout: _payout.toString(),
          isEcode: _isEcode,
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.giftcard['name']?.toString() ?? 'Gift Card';

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Current rate', style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 6),
            Text(
              '₦$_rate per unit',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Card Amount',
                hintText: _minimum > 0 ? 'Minimum $_minimum' : null,
                prefixText: '\$ ',
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _amount = double.tryParse(value.trim()) ?? 0;
                });
              },
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(.06),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'Estimated payout',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₦${_payout.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _continue,
                child: Text(
                  _isEcode ? 'Continue to E-code' : 'Continue to Upload',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
