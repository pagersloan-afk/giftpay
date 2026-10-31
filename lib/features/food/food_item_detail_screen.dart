part of 'food_ordering_screen.dart';

class FoodItemDetailScreen extends StatefulWidget {
  final Map<String, dynamic> item;
  final int initialQuantity;
  const FoodItemDetailScreen({
    super.key,
    required this.item,
    required this.initialQuantity,
  });
  @override
  State<FoodItemDetailScreen> createState() => _FoodItemDetailScreenState();
}

class _FoodItemDetailScreenState extends State<FoodItemDetailScreen> {
  int _quantity = 1;
  bool _loadingRestaurant = true;
  String? _profileError;
  Map<String, dynamic> _restaurant = {};
  static const _bg = Color(0xFF080C14),
      _surface = Color(0xFF111B2A),
      _blue = Color(0xFF4A6BB8),
      _cyan = Color(0xFF4FC3F7),
      _muted = Color(0xFF9CA8B8),
      _line = Color(0x24FFFFFF);
  String get _name => '${widget.item['name'] ?? 'Food item'}'.trim();
  String get _description =>
      '${widget.item['description'] ?? 'Freshly prepared by our restaurant.'}'
          .trim();
  String get _image => '${widget.item['imageUrl'] ?? ''}'.trim();
  String get _category => '${widget.item['category'] ?? 'Meals'}'.trim();
  double get _price =>
      num.tryParse('${widget.item['price'] ?? 0}')?.toDouble() ?? 0;
  bool get _accepting => _restaurant['acceptingOrders'] != false;
  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity < 1 ? 1 : widget.initialQuantity;
    _loadRestaurantProfile();
  }

  Future<void> _loadRestaurantProfile() async {
    try {
      final merchantUid = '${widget.item['merchantUid'] ?? ''}'.trim();
      if (merchantUid.isEmpty) {
        throw Exception(
          'This food item is missing its restaurant owner information.',
        );
      }
      final user = FirebaseAuth.instance.currentUser;
      if (user == null)
        throw Exception('Please sign in to view restaurant details.');
      final token = await user.getIdToken();
      if (token == null || token.isEmpty)
        throw Exception('Unable to authenticate. Please sign in again.');
      final response = await http.get(
        Uri.parse(ApiConfig.api('/api/food/restaurant/profile')).replace(
          queryParameters: {
            'merchantUid': '${widget.item['merchantUid'] ?? ''}'.trim(),
          },
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      dynamic body;
      try {
        body = jsonDecode(response.body);
      } catch (_) {
        throw Exception('Invalid restaurant profile response.');
      }
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          (body is Map && body['status'] == false)) {
        throw Exception(
          body is Map
              ? '${body['message'] ?? 'Unable to load restaurant profile.'}'
              : 'Unable to load restaurant profile.',
        );
      }
      if (body is! Map)
        throw Exception('Unexpected restaurant profile response.');
      final raw = body['settings'] ?? body['profile'] ?? body['restaurant'];
      if (!mounted) return;
      setState(() {
        _restaurant = raw is Map ? Map<String, dynamic>.from(raw) : {};
        _loadingRestaurant = false;
        _profileError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingRestaurant = false;
        _profileError = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  String _field(String key) => '${_restaurant[key] ?? ''}'.trim();
  String _money(num n) => '₦${n.toStringAsFixed(n % 1 == 0 ? 0 : 2)}';

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 700;
    final restaurantName = _field('restaurantName').isEmpty
        ? 'GiftPay Food restaurant'
        : _field('restaurantName');
    final logo = _field('logoUrl');
    final unavailable =
        widget.item['active'] == false ||
        (!_loadingRestaurant && _restaurant.isNotEmpty && !_accepting);
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Food details',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: AppResponsiveLayout(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1050),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                compact ? 16 : 28,
                10,
                compact ? 16 : 28,
                30,
              ),
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    height: compact ? 245 : 390,
                    color: _surface,
                    child: _image.startsWith('https://')
                        ? Image.network(
                            _image,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(
                                Icons.restaurant,
                                color: _cyan,
                                size: 70,
                              ),
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.restaurant,
                              color: _cyan,
                              size: 70,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _pill(_category, _cyan),
                ),
                const SizedBox(height: 12),
                Text(
                  _name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 27 : 35,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _money(_price),
                  style: TextStyle(
                    color: _cyan,
                    fontSize: compact ? 25 : 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (_description.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    _description,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 15,
                      height: 1.65,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: _line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'RESTAURANT',
                        style: TextStyle(
                          color: _cyan,
                          fontSize: 11,
                          letterSpacing: 1.6,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
                              width: 64,
                              height: 64,
                              color: Colors.white.withOpacity(.06),
                              child: logo.startsWith('https://')
                                  ? Image.network(
                                      logo,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.storefront,
                                        color: _cyan,
                                        size: 30,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.storefront,
                                      color: _cyan,
                                      size: 30,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  restaurantName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                if (_loadingRestaurant)
                                  const Text(
                                    'Loading restaurant profile…',
                                    style: TextStyle(
                                      color: _muted,
                                      fontSize: 12,
                                    ),
                                  )
                                else
                                  _pill(
                                    _accepting
                                        ? 'Accepting orders'
                                        : 'Temporarily unavailable',
                                    _accepting
                                        ? const Color(0xFF43D9A3)
                                        : const Color(0xFFFFC66D),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (_profileError != null && _restaurant.isEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Restaurant profile could not be loaded: $_profileError',
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _loadRestaurantProfile,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                      if (_field('description').isNotEmpty) ...[
                        const SizedBox(height: 15),
                        Text(
                          _field('description'),
                          style: const TextStyle(color: _muted, height: 1.55),
                        ),
                      ],
                      _restaurantInfo(
                        Icons.location_on_outlined,
                        'Address',
                        _field('address'),
                      ),
                      _restaurantInfo(
                        Icons.schedule,
                        'Opening hours',
                        _field('openingHours'),
                      ),
                      _restaurantInfo(
                        Icons.phone_outlined,
                        'Phone',
                        _field('phone'),
                      ),
                      _restaurantInfo(
                        Icons.email_outlined,
                        'Email',
                        _field('email'),
                      ),
                      _restaurantInfo(
                        Icons.delivery_dining_outlined,
                        'Delivery / pickup',
                        _field('deliveryNotes'),
                      ),
                      _socialLink(
                        Icons.facebook,
                        'Facebook',
                        _field('facebookUrl'),
                      ),
                      _socialLink(
                        Icons.camera_alt_outlined,
                        'Instagram',
                        _field('instagramUrl'),
                      ),
                      _socialLink(
                        Icons.music_note_rounded,
                        'TikTok',
                        _field('tiktokUrl'),
                      ),
                      _socialLink(
                        Icons.business_center_outlined,
                        'LinkedIn',
                        _field('linkedinUrl'),
                      ),
                      _socialLink(
                        Icons.play_circle_outline_rounded,
                        'YouTube',
                        _field('youtubeUrl'),
                      ),
                      _socialLink(
                        Icons.alternate_email_rounded,
                        'X',
                        _field('xUrl'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Restored customer entry point: this is the original Ask portal
                // for asking the restaurant about this specific food item.
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _cyan.withOpacity(.35)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: _cyan.withOpacity(.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.chat_bubble_outline_rounded,
                          color: _cyan,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Have a question?',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Ask the restaurant about this meal before ordering.',
                              style: TextStyle(
                                color: _muted,
                                height: 1.35,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed:
                            _loadingRestaurant || _field('merchantUid').isEmpty
                            ? null
                            : _openFoodChat,
                        icon: const Icon(Icons.forum_outlined, size: 18),
                        label: const Text('Ask'),
                        style: FilledButton.styleFrom(
                          backgroundColor: _cyan,
                          foregroundColor: const Color(0xFF08111C),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _line),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Quantity',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          _qtyButton(
                            Icons.remove,
                            _quantity > 1
                                ? () => setState(() => _quantity--)
                                : null,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              '$_quantity',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          _qtyButton(
                            Icons.add,
                            _quantity < 99
                                ? () => setState(() => _quantity++)
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: unavailable
                              ? null
                              : () => Navigator.of(context).pop(_quantity),
                          style: FilledButton.styleFrom(
                            backgroundColor: _blue,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.white12,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          icon: const Icon(Icons.shopping_bag_outlined),
                          label: Text(
                            widget.item['active'] == false
                                ? 'Item unavailable'
                                : (!_loadingRestaurant &&
                                      _restaurant.isNotEmpty &&
                                      !_accepting)
                                ? 'Restaurant not accepting orders'
                                : 'Add to basket · ${_money(_price * _quantity)}',
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openFoodChat() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to ask the restaurant a question.'),
        ),
      );
      return;
    }
    final merchantUid = _field('merchantUid');
    if (merchantUid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Restaurant chat is unavailable right now. Please try again shortly.',
          ),
        ),
      );
      return;
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => FoodItemChatScreen(
          item: widget.item,
          merchantUid: merchantUid,
          merchantName: _field('restaurantName').isEmpty
              ? 'GiftPay Food restaurant'
              : _field('restaurantName'),
          merchantLogoUrl: _field('logoUrl'),
        ),
      ),
    );
  }

  Widget _pill(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: color.withOpacity(.12),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: color.withOpacity(.3)),
    ),
    child: Text(
      text,
      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800),
    ),
  );
  Widget _restaurantInfo(IconData icon, String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _cyan, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: _muted, fontSize: 11),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(color: Colors.white, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialLink(IconData icon, String label, String url) {
    if (url.isEmpty) return const SizedBox.shrink();
    final uri = Uri.tryParse(url);
    final valid =
        uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host.isNotEmpty;
    if (!valid) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 11),
      child: InkWell(
        onTap: () async {
          try {
            await launchUrl(uri!, mode: LaunchMode.externalApplication);
          } catch (_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Unable to open $label link.')),
              );
            }
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: _cyan, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(color: _muted, fontSize: 11),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    url,
                    style: const TextStyle(
                      color: _cyan,
                      height: 1.4,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.open_in_new_rounded, color: _muted, size: 15),
          ],
        ),
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback? onTap) => IconButton(
    onPressed: onTap,
    icon: Icon(icon),
    style: IconButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: Colors.white.withOpacity(.07),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
