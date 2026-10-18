import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:utilityhub/config/api.dart';
import 'package:utilityhub/core/widgets/app_responsive_layout.dart';
import 'package:utilityhub/core/widgets/giftpay_background.dart';
import 'package:utilityhub/features/food/food_merchant_access.dart';

/// Merchant dashboard for the current single-restaurant GiftPay Food setup.
/// Uses the existing Firebase-authenticated /api/food merchant endpoints.
part 'food_merchant_sections/food_merchant_api_section.dart';
part 'food_merchant_sections/food_merchant_settings_section.dart';
part 'food_merchant_sections/food_merchant_menu_section.dart';
part 'food_merchant_sections/food_merchant_orders_section.dart';

class FoodMerchantScreen extends StatefulWidget {
  const FoodMerchantScreen({super.key});

  @override
  State<FoodMerchantScreen> createState() => _FoodMerchantScreenState();
}

class _FoodMerchantScreenState extends State<FoodMerchantScreen>
    with SingleTickerProviderStateMixin {
  static const navy = Color(0xFF0F1115);
  static const deep = Color(0xFF05070A);
  static const surface = Color(0xFF101827);
  static const blue = Color(0xFF0A4D9C);
  static const cyan = Color(0xFF4FC3F7);
  static const muted = Color(0xFF9CA8B8);
  static const line = Color(0x24FFFFFF);

  BoxDecoration _glass({double opacity = .075, double radius = 20}) =>
      BoxDecoration(
        color: Colors.white.withOpacity(opacity),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.12),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      );

  late final TabController _tabs;
  final _picker = ImagePicker();
  List<Map<String, dynamic>> _menu = [];
  List<Map<String, dynamic>> _orders = [];
  bool _loadingMenu = true;
  bool _loadingOrders = true;
  String? _menuError;
  String? _ordersError;
  bool _saving = false;
  String? _busyOrderId;
  bool _checkingAccess = true;
  bool _accessGranted = false;
  String? _accessError;
  Map<String, dynamic> _restaurantSettings = {};
  bool _loadingSettings = true;
  String? _settingsError;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _initializeMerchantDashboard();
  }

  Future<void> _initializeMerchantDashboard() async {
    try {
      final allowed = await FoodMerchantAccess.check();
      if (!mounted) return;
      if (!allowed) {
        setState(() {
          _checkingAccess = false;
          _accessGranted = false;
        });
        return;
      }
      setState(() {
        _checkingAccess = false;
        _accessGranted = true;
      });
      await Future.wait([
        _loadMenu(),
        _loadOrders(),
        _loadRestaurantSettings(),
      ]);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _checkingAccess = false;
        _accessGranted = false;
        _accessError = _error(e);
      });
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingAccess) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: GiftPayBackground(
          child: Center(child: CircularProgressIndicator(color: cyan)),
        ),
      );
    }
    if (!_accessGranted) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: navy,
          foregroundColor: Colors.white,
          title: const Text('GiftPay Food'),
        ),
        body: GiftPayBackground(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: _glass(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      size: 58,
                      color: cyan,
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Merchant access required',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _accessError ??
                          'This account is not authorized to manage GiftPay Food.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: muted),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: blue),
                      onPressed: () => Navigator.maybePop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text('Go back'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    final liveItems = _menu.where((item) => item['active'] == true).length;
    final pendingOrders = _orders
        .where((order) => order['status'] == 'pending')
        .length;
    return Theme(
      data: Theme.of(context).copyWith(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: const ColorScheme.dark(
          primary: cyan,
          secondary: blue,
          surface: surface,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: navy,
          surfaceTintColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GiftPay Food',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              Text(
                'Merchant dashboard',
                style: TextStyle(
                  fontSize: 11,
                  color: muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Refresh dashboard',
              onPressed: () {
                _loadMenu();
                _loadOrders();
                _loadRestaurantSettings();
              },
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
          bottom: TabBar(
            controller: _tabs,
            labelColor: Colors.white,
            unselectedLabelColor: muted,
            indicatorColor: cyan,
            tabs: [
              Tab(
                icon: const Icon(Icons.restaurant_menu_rounded),
                text: 'Menu ($liveItems live)',
              ),
              Tab(
                icon: const Icon(Icons.receipt_long_rounded),
                text:
                    'Orders${pendingOrders > 0 ? ' ($pendingOrders new)' : ''}',
              ),
              const Tab(
                icon: Icon(Icons.storefront_rounded),
                text: 'Restaurant',
              ),
            ],
          ),
        ),
        body: GiftPayBackground(
          child: AppResponsiveLayout(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Row(
                    children: [
                      _statCard(
                        'Menu items',
                        '${_menu.length}',
                        Icons.restaurant_rounded,
                        cyan,
                      ),
                      const SizedBox(width: 10),
                      _statCard(
                        'New orders',
                        '$pendingOrders',
                        Icons.notifications_active_outlined,
                        const Color(0xFFFFC66D),
                      ),
                      const SizedBox(width: 10),
                      _statCard(
                        'Delivered',
                        '${_orders.where((o) => o['status'] == 'delivered').length}',
                        Icons.check_circle_outline_rounded,
                        const Color(0xFF43D9A3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: TabBarView(
                    controller: _tabs,
                    children: [_menuTab(), _ordersTab(), _settingsTab()],
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: AnimatedBuilder(
          animation: _tabs,
          builder: (_, __) => _tabs.index == 0
              ? FloatingActionButton.extended(
                  backgroundColor: blue,
                  foregroundColor: Colors.white,
                  onPressed: _saving ? null : () => _saveMenuItem(),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add food item'),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
