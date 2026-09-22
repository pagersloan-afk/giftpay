import 'package:flutter/material.dart';

import 'package:utilityhub/core/widgets/app_responsive_layout.dart';

import '../services/giftcard_trade_service.dart';
import 'select_card_type_screen.dart';

class TradeGiftCardHomeScreen extends StatefulWidget {
  const TradeGiftCardHomeScreen({super.key});

  @override
  State<TradeGiftCardHomeScreen> createState() =>
      _TradeGiftCardHomeScreenState();
}

class _TradeGiftCardHomeScreenState extends State<TradeGiftCardHomeScreen> {
  final GiftCardTradeService _service = GiftCardTradeService();

  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _sellableGiftcards = [];

  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadRates();
  }

  Future<void> _loadRates() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await _service.getRateCalculatorData();

      final raw = response['data'];
      final data = raw is Map ? Map<String, dynamic>.from(raw) : response;

      final rawCategories = data['giftCardCategories'];
      final rawSellable = data['sellableGiftcards'];

      if (rawSellable is! List) {
        throw Exception('No sellable gift cards were returned.');
      }

      final sellable = rawSellable
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      final categories = <Map<String, dynamic>>[];

      if (rawCategories is List) {
        categories.addAll(
          rawCategories.whereType<Map>().map(
            (item) => Map<String, dynamic>.from(item),
          ),
        );
      }

      // Some Prestmit responses may contain category information
      // only inside sellableGiftcards. Build missing categories from
      // that information as a fallback.
      final existingCategoryIds = <String>{
        for (final category in categories) category['id']?.toString() ?? '',
      };

      for (final giftcard in sellable) {
        final category = giftcard['category'];

        if (category is! Map) {
          continue;
        }

        final categoryMap = Map<String, dynamic>.from(category);
        final id = categoryMap['id']?.toString() ?? '';

        if (id.isEmpty || existingCategoryIds.contains(id)) {
          continue;
        }

        categories.add(categoryMap);
        existingCategoryIds.add(id);
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _categories = categories;
        _sellableGiftcards = sellable;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  List<Map<String, dynamic>> get _filteredCategories {
    final query = _search.trim().toLowerCase();

    if (query.isEmpty) {
      return _categories;
    }

    return _categories.where((category) {
      final name = category['name']?.toString().toLowerCase() ?? '';

      return name.contains(query);
    }).toList();
  }

  List<Map<String, dynamic>> _sellableForCategory(
    Map<String, dynamic> category,
  ) {
    final categoryId = category['id']?.toString();
    final categoryName = category['name']?.toString().toLowerCase();

    return _sellableGiftcards.where((giftcard) {
      final nestedCategory = giftcard['category'];

      if (nestedCategory is Map) {
        final nestedId = nestedCategory['id']?.toString();
        final nestedName = nestedCategory['name']?.toString().toLowerCase();

        if (categoryId != null &&
            categoryId.isNotEmpty &&
            nestedId == categoryId) {
          return true;
        }

        if (categoryName != null &&
            categoryName.isNotEmpty &&
            nestedName == categoryName) {
          return true;
        }
      }

      return false;
    }).toList();
  }

  void _openCategory(Map<String, dynamic> category) {
    final options = _sellableForCategory(category);

    if (options.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'There are currently no sellable options for this gift card.',
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectCardTypeScreen(
          category: category,
          sellableGiftcards: options,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sell Gift Cards'),
        backgroundColor: Colors.black,
      ),
      body: AppResponsiveLayout(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _loadRates, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (_categories.isEmpty) {
      return const Center(
        child: Text('No gift card categories are currently available.'),
      );
    }

    final categories = _filteredCategories;

    return RefreshIndicator(
      onRefresh: _loadRates,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Sell Gift Cards',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose the brand of the gift card you want to sell.',
            style: TextStyle(color: Colors.white60, height: 1.5),
          ),
          const SizedBox(height: 22),
          TextField(
            onChanged: (value) {
              setState(() {
                _search = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search gift cards',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _search.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          _search = '';
                        });
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (categories.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 60),
              child: Center(child: Text('No matching gift cards found.')),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 260,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
                childAspectRatio: 1.05,
              ),
              itemBuilder: (_, index) {
                final category = categories[index];

                return _GiftCardCategoryCard(
                  category: category,
                  onTap: () => _openCategory(category),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _GiftCardCategoryCard extends StatefulWidget {
  final Map<String, dynamic> category;
  final VoidCallback onTap;

  const _GiftCardCategoryCard({required this.category, required this.onTap});

  @override
  State<_GiftCardCategoryCard> createState() => _GiftCardCategoryCardState();
}

class _GiftCardCategoryCardState extends State<_GiftCardCategoryCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final name = widget.category['name']?.toString() ?? 'Gift Card';

    final image = widget.category['image']?.toString();

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _hovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hovering = false;
        });
      },
      child: AnimatedScale(
        scale: _hovering ? 1.025 : 1,
        duration: const Duration(milliseconds: 180),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF1A1F25), Color(0xFF0D1117)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: _hovering
                    ? const Color(0xFF4A6BB8).withOpacity(.55)
                    : Colors.white.withOpacity(.08),
              ),
              boxShadow: _hovering
                  ? [
                      BoxShadow(
                        color: const Color(0xFF4A6BB8).withOpacity(.14),
                        blurRadius: 24,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 70,
                  width: 70,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.05),
                    shape: BoxShape.circle,
                  ),
                  child: image != null && image.isNotEmpty
                      ? Image.network(
                          image,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) {
                            return const Icon(
                              Icons.card_giftcard,
                              size: 42,
                              color: Colors.white54,
                            );
                          },
                        )
                      : const Icon(
                          Icons.card_giftcard,
                          size: 42,
                          color: Colors.white54,
                        ),
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'View available cards',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
