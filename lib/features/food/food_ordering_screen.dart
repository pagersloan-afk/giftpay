import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:utilityhub/config/api.dart';
import 'package:utilityhub/core/widgets/app_responsive_layout.dart';
import 'package:utilityhub/core/widgets/giftpay_background.dart';
import 'package:utilityhub/features/food/food_merchant_access.dart';
import 'package:utilityhub/features/food/food_merchant_screen.dart';

part 'food_item_detail_screen.dart';
part 'food_ordering_access_section.dart';
part 'food_ordering_api_section.dart';
part 'food_ordering_cart_section.dart';
part 'food_ordering_orders_section.dart';

/// Customer-facing GiftPay Food screen connected to /api/food.
/// Uses GiftPay's authenticated dark visual system while keeping the existing
/// backend contract, Firebase authentication, wallet checkout and order flow.
class FoodOrderingScreen extends StatefulWidget {
  const FoodOrderingScreen({super.key});

  @override
  State<FoodOrderingScreen> createState() => _FoodOrderingScreenState();
}

class _FoodOrderingScreenState extends State<FoodOrderingScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final Map<String, int> _cart = {};
  final _address = TextEditingController();
  final _phone = TextEditingController();
  final _notes = TextEditingController();

  List<Map<String, dynamic>> _menu = [];
  List<Map<String, dynamic>> _orders = [];
  bool _loadingMenu = true, _loadingOrders = false, _placing = false;
  String? _menuError, _ordersError;
  String _search = '', _category = 'All';
  String? _deliveryCode, _createdOrderId;
  bool _isFoodMerchant = false;

  static const navy = Color(0xFF0F1115);
  static const deep = Color(0xFF05070A);
  static const surface = Color(0xFF101827);
  static const blue = Color(0xFF0A4D9C);
  static const cyan = Color(0xFF4FC3F7);
  static const muted = Color(0xFF9CA8B8);
  static const line = Color(0x24FFFFFF);

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this)..addListener(_tabChanged);
    _loadMenu();
    _checkMerchantAccess();
  }

  @override
  void dispose() {
    _tabs.removeListener(_tabChanged);
    _tabs.dispose();
    _address.dispose();
    _phone.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: Theme.of(context).copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: Theme.of(context).colorScheme.copyWith(
        brightness: Brightness.dark,
        primary: cyan,
        secondary: blue,
        surface: const Color(0xFF101722),
        onSurface: Colors.white,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: Color(0xFF8D9AAF),
        indicatorColor: Color(0xFF4FC3F7),
        dividerColor: Colors.transparent,
      ),
    ),
    child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1115),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        titleSpacing: 20,
        title: const Row(
          children: [
            Icon(Icons.restaurant_menu_rounded, color: cyan, size: 23),
            SizedBox(width: 10),
            Text(
              'GiftPay Food',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: -.2,
              ),
            ),
          ],
        ),
        actions: [
          if (_isFoodMerchant)
            IconButton(
              tooltip: 'Merchant dashboard',
              onPressed: _openMerchantDashboard,
              icon: const Icon(Icons.storefront_rounded, color: cyan),
            ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => _tabs.index == 0 ? _loadMenu() : _loadOrders(),
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorSize: TabBarIndicatorSize.label,
          indicatorWeight: 3,
          tabs: const [
            Tab(
              icon: Icon(Icons.restaurant_rounded, size: 19),
              text: 'Order food',
            ),
            Tab(
              icon: Icon(Icons.receipt_long_rounded, size: 19),
              text: 'My orders',
            ),
          ],
        ),
      ),
      body: GiftPayBackground(
        child: AppResponsiveLayout(
          child: TabBarView(
            controller: _tabs,
            children: [_menuTab(), _ordersTab()],
          ),
        ),
      ),
      floatingActionButton: _tabs.index == 0 && _count > 0
          ? FloatingActionButton.extended(
              backgroundColor: blue,
              foregroundColor: Colors.white,
              elevation: 8,
              onPressed: _showCart,
              icon: const Icon(Icons.shopping_bag_outlined),
              label: Text('Cart ($_count) · ${_money(_subtotal)}'),
            )
          : null,
    ),
  );
}
