part of 'food_ordering_screen.dart';

extension _FoodOrderingAccessSection on _FoodOrderingScreenState {

  Future<void> _checkMerchantAccess() async {
    debugPrint('[GiftPay Food] Starting merchant access check.');
    try {
      final allowed = await FoodMerchantAccess.check();
      debugPrint('[GiftPay Food] Merchant access result: isMerchant=$allowed');
      if (!mounted) return;
      setState(() => _isFoodMerchant = allowed);
      if (!allowed) {
        debugPrint(
          '[GiftPay Food] Access denied by the API. The merchant icon stays hidden.',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('[GiftPay Food] Merchant access check FAILED: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      setState(() => _isFoodMerchant = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Merchant access check failed: ${e.toString().replaceFirst('Exception: ', '')}'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 8),
        ),
      );
    }
  }

  Future<void> _openMerchantDashboard() async {
    try {
      final allowed = await FoodMerchantAccess.check();
      if (!mounted) return;
      if (!allowed) {
        setState(() => _isFoodMerchant = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'This account is not authorized to manage GiftPay Food.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const FoodMerchantScreen()));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _tabChanged() {
    if (mounted) setState(() {});
    if (_tabs.index == 1 && !_tabs.indexIsChanging) _loadOrders();
  }
}
