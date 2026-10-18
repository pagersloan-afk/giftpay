part of 'food_ordering_screen.dart';

extension _FoodOrderingCartSection on _FoodOrderingScreenState {
  List<String> get _categories {
    final list =
        _menu
            .map((e) => '${e['category'] ?? 'Meals'}')
            .where((e) => e.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    return ['All', ...list.where((e) => e != 'All')];
  }

  List<Map<String, dynamic>> get _visibleMenu => _menu.where((item) {
    final q = _search.toLowerCase().trim();
    final name = '${item['name'] ?? ''}'.toLowerCase();
    final desc = '${item['description'] ?? ''}'.toLowerCase();

    return (_category == 'All' ||
            '${item['category'] ?? 'Meals'}' == _category) &&
        (q.isEmpty || name.contains(q) || desc.contains(q));
  }).toList();

  Map<String, dynamic>? _item(String id) {
    for (final item in _menu) {
      if ('${item['id'] ?? item['_id'] ?? ''}' == id) {
        return item;
      }
    }
    return null;
  }

  int get _count => _cart.values.fold(0, (a, b) => a + b);

  double get _subtotal {
    var kobo = 0;

    for (final entry in _cart.entries) {
      final price = num.tryParse('${_item(entry.key)?['price']}') ?? 0;
      kobo += (price * 100).round() * entry.value;
    }

    return kobo / 100;
  }

  String _money(num n) => '₦${n.toStringAsFixed(2)}';

  void _qty(String id, int delta) {
    if (id.isEmpty) {
      _toast('Unable to update this item because its ID is missing.');
      return;
    }

    setState(() {
      final next = (_cart[id] ?? 0) + delta;

      if (next <= 0) {
        _cart.remove(id);
      } else {
        _cart[id] = next;
      }
    });
  }

  Future<void> _openFoodItem(Map<String, dynamic> item) async {
    final result = await Navigator.of(context).push<int>(
      MaterialPageRoute<int>(
        builder: (_) => FoodItemDetailScreen(
          item: item,
          initialQuantity: _cart['${item['id'] ?? item['_id'] ?? ''}'] ?? 0,
        ),
      ),
    );

    if (!mounted || result == null || result < 0) return;

    final id = '${item['id'] ?? item['_id'] ?? ''}';

    if (id.isEmpty) {
      _toast('Unable to add this item because its ID is missing.');
      return;
    }

    setState(() {
      if (result == 0) {
        _cart.remove(id);
      } else {
        _cart[id] = result;
      }
    });
  }

  BoxDecoration _glass({double opacity = .075, double radius = 20}) =>
      BoxDecoration(
        color: Colors.white.withOpacity(opacity),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: _FoodOrderingScreenState.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.12),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      );

  Widget _thumb(Map<String, dynamic> item, {double size = 82}) {
    final url = '${item['imageUrl'] ?? ''}';

    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: size,
        height: size,
        color: const Color(0xFF1A2635),
        child: url.startsWith('https://') || url.startsWith('http://')
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.restaurant,
                  color: _FoodOrderingScreenState.cyan,
                  size: 28,
                ),
              )
            : const Icon(
                Icons.restaurant,
                color: _FoodOrderingScreenState.cyan,
                size: 28,
              ),
      ),
    );
  }

  Widget _quantity(String id, int value, {bool compact = false}) {
    final iconSize = compact ? 16.0 : 18.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.06),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _FoodOrderingScreenState.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _quantityButton(
            icon: Icons.remove_rounded,
            size: iconSize,
            onTap: () => _qty(id, -1),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: compact ? 3 : 5),
            child: Text(
              '$value',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          _quantityButton(
            icon: Icons.add_rounded,
            size: iconSize,
            onTap: () => _qty(id, 1),
            accent: true,
          ),
        ],
      ),
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required double size,
    required VoidCallback onTap,
    bool accent = false,
  }) => IconButton(
    visualDensity: VisualDensity.compact,
    constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
    onPressed: onTap,
    icon: Icon(
      icon,
      size: size,
      color: accent ? _FoodOrderingScreenState.cyan : Colors.white70,
    ),
  );

  Widget _menuCard(Map<String, dynamic> item) {
    final id = '${item['id'] ?? item['_id'] ?? ''}';
    final price = num.tryParse('${item['price']}') ?? 0;
    final quantity = _cart[id] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _glass(opacity: .065, radius: 20),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openFoodItem(item),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _thumb(item),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item['name'] ?? 'Food item'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      if ('${item['description'] ?? ''}'.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Text(
                          '${item['description']}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _FoodOrderingScreenState.muted,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Text(
                            _money(price),
                            style: const TextStyle(
                              color: _FoodOrderingScreenState.cyan,
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                          if (quantity == 0)
                            OutlinedButton.icon(
                              onPressed: id.isEmpty ? null : () => _qty(id, 1),
                              icon: const Icon(Icons.add_rounded, size: 16),
                              label: const Text('Add'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _FoodOrderingScreenState.cyan,
                                side: BorderSide(
                                  color: _FoodOrderingScreenState.cyan
                                      .withOpacity(.42),
                                ),
                                visualDensity: VisualDensity.compact,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            )
                          else
                            _quantity(id, quantity, compact: true),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white38,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    String hint, {
    int lines = 1,
    TextInputType? keyboard,
  }) => TextField(
    controller: ctrl,
    maxLines: lines,
    keyboardType: keyboard,
    style: const TextStyle(color: Colors.white),
    cursorColor: _FoodOrderingScreenState.cyan,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(color: Color(0xFF7F8A9A)),
      filled: true,
      fillColor: Colors.white.withOpacity(.055),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: _FoodOrderingScreenState.cyan,
          width: 1.3,
        ),
      ),
    ),
  );

  Future<void> _showCart() async {
    if (_cart.isEmpty) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, refreshSheet) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * .92,
            ),
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              20 + MediaQuery.of(ctx).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF101722),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(26),
              ),
              border: Border.all(color: Colors.white.withOpacity(.12)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Your cart',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close, color: Colors.white70),
                      ),
                    ],
                  ),
                  ..._cart.entries.map((entry) {
                    final item = _item(entry.key);
                    if (item == null) {
                      return const SizedBox.shrink();
                    }

                    final price = num.tryParse('${item['price']}') ?? 0;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        children: [
                          _thumb(item, size: 48),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${item['name']}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          _quantity(entry.key, entry.value, compact: true),
                          const SizedBox(width: 8),
                          Text(
                            _money(price * entry.value),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  }),
                  const Divider(height: 26, color: Colors.white12),
                  _field(
                    _address,
                    'Delivery address',
                    'House number, street, area',
                    lines: 2,
                  ),
                  const SizedBox(height: 12),
                  _field(
                    _phone,
                    'Contact phone',
                    '08012345678',
                    keyboard: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  _field(
                    _notes,
                    'Order notes (optional)',
                    'Delivery instructions',
                    lines: 2,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Food subtotal',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                      Text(
                        _money(_subtotal),
                        style: const TextStyle(
                          color: _FoodOrderingScreenState.cyan,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Delivery fee is configured by the backend and added to the final total.',
                    style: TextStyle(
                      color: _FoodOrderingScreenState.muted,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: _FoodOrderingScreenState.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: _placing
                          ? null
                          : () {
                              Navigator.pop(ctx);
                              _placeOrder();
                            },
                      icon: const Icon(Icons.account_balance_wallet_outlined),
                      label: Text(
                        _placing ? 'Placing order…' : 'Place order from wallet',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _placeOrder() async {
    if (_cart.isEmpty) return;

    if (_address.text.trim().length < 5) {
      _toast('Enter a complete delivery address.');
      return;
    }

    if (!RegExp(r'^[+0-9()\-\s]{7,25}$').hasMatch(_phone.text.trim())) {
      _toast('Enter a valid contact phone number.');
      return;
    }

    setState(() => _placing = true);

    try {
      final key = 'food_${DateTime.now().microsecondsSinceEpoch}';

      final response = await http.post(
        _uri('/api/food/orders'),
        headers: await _headers(),
        body: jsonEncode({
          'idempotencyKey': key,
          'items': _cart.entries
              .map((e) => {'itemId': e.key, 'quantity': e.value})
              .toList(),
          'deliveryAddress': _address.text.trim(),
          'phone': _phone.text.trim(),
          'notes': _notes.text.trim(),
        }),
      );

      final data = _decode(response);

      final order = data['order'] is Map
          ? Map<String, dynamic>.from(data['order'] as Map)
          : <String, dynamic>{};

      if (!mounted) return;

      setState(() {
        _deliveryCode = data['deliveryCode']?.toString();
        _createdOrderId = order['id']?.toString();
        _cart.clear();
        _placing = false;
      });

      _address.clear();
      _phone.clear();
      _notes.clear();

      _tabs.animateTo(1);
      await _loadOrders();

      if (mounted) {
        await _orderPlacedDialog(order);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _placing = false);
      }

      _toast(_error(e));
    }
  }

  Future<void> _orderPlacedDialog(Map<String, dynamic> order) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF111B29),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        icon: const Icon(
          Icons.check_circle,
          color: Color(0xFF43D9A3),
          size: 46,
        ),
        title: const Text(
          'Order placed',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Order ${order['id'] ?? _createdOrderId ?? ''} has been submitted.',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            const Text(
              'Keep this code private and share it only when your delivery arrives.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _FoodOrderingScreenState.muted),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.055),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  const Text(
                    'DELIVERY CODE',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.2,
                      color: _FoodOrderingScreenState.muted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SelectableText(
                    _deliveryCode ?? '',
                    style: const TextStyle(
                      fontSize: 28,
                      letterSpacing: 7,
                      fontWeight: FontWeight.w900,
                      color: _FoodOrderingScreenState.cyan,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(
              backgroundColor: _FoodOrderingScreenState.blue,
            ),
            child: const Text('View my orders'),
          ),
        ],
      ),
    );
  }
}
