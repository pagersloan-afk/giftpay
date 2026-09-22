import 'package:flutter/material.dart';

import 'upload_card_screen.dart';

class EnterTradeDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> giftcard;

  // ============================================================
  // IMPORTANT:
  //
  // When the card-selection screen already knows that this is
  // an E-code, it should pass:
  //
  // isEcode: true
  //
  // That explicit decision becomes the source of truth.
  //
  // It is optional for backwards compatibility with existing
  // navigation code.
  // ============================================================

  final bool? isEcode;

  const EnterTradeDetailsScreen({
    super.key,
    required this.giftcard,
    this.isEcode,
  });

  @override
  State<EnterTradeDetailsScreen> createState() =>
      _EnterTradeDetailsScreenState();
}

class _EnterTradeDetailsScreenState extends State<EnterTradeDetailsScreen> {
  final TextEditingController _amountController = TextEditingController();

  double _amount = 0;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // ============================================================
  // CARD INFORMATION
  // ============================================================

  double get _rate {
    return double.tryParse(widget.giftcard['rate']?.toString() ?? '') ?? 0;
  }

  double get _minimum {
    return double.tryParse(widget.giftcard['minimum']?.toString() ?? '') ?? 0;
  }

  double get _payout {
    return _amount * _rate;
  }

  String get _name {
    return widget.giftcard['name']?.toString() ?? 'Gift Card';
  }

  String get _country {
    return widget.giftcard['country']?.toString().trim() ?? '';
  }

  String get _categoryName {
    final category = widget.giftcard['category'];

    if (category is Map) {
      return category['name']?.toString() ?? _name;
    }

    return _name;
  }

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
  // PRIORITY:
  //
  // 1. Explicit isEcode passed from the previous screen.
  // 2. Prestmit form.
  // 3. Card name.
  // 4. Category/subcategory name.
  // 5. Terms.
  //
  // The explicit value always wins.
  // ============================================================

  bool get _isEcode {
    // ----------------------------------------------------------
    // 1. EXPLICIT SELECTION
    // ----------------------------------------------------------
    //
    // This is now the primary source of truth.
    //
    // If SelectCardTypeScreen says this is E-code, we do not
    // reinterpret it here.
    // ----------------------------------------------------------

    if (widget.isEcode != null) {
      return widget.isEcode!;
    }

    // ----------------------------------------------------------
    // 2. PRESTMIT FORM
    // ----------------------------------------------------------

    final form = widget.giftcard['form']?.toString().trim() ?? '';

    final normalizedForm = _normalizeForm(form);

    if (normalizedForm == 'ecode' ||
        normalizedForm == 'digital' ||
        normalizedForm.contains('ecode')) {
      return true;
    }

    // ----------------------------------------------------------
    // 3. CARD NAME
    // ----------------------------------------------------------

    final name = widget.giftcard['name']?.toString().trim() ?? '';

    final normalizedName = _normalizeForm(name);

    if (normalizedName.contains('ecode') ||
        normalizedName.contains('digitalcode') ||
        normalizedName.contains('digitalcard')) {
      return true;
    }

    // ----------------------------------------------------------
    // 4. CATEGORY
    // ----------------------------------------------------------

    final category = widget.giftcard['category'];

    if (category is Map) {
      final categoryName = category['name']?.toString().trim() ?? '';

      final normalizedCategory = _normalizeForm(categoryName);

      if (normalizedCategory.contains('ecode') ||
          normalizedCategory.contains('digitalcode') ||
          normalizedCategory.contains('digitalcard')) {
        return true;
      }
    }

    // ----------------------------------------------------------
    // 5. OTHER POSSIBLE PRODUCT LABELS
    // ----------------------------------------------------------

    final title = widget.giftcard['title']?.toString().trim() ?? '';

    final displayName = widget.giftcard['displayName']?.toString().trim() ?? '';

    final subcategory = widget.giftcard['subcategory']?.toString().trim() ?? '';

    final normalizedTitle = _normalizeForm(title);
    final normalizedDisplayName = _normalizeForm(displayName);
    final normalizedSubcategory = _normalizeForm(subcategory);

    if (normalizedTitle.contains('ecode') ||
        normalizedTitle.contains('digitalcode') ||
        normalizedTitle.contains('digitalcard')) {
      return true;
    }

    if (normalizedDisplayName.contains('ecode') ||
        normalizedDisplayName.contains('digitalcode') ||
        normalizedDisplayName.contains('digitalcard')) {
      return true;
    }

    if (normalizedSubcategory.contains('ecode') ||
        normalizedSubcategory.contains('digitalcode') ||
        normalizedSubcategory.contains('digitalcard')) {
      return true;
    }

    // ----------------------------------------------------------
    // 6. TERMS
    // ----------------------------------------------------------

    final terms = widget.giftcard['terms']?.toString().trim() ?? '';

    final normalizedTerms = _normalizeForm(terms);

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
  // DISPLAY FORM
  // ============================================================

  String get _form {
    // Explicit E-code decision must be reflected in the UI.
    if (_isEcode) {
      return 'E-code';
    }

    final form = widget.giftcard['form']?.toString().trim() ?? '';

    if (form.isNotEmpty) {
      return form;
    }

    return 'Physical';
  }

  // ============================================================
  // CONTINUE
  // ============================================================

  void _continue() {
    if (_amount <= 0) {
      _showError('Enter the card amount.');
      return;
    }

    if (_minimum > 0 && _amount < _minimum) {
      _showError(
        'The minimum amount for this gift card is '
        '${_formatNumber(_minimum)}.',
      );
      return;
    }

    final selectedIsEcode = _isEcode;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UploadCardScreen(
          giftcard: widget.giftcard,

          amount: _amount.toString(),

          rate: _rate.toString(),

          payout: _payout.toString(),

          // IMPORTANT:
          // Preserve the exact decision from this screen.
          isEcode: selectedIsEcode,
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ============================================================
  // NUMBER FORMAT
  // ============================================================

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final isEcode = _isEcode;

    return Scaffold(
      appBar: AppBar(title: const Text('Sell Gift Card')),

      body: ListView(
        padding: const EdgeInsets.all(24),

        children: [
          _buildSelectedCard(),

          const SizedBox(height: 28),

          const Text(
            'Gift Card Amount',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),

          const SizedBox(height: 10),

          TextField(
            controller: _amountController,

            keyboardType: const TextInputType.numberWithOptions(decimal: true),

            decoration: InputDecoration(
              hintText: _minimum > 0
                  ? 'Minimum ${_formatNumber(_minimum)}'
                  : 'Enter amount',

              prefixText: _currencyPrefix,

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),

            onChanged: (value) {
              setState(() {
                _amount = double.tryParse(value.trim()) ?? 0;
              });
            },
          ),

          const SizedBox(height: 24),

          _buildPayoutCard(),

          const SizedBox(height: 18),

          if (isEcode) _buildEcodeNotice() else _buildPhysicalNotice(),

          const SizedBox(height: 18),

          const Text(
            'The displayed payout is an estimate based on the current Prestmit rate. The final payout is determined after verification.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.5),
          ),

          const SizedBox(height: 28),

          SizedBox(
            height: 54,

            child: ElevatedButton(
              onPressed: _continue,

              child: Text(
                isEcode ? 'Continue to E-code' : 'Continue to Upload',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CURRENCY
  // ============================================================

  String get _currencyPrefix {
    final country = _country.toLowerCase();

    if (country.contains('uk') || country.contains('united kingdom')) {
      return '£ ';
    }

    if (country.contains('canada')) {
      return 'CA\$ ';
    }

    if (country.contains('europe') || country.contains('eu')) {
      return '€ ';
    }

    return '\$ ';
  }

  // ============================================================
  // SELECTED CARD
  // ============================================================

  Widget _buildSelectedCard() {
    final category = widget.giftcard['category'];

    final image = category is Map ? category['image']?.toString() : null;

    final isEcode = _isEcode;

    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),

        gradient: const LinearGradient(
          colors: [Color(0xFF1B2431), Color(0xFF10151B)],

          begin: Alignment.topLeft,

          end: Alignment.bottomRight,
        ),

        border: Border.all(color: const Color(0xFF273D68)),
      ),

      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            padding: const EdgeInsets.all(10),

            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.05),

              borderRadius: BorderRadius.circular(15),
            ),

            child: image != null && image.isNotEmpty
                ? Image.network(
                    image,
                    fit: BoxFit.contain,

                    errorBuilder: (_, __, ___) {
                      return const Icon(
                        Icons.card_giftcard,
                        color: Colors.white54,
                        size: 38,
                      );
                    },
                  )
                : const Icon(
                    Icons.card_giftcard,
                    color: Colors.white54,
                    size: 38,
                  ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  _name,

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 6),

                Wrap(
                  spacing: 6,
                  runSpacing: 6,

                  children: [
                    if (_country.isNotEmpty)
                      _InfoTag(icon: Icons.public, text: _country),

                    _InfoTag(
                      icon: isEcode
                          ? Icons.confirmation_number_outlined
                          : Icons.credit_card,

                      text: isEcode ? 'E-code' : _form,

                      highlighted: isEcode,
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  _categoryName,

                  style: const TextStyle(
                    color: Color(0xFF75A1FF),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAYOUT CARD
  // ============================================================

  Widget _buildPayoutCard() {
    return Container(
      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: const Color(0xFF4A6BB8).withOpacity(.08),

        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: const Color(0xFF4A6BB8).withOpacity(.20)),
      ),

      child: Column(
        children: [
          const Text('Current Rate', style: TextStyle(color: Colors.white54)),

          const SizedBox(height: 7),

          Text(
            '₦${_rate.toStringAsFixed(0)} / unit',

            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),

          const SizedBox(height: 22),

          const Text(
            'Estimated payout',
            style: TextStyle(color: Colors.white54),
          ),

          const SizedBox(height: 7),

          Text(
            '₦${_payout.toStringAsFixed(2)}',

            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: Color(0xFF75A1FF),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // E-CODE NOTICE
  // ============================================================

  Widget _buildEcodeNotice() {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xFF4A6BB8).withOpacity(.10),

        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: const Color(0xFF4A6BB8).withOpacity(.25)),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Icon(
            Icons.confirmation_number_outlined,
            color: Color(0xFF75A1FF),
            size: 22,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  'E-code gift card',

                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'You do not need to upload an image. On the next screen, enter the gift card code in the E-code field.',

                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PHYSICAL CARD NOTICE
  // ============================================================

  Widget _buildPhysicalNotice() {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.035),

        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: Colors.white.withOpacity(.08)),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Icon(
            Icons.photo_camera_outlined,
            color: Colors.white60,
            size: 22,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  'Physical gift card',

                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'You will upload clear JPG or PNG images of the gift card on the next screen.',

                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// INFO TAG
// ================================================================

class _InfoTag extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool highlighted;

  const _InfoTag({
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
