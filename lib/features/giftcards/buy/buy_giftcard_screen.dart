import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';
import 'package:utilityhub/core/widgets/app_responsive_layout.dart';
import 'package:utilityhub/features/giftcards/buy/enter_amount_screen.dart';
import 'package:utilityhub/features/giftcards/models/giftcard_brand.dart';
import 'package:utilityhub/features/giftcards/services/giftcard_service.dart';

class BuyGiftCardScreen extends StatefulWidget {
  const BuyGiftCardScreen({super.key});

  @override
  State<BuyGiftCardScreen> createState() => _BuyGiftCardScreenState();
}

class _BuyGiftCardScreenState extends State<BuyGiftCardScreen> {
  final GiftCardService _service = GiftCardService();

  List<GiftCardBrand> products = [];

  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadCatalog();
  }

  Future<void> loadCatalog() async {
    if (mounted) {
      setState(() {
        loading = true;
        error = null;
      });
    }

    try {
      final result = await _service.getCatalog();

      if (!mounted) return;

      setState(() {
        products = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error = e.toString();
      });
    }
  }

  void openProduct(GiftCardBrand product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EnterGiftCardAmountScreen(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeaderr(title: "Buy Gift Card"),
      body: AppResponsiveLayout(
        child: Padding(padding: const EdgeInsets.all(24), child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                "Unable to load gift cards",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white60),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: loadCatalog,
                child: const Text("Try Again"),
              ),
            ],
          ),
        ),
      );
    }

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.card_giftcard_outlined,
              color: Colors.white54,
              size: 52,
            ),
            const SizedBox(height: 16),
            const Text(
              "No gift cards available",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loadCatalog,
              child: const Text("Refresh"),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: RefreshIndicator(
            onRefresh: loadCatalog,
            child: GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 320,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                mainAxisExtent: 300,
              ),
              itemBuilder: (context, index) {
                final product = products[index];

                return _ProductCard(
                  product: product,
                  onTap: () => openProduct(product),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final GiftCardBrand product;
  final VoidCallback onTap;

  const _ProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final currency = product.currencyCode.isEmpty
        ? ""
        : " ${product.currencyCode}";

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1115),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5).withOpacity(.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.card_giftcard,
                color: Color(0xFF4FC3F7),
                size: 26,
              ),
            ),

            const SizedBox(height: 14),

            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "SKU: ${product.sku}",
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),

            const SizedBox(height: 8),

            Text(
              "${product.minPrice.toStringAsFixed(2)}$currency"
              " - "
              "${product.maxPrice.toStringAsFixed(2)}$currency",
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),

            if (product.preOrder) ...[
              const SizedBox(height: 8),
              const Text(
                "Pre-order",
                style: TextStyle(
                  color: Color(0xFF4FC3F7),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
