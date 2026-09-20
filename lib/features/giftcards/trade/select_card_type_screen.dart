import 'package:flutter/material.dart';

import 'enter_details_screen.dart';

class SelectCardTypeScreen extends StatelessWidget {
  final Map<String, dynamic> giftcard;

  const SelectCardTypeScreen({super.key, required this.giftcard});

  @override
  Widget build(BuildContext context) {
    final name = giftcard['name']?.toString() ?? 'Gift Card';

    final country = giftcard['country']?.toString() ?? '';

    final form = giftcard['form']?.toString() ?? '';

    final rate = giftcard['rate']?.toString() ?? '0';

    final minimum = giftcard['minimum']?.toString() ?? '0';

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _InfoCard(label: 'GIFT CARD', value: name),
          const SizedBox(height: 12),
          _InfoCard(label: 'COUNTRY', value: country),
          const SizedBox(height: 12),
          _InfoCard(label: 'CARD FORM', value: form),
          const SizedBox(height: 12),
          _InfoCard(label: 'CURRENT RATE', value: '₦$rate'),
          const SizedBox(height: 12),
          _InfoCard(label: 'MINIMUM', value: minimum),
          const SizedBox(height: 28),
          if (giftcard['terms'] != null &&
              giftcard['terms'].toString().trim().isNotEmpty) ...[
            const Text(
              'Terms',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(
              _stripHtml(giftcard['terms'].toString()),
              style: const TextStyle(height: 1.5, color: Colors.grey),
            ),
            const SizedBox(height: 28),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EnterTradeDetailsScreen(giftcard: giftcard),
                  ),
                );
              },
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }

  String _stripHtml(String value) {
    return value
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .trim();
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;

  const _InfoCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
