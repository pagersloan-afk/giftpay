part of 'food_ordering_screen.dart';

extension _FoodOrderingApiSection on _FoodOrderingScreenState {

  Uri _uri(String path) => Uri.parse(ApiConfig.api(path));

  Future<Map<String, String>> _headers() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Please sign in to use GiftPay Food.');
    final token = await user.getIdToken();
    if (token == null || token.isEmpty) {
      throw Exception('Unable to authenticate. Please sign in again.');
    }
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Map<String, dynamic> _decode(http.Response response) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {
      throw Exception('Invalid server response (${response.statusCode}).');
    }
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        (body is Map && body['status'] == false)) {
      throw Exception(
        body is Map
            ? (body['message']?.toString() ?? 'Request failed.')
            : 'Request failed (${response.statusCode}).',
      );
    }
    if (body is! Map<String, dynamic>) {
      throw Exception('Unexpected server response.');
    }
    return body;
  }

  String _error(Object e) => e.toString().replaceFirst('Exception: ', '');

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1B2635),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Future<void> _loadMenu() async {
    if (!mounted) return;
    setState(() {
      _loadingMenu = true;
      _menuError = null;
    });
    try {
      final response = await http.get(
        _uri('/api/food/menu'),
        headers: await _headers(),
      );
      final data = _decode(response);
      final raw = data['items'];
      if (raw is! List) throw Exception('Menu response has no items list.');
      if (!mounted) return;
      setState(() {
        _menu = raw
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        _loadingMenu = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _menuError = _error(e);
          _loadingMenu = false;
        });
      }
    }
  }

  Future<void> _loadOrders() async {
    if (!mounted) return;
    setState(() {
      _loadingOrders = true;
      _ordersError = null;
    });
    try {
      final response = await http.get(
        _uri('/api/food/orders'),
        headers: await _headers(),
      );
      final raw = _decode(response)['orders'];
      if (raw is! List) throw Exception('Order response has no orders list.');
      if (!mounted) return;
      setState(() {
        _orders = raw
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        _loadingOrders = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _ordersError = _error(e);
          _loadingOrders = false;
        });
      }
    }
  }
}
