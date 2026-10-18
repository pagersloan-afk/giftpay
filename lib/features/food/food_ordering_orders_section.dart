part of 'food_ordering_screen.dart';

extension _FoodOrderingOrdersSection on _FoodOrderingScreenState {
  Future<void> _confirmDelivery(Map<String, dynamic> order) async {
    final ctrl = TextEditingController();
    final id = '${order['id'] ?? ''}';
    if (id.isEmpty) return;
    final code = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF111B29),
        title: const Text(
          'Confirm delivery',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Only confirm after your food has arrived.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              autofocus: true,
              maxLength: 6,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Six-digit delivery code',
                counterText: '',
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            style: FilledButton.styleFrom(
              backgroundColor: _FoodOrderingScreenState.blue,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (code == null) return;
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      _toast('Enter the six-digit delivery code.');
      return;
    }
    try {
      final response = await http.post(
        _uri('/api/food/orders/$id/confirm-delivery'),
        headers: await _headers(),
        body: jsonEncode({'deliveryCode': code}),
      );
      final data = _decode(response);
      _toast(data['message']?.toString() ?? 'Delivery confirmed.');
      await _loadOrders();
    } catch (e) {
      _toast(_error(e));
    }
  }

  Future<void> _refreshOrder(Map<String, dynamic> order) async {
    final id = '${order['id'] ?? ''}';
    if (id.isEmpty) return;
    try {
      _decode(
        await http.get(_uri('/api/food/orders/$id'), headers: await _headers()),
      );
      await _loadOrders();
    } catch (e) {
      _toast(_error(e));
    }
  }

  Widget _errorView(
    String title,
    String message,
    Future<void> Function() retry,
  ) => Center(
    child: Padding(
      padding: const EdgeInsets.all(26),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off,
            size: 46,
            color: _FoodOrderingScreenState.cyan,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _FoodOrderingScreenState.muted),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: retry,
            style: FilledButton.styleFrom(
              backgroundColor: _FoodOrderingScreenState.blue,
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('Try again'),
          ),
        ],
      ),
    ),
  );

  Widget _menuTab() {
    if (_loadingMenu) {
      return const Center(
        child: CircularProgressIndicator(color: _FoodOrderingScreenState.cyan),
      );
    }
    if (_menuError != null) {
      return _errorView('Could not load menu', _menuError!, _loadMenu);
    }

    return RefreshIndicator(
      color: _FoodOrderingScreenState.cyan,
      backgroundColor: _FoodOrderingScreenState.surface,
      onRefresh: _loadMenu,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF173C70),
                  Color(0xFF0A4D9C),
                  Color(0xFF163052),
                ],
              ),
              border: Border.all(color: Colors.white.withOpacity(.13)),
              boxShadow: [
                BoxShadow(
                  color: _FoodOrderingScreenState.blue.withOpacity(.22),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good food, delivered.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                        ),
                      ),
                      SizedBox(height: 9),
                      Text(
                        'Choose your meal and pay securely with your GiftPay wallet.',
                        style: TextStyle(
                          color: Color(0xFFD9E8FF),
                          height: 1.45,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.12),
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(color: Colors.white.withOpacity(.15)),
                  ),
                  child: const Icon(
                    Icons.delivery_dining_rounded,
                    color: Colors.white,
                    size: 31,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 17),
          TextField(
            onChanged: (v) => setState(() => _search = v),
            style: const TextStyle(color: Colors.white),
            cursorColor: _FoodOrderingScreenState.cyan,
            decoration: InputDecoration(
              hintText: 'Search meals',
              hintStyle: const TextStyle(color: Color(0xFF8793A4)),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: _FoodOrderingScreenState.cyan,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(.055),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 15,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.white.withOpacity(.10)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(
                  color: _FoodOrderingScreenState.cyan.withOpacity(.7),
                ),
              ),
            ),
          ),
          const SizedBox(height: 13),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final value = _categories[i];
                final selected = value == _category;
                return ChoiceChip(
                  label: Text(value),
                  selected: selected,
                  onSelected: (_) => setState(() => _category = value),
                  selectedColor: _FoodOrderingScreenState.blue,
                  backgroundColor: Colors.white.withOpacity(.055),
                  side: BorderSide(
                    color: selected
                        ? _FoodOrderingScreenState.cyan.withOpacity(.45)
                        : Colors.white12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : const Color(0xFFB8C2D0),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                  showCheckmark: false,
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Our menu',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.055),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white10),
                ),
                child: Text(
                  '${_visibleMenu.length} items',
                  style: const TextStyle(
                    color: _FoodOrderingScreenState.muted,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          if (_visibleMenu.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 20),
              decoration: _glass(opacity: .04, radius: 18),
              child: const Column(
                children: [
                  Icon(
                    Icons.restaurant_menu_rounded,
                    size: 36,
                    color: _FoodOrderingScreenState.cyan,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'No menu items found.',
                    style: TextStyle(color: _FoodOrderingScreenState.muted),
                  ),
                ],
              ),
            )
          else
            ..._visibleMenu.map(_menuCard),
        ],
      ),
    );
  }

  Widget _status(String value) {
    final normalized = value.toLowerCase();
    final color = normalized == 'delivered'
        ? const Color(0xFF43D9A3)
        : normalized == 'cancelled'
        ? const Color(0xFFFF6B78)
        : normalized == 'out_for_delivery'
        ? _FoodOrderingScreenState.cyan
        : const Color(0xFFFFC66D);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(.22)),
      ),
      child: Text(
        value.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          letterSpacing: .3,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _ordersTab() {
    if (_loadingOrders && _orders.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: _FoodOrderingScreenState.cyan),
      );
    }
    if (_ordersError != null && _orders.isEmpty) {
      return _errorView('Could not load orders', _ordersError!, _loadOrders);
    }
    if (_orders.isEmpty) {
      return RefreshIndicator(
        color: _FoodOrderingScreenState.cyan,
        backgroundColor: _FoodOrderingScreenState.surface,
        onRefresh: _loadOrders,
        child: ListView(
          children: const [
            SizedBox(height: 100),
            Icon(
              Icons.receipt_long_rounded,
              size: 56,
              color: _FoodOrderingScreenState.cyan,
            ),
            SizedBox(height: 12),
            Center(
              child: Text(
                'No orders yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 8),
            Center(
              child: Text(
                'Your orders will appear here.',
                style: TextStyle(color: _FoodOrderingScreenState.muted),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: _FoodOrderingScreenState.cyan,
      backgroundColor: _FoodOrderingScreenState.surface,
      onRefresh: _loadOrders,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (ctx, i) {
          final order = _orders[i];
          final status = '${order['status'] ?? 'pending'}';
          final payment = '${order['paymentStatus'] ?? 'reserved'}';
          final id = '${order['id'] ?? ''}';
          final items = order['items'] is List
              ? order['items'] as List
              : const [];
          final canConfirm =
              status == 'out_for_delivery' && payment == 'reserved';

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: _glass(opacity: .065, radius: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Order ${id.length > 18 ? id.substring(id.length - 18) : id}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    _status(status),
                  ],
                ),
                const SizedBox(height: 13),
                ...items.take(5).whereType<Map>().map((raw) {
                  final item = Map<String, dynamic>.from(raw);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${item['quantity'] ?? 1} × ${item['name'] ?? 'Food item'}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                        Text(
                          _money(num.tryParse('${item['lineTotal']}') ?? 0),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(height: 22, color: Colors.white12),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Total',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _FoodOrderingScreenState.muted,
                        ),
                      ),
                    ),
                    Text(
                      _money(num.tryParse('${order['total']}') ?? 0),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: _FoodOrderingScreenState.cyan,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  'Payment: $payment',
                  style: const TextStyle(
                    color: _FoodOrderingScreenState.muted,
                    fontSize: 12,
                  ),
                ),
                if ('${order['deliveryAddress'] ?? ''}'.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    'Deliver to: ${order['deliveryAddress']}',
                    style: const TextStyle(
                      color: _FoodOrderingScreenState.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _refreshOrder(order),
                      icon: const Icon(Icons.refresh_rounded, size: 17),
                      label: const Text('Refresh status'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _FoodOrderingScreenState.cyan,
                        side: BorderSide(
                          color: _FoodOrderingScreenState.cyan.withOpacity(.35),
                        ),
                      ),
                    ),
                    if (canConfirm)
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: _FoodOrderingScreenState.blue,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => _confirmDelivery(order),
                        icon: const Icon(Icons.verified_outlined, size: 17),
                        label: const Text('Confirm delivery'),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
