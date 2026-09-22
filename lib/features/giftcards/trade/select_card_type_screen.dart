import 'package:flutter/material.dart';

import 'enter_details_screen.dart';

class SelectCardTypeScreen extends StatefulWidget {
  final Map<String, dynamic> category;
  final List<Map<String, dynamic>> sellableGiftcards;

  const SelectCardTypeScreen({
    super.key,
    required this.category,
    required this.sellableGiftcards,
  });

  @override
  State<SelectCardTypeScreen> createState() => _SelectCardTypeScreenState();
}

class _SelectCardTypeScreenState extends State<SelectCardTypeScreen> {
  String _search = '';
  String _countryFilter = 'All Countries';
  String _formFilter = 'All Forms';

  // ============================================================
  // FORM NORMALIZATION
  // ============================================================

  String _normalizeForm(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[-_\s]'), '').trim();
  }

  // ============================================================
  // E-CODE DETECTION
  // ============================================================
  //
  // This determines the card type ONCE at the card-selection
  // stage.
  //
  // That result is then explicitly passed to the next screen.
  // ============================================================

  bool _isEcode(Map<String, dynamic> giftcard) {
    final form = giftcard['form']?.toString().trim() ?? '';

    final name = giftcard['name']?.toString().trim() ?? '';

    final terms = giftcard['terms']?.toString().trim() ?? '';

    final normalizedForm = _normalizeForm(form);

    final normalizedName = _normalizeForm(name);

    final normalizedTerms = _normalizeForm(terms);

    // ----------------------------------------------------------
    // 1. EXPLICIT PRESTMIT FORM
    // ----------------------------------------------------------

    if (normalizedForm == 'ecode' ||
        normalizedForm == 'digital' ||
        normalizedForm.contains('ecode')) {
      return true;
    }

    // ----------------------------------------------------------
    // 2. CARD NAME
    // ----------------------------------------------------------

    if (normalizedName.contains('ecode') ||
        normalizedName.contains('digitalcode') ||
        normalizedName.contains('digitalcard')) {
      return true;
    }

    // ----------------------------------------------------------
    // 3. TERMS
    // ----------------------------------------------------------

    if (normalizedTerms.contains('entercodeinthecomments') ||
        normalizedTerms.contains('codeinthecomments')) {
      return true;
    }

    if (normalizedTerms.contains('enter') &&
        normalizedTerms.contains('code') &&
        normalizedTerms.contains('comments')) {
      return true;
    }

    return false;
  }

  // ============================================================
  // RESOLVED FORM
  // ============================================================

  String _resolvedForm(Map<String, dynamic> giftcard) {
    // IMPORTANT:
    // Resolve E-code FIRST.
    //
    // This prevents a misleading/incorrect form value from
    // overriding the actual E-code identification.
    if (_isEcode(giftcard)) {
      return 'E-code';
    }

    final originalForm = giftcard['form']?.toString().trim() ?? '';

    if (originalForm.isNotEmpty) {
      return originalForm;
    }

    return 'Physical';
  }

  // ============================================================
  // NORMALIZED GIFTCARD
  // ============================================================

  Map<String, dynamic> _normalizedGiftcard(Map<String, dynamic> giftcard) {
    final normalized = Map<String, dynamic>.from(giftcard);

    final isEcode = _isEcode(giftcard);

    // Store the resolved display form.
    normalized['form'] = isEcode ? 'E-code' : _resolvedForm(giftcard);

    // Store the explicit decision as part of the selected
    // product as well.
    //
    // This gives downstream screens another reliable source.
    normalized['isEcode'] = isEcode;

    return normalized;
  }

  // ============================================================
  // COUNTRIES
  // ============================================================

  List<String> get _countries {
    final values = widget.sellableGiftcards
        .map((item) => item['country']?.toString().trim() ?? '')
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList();

    values.sort();

    return values;
  }

  // ============================================================
  // FORMS
  // ============================================================

  List<String> get _forms {
    final values = widget.sellableGiftcards
        .map((item) => _resolvedForm(item))
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList();

    values.sort();

    return values;
  }

  // ============================================================
  // FILTERED CARDS
  // ============================================================

  List<Map<String, dynamic>> get _filteredCards {
    final query = _search.trim().toLowerCase();

    return widget.sellableGiftcards.where((giftcard) {
      final name = giftcard['name']?.toString().toLowerCase() ?? '';

      final country = giftcard['country']?.toString().trim() ?? '';

      final form = _resolvedForm(giftcard);

      final matchesSearch =
          query.isEmpty ||
          name.contains(query) ||
          country.toLowerCase().contains(query) ||
          form.toLowerCase().contains(query);

      final matchesCountry =
          _countryFilter == 'All Countries' || country == _countryFilter;

      final matchesForm = _formFilter == 'All Forms' || form == _formFilter;

      return matchesSearch && matchesCountry && matchesForm;
    }).toList();
  }

  // ============================================================
  // SELECT CARD
  // ============================================================

  void _selectGiftcard(Map<String, dynamic> giftcard) {
    // Determine the card type RIGHT HERE.
    //
    // For:
    // "USA iTunes ecode"
    //
    // this should be true.
    final isEcode = _isEcode(giftcard);

    // Normalize the selected gift card.
    final normalizedGiftcard = _normalizedGiftcard(giftcard);

    // Safety: make absolutely sure the normalized object
    // contains the same explicit decision.
    normalizedGiftcard['isEcode'] = isEcode;

    debugPrint(
      'GiftPay SELL CARD SELECTED: '
      '${normalizedGiftcard['name']} '
      '| form=${normalizedGiftcard['form']} '
      '| isEcode=$isEcode '
      '| id=${normalizedGiftcard['id']}',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EnterTradeDetailsScreen(
          giftcard: normalizedGiftcard,

          // THIS IS THE IMPORTANT FIX.
          //
          // The next screen no longer has to guess.
          isEcode: isEcode,
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final categoryName = widget.category['name']?.toString() ?? 'Gift Cards';

    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),

      body: ListView(
        padding: const EdgeInsets.all(24),

        children: [
          Text(
            categoryName,

            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),

          const SizedBox(height: 8),

          const Text(
            'Select the exact gift card you have.',
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
              hintText: 'Search card type',

              prefixIcon: const Icon(Icons.search),

              filled: true,

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),

                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 16),

          _buildFilters(),

          const SizedBox(height: 24),

          Text(
            '${_filteredCards.length} available card'
            '${_filteredCards.length == 1 ? '' : 's'}',

            style: const TextStyle(
              color: Colors.white60,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          if (_filteredCards.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 70),

              child: Center(
                child: Text('No matching gift card options found.'),
              ),
            )
          else
            ..._filteredCards.map((giftcard) {
              final normalizedGiftcard = _normalizedGiftcard(giftcard);

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),

                child: _SellableGiftCardOption(
                  giftcard: normalizedGiftcard,

                  onTap: () {
                    _selectGiftcard(giftcard);
                  },
                ),
              );
            }),
        ],
      ),
    );
  }

  // ============================================================
  // FILTERS
  // ============================================================

  Widget _buildFilters() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,

      children: [
        _FilterDropdown(
          label: 'Country',

          value: _countryFilter,

          values: ['All Countries', ..._countries],

          onChanged: (value) {
            setState(() {
              _countryFilter = value;
            });
          },
        ),

        _FilterDropdown(
          label: 'Form',

          value: _formFilter,

          values: ['All Forms', ..._forms],

          onChanged: (value) {
            setState(() {
              _formFilter = value;
            });
          },
        ),
      ],
    );
  }
}

// ================================================================
// SELLABLE GIFT CARD OPTION
// ================================================================

class _SellableGiftCardOption extends StatefulWidget {
  final Map<String, dynamic> giftcard;

  final VoidCallback onTap;

  const _SellableGiftCardOption({required this.giftcard, required this.onTap});

  @override
  State<_SellableGiftCardOption> createState() =>
      _SellableGiftCardOptionState();
}

class _SellableGiftCardOptionState extends State<_SellableGiftCardOption> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final name = widget.giftcard['name']?.toString() ?? 'Gift Card';

    final country = widget.giftcard['country']?.toString().trim() ?? '';

    final form = widget.giftcard['form']?.toString().trim() ?? 'Physical';

    // Because the parent has already normalized the
    // card, this is now safe.
    final isEcode =
        widget.giftcard['isEcode'] == true || form.toLowerCase() == 'e-code';

    final rate = _parseNumber(widget.giftcard['rate']);

    final minimum = _parseNumber(widget.giftcard['minimum']);

    final category = widget.giftcard['category'];

    final image = category is Map ? category['image']?.toString() : null;

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

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),

          color: const Color(0xFF14191F),

          border: Border.all(
            color: _hovering
                ? const Color(0xFF4A6BB8)
                : Colors.white.withOpacity(.08),
          ),

          boxShadow: _hovering
              ? [
                  BoxShadow(
                    color: const Color(0xFF4A6BB8).withOpacity(.12),

                    blurRadius: 24,
                  ),
                ]
              : null,
        ),

        child: InkWell(
          onTap: widget.onTap,

          borderRadius: BorderRadius.circular(18),

          child: Padding(
            padding: const EdgeInsets.all(18),

            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,

                  padding: const EdgeInsets.all(9),

                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.05),

                    borderRadius: BorderRadius.circular(14),
                  ),

                  child: image != null && image.isNotEmpty
                      ? Image.network(
                          image,
                          fit: BoxFit.contain,

                          errorBuilder: (_, __, ___) {
                            return const Icon(
                              Icons.card_giftcard,
                              color: Colors.white54,
                            );
                          },
                        )
                      : const Icon(Icons.card_giftcard, color: Colors.white54),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        name,

                        maxLines: 2,

                        overflow: TextOverflow.ellipsis,

                        style: const TextStyle(
                          color: Colors.white,

                          fontSize: 16,

                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 8,
                        runSpacing: 6,

                        children: [
                          if (country.isNotEmpty)
                            _Tag(icon: Icons.public, text: country),

                          _Tag(
                            icon: isEcode
                                ? Icons.confirmation_number_outlined
                                : Icons.credit_card,

                            text: isEcode ? 'E-code' : form,

                            highlighted: isEcode,
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'Rate  ₦${_formatNumber(rate)} / unit',

                        style: const TextStyle(
                          color: Color(0xFF75A1FF),

                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      if (minimum > 0) ...[
                        const SizedBox(height: 3),

                        Text(
                          'Minimum ${_formatNumber(minimum)}',

                          style: const TextStyle(
                            color: Colors.white54,

                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                const Icon(Icons.chevron_right_rounded, color: Colors.white54),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _parseNumber(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString().trim()) ?? 0;
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toString();
  }
}

// ================================================================
// TAG
// ================================================================

class _Tag extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool highlighted;

  const _Tag({
    required this.icon,
    required this.text,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),

      decoration: BoxDecoration(
        color: highlighted
            ? const Color(0xFF4A6BB8).withOpacity(.18)
            : Colors.white.withOpacity(.05),

        borderRadius: BorderRadius.circular(20),

        border: highlighted
            ? Border.all(color: const Color(0xFF4A6BB8).withOpacity(.35))
            : null,
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          Icon(
            icon,

            size: 13,

            color: highlighted ? const Color(0xFF75A1FF) : Colors.white54,
          ),

          const SizedBox(width: 5),

          Text(
            text,

            style: TextStyle(
              color: highlighted ? const Color(0xFFBBD0FF) : Colors.white70,

              fontSize: 11,

              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// FILTER DROPDOWN
// ================================================================

class _FilterDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 160),

      padding: const EdgeInsets.symmetric(horizontal: 12),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.05),

        borderRadius: BorderRadius.circular(14),

        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),

      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: values.contains(value) ? value : values.first,

          isExpanded: true,

          dropdownColor: const Color(0xFF171C22),

          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,

            color: Colors.white54,
          ),

          items: values
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,

                  child: Text(
                    item == values.first ? label : item,

                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),

          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
        ),
      ),
    );
  }
}
