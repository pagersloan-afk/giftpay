import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/giftcard_trade_service.dart';
import 'success_screen.dart';

class UploadCardScreen extends StatefulWidget {
  final Map<String, dynamic> giftcard;
  final String amount;
  final String rate;
  final String payout;
  final bool isEcode;

  const UploadCardScreen({
    super.key,
    required this.giftcard,
    required this.amount,
    required this.rate,
    required this.payout,
    required this.isEcode,
  });

  @override
  State<UploadCardScreen> createState() => _UploadCardScreenState();
}

class _UploadCardScreenState extends State<UploadCardScreen> {
  final ImagePicker _picker = ImagePicker();

  final GiftCardTradeService _service = GiftCardTradeService();

  final TextEditingController _codeController = TextEditingController();

  List<XFile> _images = [];

  bool _submitting = false;

  // ============================================================
  // CARD INFORMATION
  // ============================================================

  String get _brand {
    final category = widget.giftcard['category'];

    if (category is Map) {
      return category['name']?.toString() ??
          widget.giftcard['name']?.toString() ??
          'Gift Card';
    }

    return widget.giftcard['name']?.toString() ?? 'Gift Card';
  }

  String get _country {
    return widget.giftcard['country']?.toString().trim() ?? '';
  }

  String _normalizeForm(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[-_\s]'), '').trim();
  }

  // ============================================================
  // CARD TYPE
  // ============================================================
  //
  // IMPORTANT:
  // widget.isEcode is the explicit decision made by the previous
  // screen. It must take priority over whatever happens to be
  // present in giftcard['form'].
  //
  // This prevents an E-code product from becoming "Physical"
  // simply because the Prestmit object contains an unexpected
  // or missing form value.
  // ============================================================

  String get _cardType {
    // Explicit E-code selection always wins.
    if (widget.isEcode) {
      return 'E-code';
    }

    final form = widget.giftcard['form']?.toString().trim() ?? '';

    if (form.isNotEmpty) {
      final normalized = _normalizeForm(form);

      if (normalized == 'ecode' ||
          normalized == 'digital' ||
          normalized.contains('ecode')) {
        return 'E-code';
      }

      return form;
    }

    return 'Physical';
  }

  String get _giftcardId {
    return widget.giftcard['id']?.toString().trim() ?? '';
  }

  // ============================================================
  // E-CODE DETECTION
  // ============================================================
  //
  // The explicit isEcode value passed from the previous screen
  // is the primary source of truth.
  //
  // Prestmit's form value is only used as a fallback.
  // ============================================================

  bool get _isEcode {
    // PRIMARY SOURCE OF TRUTH
    if (widget.isEcode) {
      return true;
    }

    // FALLBACK: inspect Prestmit form.
    final form = widget.giftcard['form']?.toString().trim() ?? '';

    if (form.isEmpty) {
      return false;
    }

    final normalized = _normalizeForm(form);

    return normalized == 'ecode' ||
        normalized == 'digital' ||
        normalized.contains('ecode');
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  // ============================================================
  // IMAGE PICKER
  // ============================================================

  Future<void> _pickImages() async {
    // E-codes never use image attachments.
    if (_isEcode) {
      return;
    }

    try {
      final selected = await _picker.pickMultiImage(imageQuality: 90);

      if (selected.isEmpty) {
        return;
      }

      if (selected.length > 20) {
        _showError('You can upload a maximum of 20 images.');
        return;
      }

      setState(() {
        _images = selected.take(20).toList();
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showError('Unable to select images.');
    }
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  Future<void> _submit() async {
    if (_giftcardId.isEmpty) {
      _showError('The gift card identifier is missing.');
      return;
    }

    final isEcode = _isEcode;

    final code = _codeController.text.trim();

    // ----------------------------------------------------------
    // E-CODE
    // ----------------------------------------------------------

    if (isEcode) {
      if (code.isEmpty) {
        _showError('Enter your gift card code.');
        return;
      }
    }

    // ----------------------------------------------------------
    // PHYSICAL CARD
    // ----------------------------------------------------------

    if (!isEcode && _images.isEmpty) {
      _showError('Upload at least one gift card image.');
      return;
    }

    if (_submitting) {
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      final trade = await _service.submitTrade(
        giftcardId: _giftcardId,

        brand: _brand,

        country: _country,

        cardType: isEcode ? 'E-code' : 'Physical',

        amount: widget.amount,

        rate: widget.rate,

        expectedPayout: widget.payout,

        payoutMethod: 'NAIRA',

        // Prestmit requires E-codes in the comments field.
        comments: isEcode ? code : null,

        // E-codes MUST NOT send attachments.
        images: isEcode ? const [] : _images,
      );

      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => TradeSuccessScreen(trade: trade)),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showError(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
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
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final isEcode = _isEcode;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEcode ? 'Enter E-code' : 'Upload Gift Card'),
      ),

      body: ListView(
        padding: const EdgeInsets.all(24),

        children: [
          _buildTradeSummary(),

          const SizedBox(height: 28),

          if (isEcode) _buildEcode() else _buildImages(),

          const SizedBox(height: 28),

          SizedBox(
            height: 54,

            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,

              child: _submitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(isEcode ? 'Submit E-code' : 'Submit Trade'),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TRADE SUMMARY
  // ============================================================

  Widget _buildTradeSummary() {
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

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            '$_brand${_country.isNotEmpty ? ' • $_country' : ''}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),

          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            runSpacing: 8,

            children: [
              _SummaryTag(
                icon: isEcode
                    ? Icons.confirmation_number_outlined
                    : Icons.credit_card,

                text: isEcode ? 'E-code' : 'Physical',

                highlighted: isEcode,
              ),

              if (_country.isNotEmpty)
                _SummaryTag(icon: Icons.public, text: _country),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            'Amount: ${_currencySymbolForCountry()}${widget.amount}',
            style: const TextStyle(color: Colors.white60),
          ),

          const SizedBox(height: 5),

          Text(
            'Rate: ₦${widget.rate} / unit',
            style: const TextStyle(color: Colors.white60),
          ),

          const SizedBox(height: 5),

          Text(
            'Estimated payout: ₦${widget.payout}',
            style: const TextStyle(
              color: Color(0xFF75A1FF),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _currencySymbolForCountry() {
    final country = _country.toLowerCase();

    if (country.contains('uk') || country.contains('united kingdom')) {
      return '£';
    }

    if (country.contains('canada')) {
      return 'CA\$';
    }

    if (country.contains('europe') || country.contains('eu')) {
      return '€';
    }

    return '\$';
  }

  // ============================================================
  // E-CODE
  // ============================================================

  Widget _buildEcode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,

      children: [
        Container(
          padding: const EdgeInsets.all(18),

          decoration: BoxDecoration(
            color: const Color(0xFF4A6BB8).withOpacity(.10),

            borderRadius: BorderRadius.circular(18),

            border: Border.all(color: const Color(0xFF4A6BB8).withOpacity(.25)),
          ),

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const Icon(
                Icons.confirmation_number_outlined,
                color: Color(0xFF75A1FF),
                size: 26,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'Enter your gift card E-code',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'No image is required for an E-code. Enter the complete code below.',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          'Gift Card Code',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),

        const SizedBox(height: 10),

        TextField(
          controller: _codeController,

          maxLines: 5,

          textCapitalization: TextCapitalization.none,

          autocorrect: false,

          enableSuggestions: false,

          decoration: InputDecoration(
            labelText: 'Gift Card Code',

            hintText: 'Enter the e-code here',

            alignLabelWithHint: true,

            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          'Your E-code will be submitted to Prestmit in the comments field. No image attachment will be sent.',
          style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.5),
        ),
      ],
    );
  }

  // ============================================================
  // PHYSICAL CARD
  // ============================================================

  Widget _buildImages() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,

      children: [
        const Text(
          'Gift Card Images',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),

        const SizedBox(height: 10),

        OutlinedButton.icon(
          onPressed: _submitting ? null : _pickImages,

          icon: const Icon(Icons.photo_library_outlined),

          label: Text(
            _images.isEmpty
                ? 'Select Gift Card Images'
                : 'Change Images (${_images.length})',
          ),
        ),

        const SizedBox(height: 16),

        if (_images.isEmpty)
          Container(
            padding: const EdgeInsets.all(28),

            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.04),

              borderRadius: BorderRadius.circular(18),

              border: Border.all(color: Colors.white.withOpacity(.08)),
            ),

            child: const Column(
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 48,
                  color: Colors.white38,
                ),

                SizedBox(height: 14),

                Text(
                  'Upload clear photos of your gift card.',
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 8),

                Text(
                  'Maximum 20 images • JPG/PNG • 5MB each',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,

            physics: const NeverScrollableScrollPhysics(),

            itemCount: _images.length,

            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),

            itemBuilder: (_, index) {
              final image = _images[index];

              return _ImagePreview(
                image: image,

                onRemove: () {
                  setState(() {
                    _images.removeAt(index);
                  });
                },
              );
            },
          ),
      ],
    );
  }
}

// ================================================================
// SUMMARY TAG
// ================================================================

class _SummaryTag extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool highlighted;

  const _SummaryTag({
    required this.icon,
    required this.text,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

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
            size: 14,
            color: highlighted ? const Color(0xFF75A1FF) : Colors.white54,
          ),

          const SizedBox(width: 5),

          Text(
            text,
            style: TextStyle(
              color: highlighted ? const Color(0xFFBBD0FF) : Colors.white70,

              fontSize: 11,

              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// IMAGE PREVIEW
// ================================================================

class _ImagePreview extends StatefulWidget {
  final XFile image;
  final VoidCallback onRemove;

  const _ImagePreview({required this.image, required this.onRemove});

  @override
  State<_ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<_ImagePreview> {
  late Future<Uint8List> _bytes;

  @override
  void initState() {
    super.initState();

    _bytes = widget.image.readAsBytes();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),

      child: Stack(
        fit: StackFit.expand,

        children: [
          FutureBuilder<Uint8List>(
            future: _bytes,

            builder: (_, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return Container(
                  color: Colors.black12,

                  child: const Icon(Icons.image),
                );
              }

              return Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,

                errorBuilder: (_, __, ___) {
                  return Container(
                    color: Colors.black12,

                    child: const Icon(Icons.image),
                  );
                },
              );
            },
          ),

          Positioned(
            right: 7,
            top: 7,

            child: CircleAvatar(
              radius: 16,

              backgroundColor: Colors.black.withOpacity(.65),

              child: IconButton(
                padding: EdgeInsets.zero,

                icon: const Icon(Icons.close, size: 18, color: Colors.white),

                onPressed: widget.onRemove,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
