part of '../food_merchant_screen.dart';

extension _FoodMerchantApiSection on _FoodMerchantScreenState {
  Uri _uri(String path) => Uri.parse(ApiConfig.api(path));

  Future<String> _token() async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null)
        throw Exception('Please sign in with the merchant account.');
      final token = await user.getIdToken();
      if (token == null || token.isEmpty)
        throw Exception('Your session expired. Sign in again.');
      return token;
    }

  Future<Map<String, String>> _headers() async => {
      'Authorization': 'Bearer ${await _token()}',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

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
              ? '${body['message'] ?? 'Request failed.'}'
              : 'Request failed.',
        );
      }
      if (body is! Map<String, dynamic>)
        throw Exception('Unexpected server response.');
      return body;
    }

  String _error(Object e) => e.toString().replaceFirst('Exception: ', '');

  void _toast(String text) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(text),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF1B2635),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
    }

  String _money(dynamic value) =>
        '₦${(num.tryParse('$value') ?? 0).toStringAsFixed(2)}';

  Future<void> _loadMenu() async {
      if (mounted)
        setState(() {
          _loadingMenu = true;
          _menuError = null;
        });
      try {
        final res = await http.get(
          _uri('/api/food/merchant/menu'),
          headers: await _headers(),
        );
        final raw = _decode(res)['items'];
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
        if (mounted)
          setState(() {
            _menuError = _error(e);
            _loadingMenu = false;
          });
      }
    }

  Future<void> _loadOrders() async {
      if (mounted)
        setState(() {
          _loadingOrders = true;
          _ordersError = null;
        });
      try {
        final res = await http.get(
          _uri('/api/food/merchant/orders'),
          headers: await _headers(),
        );
        final raw = _decode(res)['orders'];
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
        if (mounted)
          setState(() {
            _ordersError = _error(e);
            _loadingOrders = false;
          });
      }
    }

  Future<void> _loadRestaurantSettings() async {
      if (mounted)
        setState(() {
          _loadingSettings = true;
          _settingsError = null;
        });
      try {
        final res = await http.get(
          _uri('/api/food/merchant/settings'),
          headers: await _headers(),
        );
        final raw = _decode(res)['settings'];
        if (raw is! Map) throw Exception('Settings response is invalid.');
        if (!mounted) return;
        setState(() {
          _restaurantSettings = Map<String, dynamic>.from(raw);
          _loadingSettings = false;
        });
      } catch (e) {
        if (mounted)
          setState(() {
            _settingsError = _error(e);
            _loadingSettings = false;
          });
      }
    }
}
