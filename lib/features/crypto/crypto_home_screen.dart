import 'package:flutter/material.dart';
import 'package:utilityhub/features/crypto/data/crypto_api_service.dart';

class CryptoHomeScreen extends StatefulWidget {
  const CryptoHomeScreen({super.key});

  @override
  State<CryptoHomeScreen> createState() => _CryptoHomeScreenState();
}

class _CryptoHomeScreenState extends State<CryptoHomeScreen> {
  late Future<List<dynamic>> _load;

  @override
  void initState() {
    super.initState();
    _load = _loadData();
  }

  Future<List<dynamic>> _loadData() async {
    return Future.wait([
      CryptoApiService.getCurrencies(),
      CryptoApiService.getPairs(),
    ]);
  }

  void _refresh() => setState(() => _load = _loadData());

  List<dynamic> _items(dynamic value) {
    if (value is List) return value;
    if (value is Map && value['data'] is List) return value['data'] as List;
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF20C997);
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: const Text('GiftPay Crypto'),
        backgroundColor: const Color(0xFF111820),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _load,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 42, color: Colors.white54),
                    const SizedBox(height: 12),
                    Text(
                      snapshot.error.toString().replaceFirst('Exception: ', ''),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(onPressed: _refresh, child: const Text('Try again')),
                  ],
                ),
              ),
            );
          }

          final currencies = _items(snapshot.data![0]);
          final pairs = _items(snapshot.data![1]);
          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF123B35), Color(0xFF172B3A)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Digital assets', style: TextStyle(color: Colors.white70)),
                      SizedBox(height: 8),
                      Text('Crypto on GiftPay', style: TextStyle(
                        color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold,
                      )),
                      SizedBox(height: 6),
                      Text('Market information powered by Busha.',
                        style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _sectionTitle('Supported assets', currencies.length),
                if (currencies.isEmpty)
                  _empty('No supported assets were returned.')
                else
                  _chipWrap(currencies, (m) =>
                    '${m is Map ? (m['code'] ?? m['currency'] ?? m['name'] ?? 'Asset') : m}'),
                const SizedBox(height: 24),
                _sectionTitle('Trading pairs', pairs.length),
                if (pairs.isEmpty)
                  _empty('No trading pairs were returned.')
                else
                  _chipWrap(pairs, (m) =>
                    '${m is Map ? (m['symbol'] ?? m['code'] ?? m['base_currency'] ?? 'Pair') : m}'),
                const SizedBox(height: 24),
                const Text(
                  'Wallet balances, customer onboarding, quotes and transactions will appear here after GiftPay customer accounts are mapped to Busha and the settlement controls are completed.',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String title, int count) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Text(title, style: const TextStyle(
          color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold,
        )),
        const SizedBox(width: 8),
        Text('$count', style: const TextStyle(color: Colors.white54)),
      ],
    ),
  );

  Widget _empty(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Text(text, style: const TextStyle(color: Colors.white54)),
  );

  Widget _chipWrap(List<dynamic> values, String Function(dynamic) label) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values.take(40).map((item) => Chip(
        label: Text(label(item)),
        backgroundColor: const Color(0xFF19232E),
        labelStyle: const TextStyle(color: Colors.white),
      )).toList(),
    );
  }
}
