part of '../food_merchant_screen.dart';

extension _FoodMerchantOrdersSection on _FoodMerchantScreenState {
  List<String> _nextStatuses(String status) {
      switch (status) {
        case 'pending':
          return ['confirmed', 'cancelled'];
        case 'confirmed':
          return ['preparing', 'cancelled'];
        case 'preparing':
          return ['out_for_delivery', 'cancelled'];
        default:
          return [];
      }
    }

  String _statusLabel(String status) => status
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');

  Future<void> _updateOrder(Map<String, dynamic> order, String status) async {
      final id = '${order['id'] ?? ''}';
      if (id.isEmpty) return;
      if (status == 'cancelled') {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Cancel this order?'),
            content: const Text(
              'The customer’s reserved wallet amount will be refunded by the backend.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Keep order'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Cancel order'),
              ),
            ],
          ),
        );
        if (confirmed != true) return;
      }
      setState(() => _busyOrderId = id);
      try {
        final response = await http.patch(
          _uri('/api/food/merchant/orders/$id/status'),
          headers: await _headers(),
          body: jsonEncode({'status': status}),
        );
        _decode(response);
        await _loadOrders();
        _toast('Order ${_statusLabel(status).toLowerCase()}.');
      } catch (e) {
        _toast(_error(e));
      } finally {
        if (mounted) setState(() => _busyOrderId = null);
      }
    }

  Widget _statCard(String title, String value, IconData icon, Color tint) =>
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _FoodMerchantScreenState.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: tint.withOpacity(.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: tint, size: 19),
                ),
                const SizedBox(height: 12),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: const TextStyle(fontSize: 11, color: _FoodMerchantScreenState.muted),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        );

  Widget _ordersTab() {
      if (_loadingOrders) return const Center(child: CircularProgressIndicator());
      if (_ordersError != null) return _errorState(_ordersError!, _loadOrders);
      if (_orders.isEmpty)
        return _emptyState(
          Icons.receipt_long,
          'No orders yet',
          'New customer orders will appear here.',
          'Refresh orders',
          _loadOrders,
        );
      final active = _orders
          .where((o) => !['delivered', 'cancelled'].contains('${o['status']}'))
          .length;
      return RefreshIndicator(
        onRefresh: _loadOrders,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$active active order${active == 1 ? '' : 's'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _loadOrders,
                  icon: const Icon(Icons.refresh, color: _FoodMerchantScreenState.navy),
                ),
              ],
            ),
            for (final order in _orders) _orderCard(order),
          ],
        ),
      );
    }

  Widget _orderCard(Map<String, dynamic> order) {
      final status = '${order['status'] ?? 'pending'}';
      final id = '${order['id'] ?? ''}';
      final items = order['items'] is List ? (order['items'] as List) : const [];
      final next = _nextStatuses(status);
      final busy = _busyOrderId == id;
      final customer = '${order['phone'] ?? 'No phone supplied'}';
      return Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.065),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _FoodMerchantScreenState.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order ${id.length > 15 ? id.substring(id.length - 12) : id}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '$customer',
                        style: const TextStyle(color: _FoodMerchantScreenState.muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withOpacity(.11),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel(status),
                    style: TextStyle(
                      color: _statusColor(status),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final raw in items.whereType<Map>())
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${raw['quantity'] ?? 1} × ${raw['name'] ?? 'Food item'}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Text(
                      _money(raw['lineTotal']),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            const Divider(height: 22),
            Row(
              children: [
                const Icon(Icons.payments_outlined, size: 18, color: _FoodMerchantScreenState.blue),
                const SizedBox(width: 7),
                const Expanded(
                  child: Text('Order total', style: TextStyle(color: _FoodMerchantScreenState.muted)),
                ),
                Text(
                  _money(order['total']),
                  style: const TextStyle(
                    fontSize: 17,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.055),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_outlined, color: _FoodMerchantScreenState.blue, size: 18),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      '${order['deliveryAddress'] ?? 'No delivery address'}',
                      style: const TextStyle(fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            if ('${order['notes'] ?? ''}'.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Note: ${order['notes']}',
                style: const TextStyle(color: _FoodMerchantScreenState.muted, fontSize: 12),
              ),
            ],
            const SizedBox(height: 13),
            if (status == 'out_for_delivery')
              const Text(
                'Waiting for the customer to confirm delivery with their six-digit code.',
                style: TextStyle(color: _FoodMerchantScreenState.muted, fontSize: 12),
              ),
            if (status == 'delivered')
              const Text(
                'Delivery confirmed by customer.',
                style: TextStyle(
                  color: Color(0xFF16784B),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            if (status == 'cancelled')
              const Text(
                'Order cancelled. The backend handles the customer refund.',
                style: TextStyle(color: _FoodMerchantScreenState.muted, fontSize: 12),
              ),
            if (next.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final target in next)
                    if (target == 'cancelled')
                      OutlinedButton(
                        onPressed: busy
                            ? null
                            : () => _updateOrder(order, target),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Color(0xFFFFD5D5)),
                        ),
                        child: const Text('Cancel'),
                      )
                    else
                      FilledButton.icon(
                        onPressed: busy
                            ? null
                            : () => _updateOrder(order, target),
                        style: FilledButton.styleFrom(backgroundColor: _FoodMerchantScreenState.blue),
                        icon: const Icon(Icons.arrow_forward, size: 16),
                        label: Text(_primaryActionLabel(target)),
                      ),
                ],
              ),
            ],
            if (busy)
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: LinearProgressIndicator(minHeight: 2),
              ),
          ],
        ),
      );
    }

  String _primaryActionLabel(String status) {
      switch (status) {
        case 'confirmed':
          return 'Accept order';
        case 'preparing':
          return 'Start preparing';
        case 'out_for_delivery':
          return 'Mark out for delivery';
        default:
          return _statusLabel(status);
      }
    }

  Color _statusColor(String status) {
      switch (status) {
        case 'pending':
          return const Color(0xFFB36A00);
        case 'confirmed':
          return const Color(0xFF2E65B0);
        case 'preparing':
          return const Color(0xFF7B4AB1);
        case 'out_for_delivery':
          return const Color(0xFF087F8C);
        case 'delivered':
          return const Color(0xFF16784B);
        case 'cancelled':
          return Colors.red;
        default:
          return _FoodMerchantScreenState.navy;
      }
    }

  Widget _errorState(String message, Future<void> Function() retry) => Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 42, color: _FoodMerchantScreenState.blue),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: retry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );

  Widget _emptyState(
      IconData icon,
      String title,
      String subtitle,
      String action,
      VoidCallback onPressed,
    ) => Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.055),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(icon, size: 38, color: _FoodMerchantScreenState.blue),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _FoodMerchantScreenState.muted),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(backgroundColor: _FoodMerchantScreenState.blue),
              child: Text(action),
            ),
          ],
        ),
      ),
    );
}
