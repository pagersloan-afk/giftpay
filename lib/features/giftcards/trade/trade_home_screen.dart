import 'package:flutter/material.dart';

import 'package:utilityhub/core/widgets/app_responsive_layout.dart';

import '../services/giftcard_trade_service.dart';
import 'select_card_type_screen.dart';

class TradeGiftCardHomeScreen extends StatefulWidget {
  const TradeGiftCardHomeScreen({super.key});

  @override
  State<TradeGiftCardHomeScreen> createState() =>
      _TradeGiftCardHomeScreenState();
}

class _TradeGiftCardHomeScreenState extends State<TradeGiftCardHomeScreen> {
  final GiftCardTradeService _service = GiftCardTradeService();

  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> _giftcards = [];

  @override
  void initState() {
    super.initState();
    _loadRates();
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
        throw Exception('No sellable gift cards were returned.');
      }

      final items = sellable
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      if (!mounted) {
        return;
      }

      setState(() {
        _giftcards = items;
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

  void _openGiftCard(Map<String, dynamic> giftcard) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectCardTypeScreen(giftcard: giftcard),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trade Gift Cards'),
        backgroundColor: Colors.black,
      ),
      body: AppResponsiveLayout(child: _buildBody()),
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
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _loadRates, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (_giftcards.isEmpty) {
      return const Center(
        child: Text('No gift cards are currently available for sale.'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRates,
      child: GridView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: _giftcards.length,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 240,
          crossAxisSpacing: 18,
          mainAxisSpacing: 18,
          childAspectRatio: 0.92,
        ),
        itemBuilder: (_, index) {
          final giftcard = _giftcards[index];

          return _SellGiftCardCard(
            giftcard: giftcard,
            onTap: () => _openGiftCard(giftcard),
          );
        },
      ),
    );
  }
}

class _SellGiftCardCard extends StatefulWidget {
  final Map<String, dynamic> giftcard;
  final VoidCallback onTap;

  const _SellGiftCardCard({required this.giftcard, required this.onTap});

  @override
  State<_SellGiftCardCard> createState() => _SellGiftCardCardState();
}

class _SellGiftCardCardState extends State<_SellGiftCardCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final name = widget.giftcard['name']?.toString() ?? 'Gift Card';

    final rate = widget.giftcard['rate']?.toString() ?? '';

    final country = widget.giftcard['country']?.toString() ?? '';

    final form = widget.giftcard['form']?.toString() ?? '';

    final category = widget.giftcard['category'];

    final categoryName = category is Map ? category['name']?.toString() : null;

    final image = category is Map ? category['image']?.toString() : null;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _hovering = true);
      },
      onExit: (_) {
        setState(() => _hovering = false);
      },
      child: AnimatedScale(
        scale: _hovering ? 1.025 : 1,
        duration: const Duration(milliseconds: 180),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                colors: [Color(0xFF1A1F25), Color(0xFF0D1117)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: _hovering
                    ? Colors.blueAccent.withOpacity(.4)
                    : Colors.white.withOpacity(.08),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 56,
                  width: 56,
                  child: image != null && image.isNotEmpty
                      ? Image.network(
                          image,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.card_giftcard,
                                size: 46,
                                color: Colors.white54,
                              ),
                        )
                      : const Icon(
                          Icons.card_giftcard,
                          size: 46,
                          color: Colors.white54,
                        ),
                ),
                const SizedBox(height: 14),
                Text(
                  categoryName ?? name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$country • $form',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  '₦$rate / unit',
                  style: const TextStyle(
                    color: Color(0xFF75A1FF),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
