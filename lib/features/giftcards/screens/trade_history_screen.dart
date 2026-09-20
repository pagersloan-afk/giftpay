import 'package:flutter/material.dart';

import '../models/giftcard_trade.dart';
import '../services/giftcard_trade_service.dart';

class GiftCardTradeHistoryScreen extends StatefulWidget {
  const GiftCardTradeHistoryScreen({super.key});

  @override
  State<GiftCardTradeHistoryScreen> createState() =>
      _GiftCardTradeHistoryScreenState();
}

class _GiftCardTradeHistoryScreenState
    extends State<GiftCardTradeHistoryScreen> {
  final GiftCardTradeService _service = GiftCardTradeService();

  bool _loading = true;
  String? _error;

  List<GiftCardTrade> _trades = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final trades = await _service.getHistory();

      if (!mounted) {
        return;
      }

      setState(() {
        _trades = trades;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gift Card Trades')),
      body: RefreshIndicator(onRefresh: _loadHistory, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loading && _trades.isEmpty) {
      return ListView(
        physics: AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 300,
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

    if (_error != null && _trades.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 120),
          const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(_error!, textAlign: TextAlign.center),
          const SizedBox(height: 18),
          ElevatedButton(onPressed: _loadHistory, child: const Text('Retry')),
        ],
      );
    }

    if (_trades.isEmpty) {
      return ListView(
        physics: AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 280,
            child: Center(child: Text('No gift card trades yet.')),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _trades.length,
      itemBuilder: (_, index) {
        final trade = _trades[index];

        return _TradeListItem(
          trade: trade,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TradeDetailsScreen(trade: trade),
              ),
            );
          },
        );
      },
    );
  }
}

class _TradeListItem extends StatelessWidget {
  final GiftCardTrade trade;
  final VoidCallback onTap;

  const _TradeListItem({required this.trade, required this.onTap});

  Color _statusColor() {
    switch (trade.status) {
      case 'completed':
        return Colors.green;

      case 'rejected':
        return Colors.red;

      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(.12),
          child: Icon(Icons.card_giftcard, color: color),
        ),
        title: Text(
          trade.brand.isEmpty ? 'Gift Card' : trade.brand,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text('₦${trade.valueInNaira}\n${trade.providerReference}'),
        isThreeLine: true,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            trade.status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class TradeDetailsScreen extends StatelessWidget {
  final GiftCardTrade trade;

  const TradeDetailsScreen({super.key, required this.trade});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trade Details')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _detail('Gift Card', trade.brand),
          _detail('Country', trade.country),
          _detail('Card Type', trade.cardType),
          _detail('Amount', '\$${trade.amount}'),
          _detail('Rate', '₦${trade.rate}'),
          _detail('Expected Payout', '₦${trade.valueInNaira}'),
          _detail('Payout Method', trade.payoutMethod),
          _detail('Prestmit Reference', trade.providerReference),
          _detail('Status', trade.status.toUpperCase()),
          if (trade.rejectionReason != null &&
              trade.rejectionReason!.isNotEmpty)
            _detail('Rejection Reason', trade.rejectionReason!),
          _detail('Created', trade.createdAt.toLocal().toString()),
        ],
      ),
    );
  }

  Widget _detail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
