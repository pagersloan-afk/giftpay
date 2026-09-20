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
    return widget.giftcard['country']?.toString() ?? '';
  }

  String get _cardType {
    return widget.giftcard['form']?.toString() ?? '';
  }

  String get _giftcardId {
    return widget.giftcard['id']?.toString() ?? '';
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
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
    } catch (error) {
      _showError('Unable to select images.');
    }
  }

  Future<void> _submit() async {
    if (_giftcardId.isEmpty) {
      _showError('The gift card identifier is missing.');
      return;
    }

    if (widget.isEcode) {
      if (_codeController.text.trim().isEmpty) {
        _showError('Enter your gift card code.');
        return;
      }
    } else {
      if (_images.isEmpty) {
        _showError('Upload at least one gift card image.');
        return;
      }
    }

    setState(() {
      _submitting = true;
    });

    try {
      final trade = await _service.submitTrade(
        giftcardId: _giftcardId,
        brand: _brand,
        country: _country,
        cardType: _cardType,
        amount: widget.amount,
        rate: widget.rate,
        expectedPayout: widget.payout,
        payoutMethod: 'NAIRA',
        comments: widget.isEcode ? _codeController.text.trim() : null,
        images: widget.isEcode ? const [] : _images,
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

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEcode ? 'Enter E-code' : 'Upload Gift Card'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${_brand} • $_country',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Amount: \$${widget.amount}',
              style: const TextStyle(color: Colors.grey),
            ),
            Text(
              'Estimated payout: ₦${widget.payout}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Expanded(child: widget.isEcode ? _buildEcode() : _buildImages()),
            SizedBox(
              height: 52,
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
                    : const Text('Submit Trade'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEcode() {
    return TextField(
      controller: _codeController,
      maxLines: 5,
      decoration: const InputDecoration(
        labelText: 'Gift Card Code',
        hintText: 'Enter the e-code here',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildImages() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _pickImages,
            icon: const Icon(Icons.photo_library_outlined),
            label: Text(
              _images.isEmpty
                  ? 'Select Gift Card Images'
                  : 'Change Images (${_images.length})',
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _images.isEmpty
              ? const Center(
                  child: Text(
                    'Select clear photos of your gift card.\n\nMaximum 20 images • JPG/PNG • 5MB each',
                    textAlign: TextAlign.center,
                  ),
                )
              : GridView.builder(
                  itemCount: _images.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (_, index) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          _images[index].path,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image),
                              ),
                        ),
                        Positioned(
                          right: 6,
                          top: 6,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.black54,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.close,
                                size: 18,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _images.removeAt(index);
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }
}
