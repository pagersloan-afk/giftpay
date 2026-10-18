part of '../food_merchant_screen.dart';

extension _FoodMerchantMenuSection on _FoodMerchantScreenState {
  Future<String> _uploadImage(XFile file) async {
      final token = await _token();
      final mime = (file.mimeType ?? '').toLowerCase();
      final fileName = file.name.toLowerCase();
      final subtype =
          mime == 'image/png' || (mime.isEmpty && fileName.endsWith('.png'))
          ? 'png'
          : mime == 'image/webp' || (mime.isEmpty && fileName.endsWith('.webp'))
          ? 'webp'
          : 'jpeg';
      final request = http.MultipartRequest(
        'POST',
        _uri('/api/food/merchant/menu-image'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          await file.readAsBytes(),
          filename: file.name.isEmpty ? 'food-image.$subtype' : file.name,
          contentType: MediaType('image', subtype),
        ),
      );
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      final data = _decode(response);
      final url = '${data['imageUrl'] ?? ''}'.trim();
      if (!url.startsWith('https://'))
        throw Exception('Image upload did not return a valid HTTPS URL.');
      return url;
    }

  Future<void> _saveMenuItem({Map<String, dynamic>? existing}) async {
      final name = TextEditingController(text: '${existing?['name'] ?? ''}');
      final description = TextEditingController(
        text: '${existing?['description'] ?? ''}',
      );
      final category = TextEditingController(
        text: '${existing?['category'] ?? 'Meals'}',
      );
      final price = TextEditingController(
        text: existing == null ? '' : '${existing['price'] ?? ''}',
      );
      final imageUrl = TextEditingController(
        text: '${existing?['imageUrl'] ?? ''}',
      );
      bool available = existing?['active'] != false;
      XFile? selectedImage;
      Uint8List? selectedBytes;
      String? formError;
  
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) => StatefulBuilder(
          builder: (ctx, refresh) {
            Future<void> pickImage() async {
              try {
                final picked = await _picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 84,
                  maxWidth: 1800,
                );
                if (picked == null) return;
                final bytes = await picked.readAsBytes();
                if (bytes.length > 5 * 1024 * 1024) {
                  refresh(() => formError = 'Choose an image smaller than 5 MB.');
                  return;
                }
                final type = (picked.mimeType ?? '').toLowerCase();
                if (type.isNotEmpty &&
                    !['image/jpeg', 'image/png', 'image/webp'].contains(type)) {
                  refresh(() => formError = 'Use a JPG, PNG or WebP image.');
                  return;
                }
                refresh(() {
                  selectedImage = picked;
                  selectedBytes = bytes;
                  formError = null;
                });
              } catch (e) {
                refresh(() => formError = _error(e));
              }
            }
  
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * .92,
              ),
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                20 + MediaQuery.of(ctx).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: _FoodMerchantScreenState.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: _FoodMerchantScreenState.line,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      existing == null ? 'Add food item' : 'Edit food item',
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Add a clear photo, accurate price and useful description.',
                      style: TextStyle(color: _FoodMerchantScreenState.muted),
                    ),
                    const SizedBox(height: 18),
                    InkWell(
                      onTap: pickImage,
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        width: double.infinity,
                        height: 175,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.055),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: _FoodMerchantScreenState.line),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: selectedBytes != null
                            ? Image.memory(selectedBytes!, fit: BoxFit.cover)
                            : '${imageUrl.text}'.startsWith('https://')
                            ? Image.network(
                                imageUrl.text,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _imagePlaceholder(),
                              )
                            : _imagePlaceholder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton.icon(
                        onPressed: pickImage,
                        icon: const Icon(Icons.add_photo_alternate_outlined),
                        label: Text(
                          selectedImage == null
                              ? 'Choose food image'
                              : 'Change selected image',
                        ),
                      ),
                    ),
                    _textField(
                      name,
                      'Food name',
                      'e.g. Jollof rice with chicken',
                    ),
                    const SizedBox(height: 12),
                    _textField(
                      description,
                      'Description',
                      'Ingredients, portion size, extras…',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _textField(
                            price,
                            'Price (₦)',
                            '2500',
                            keyboard: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _textField(category, 'Category', 'Meals'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      title: const Text(
                        'Image URL (optional alternative)',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: const Text(
                        'Use this if your image is already hosted securely.',
                      ),
                      children: [
                        TextField(
                          controller: imageUrl,
                          keyboardType: TextInputType.url,
                          decoration: _inputDecoration(
                            'HTTPS image URL',
                            'https://…',
                          ),
                          onChanged: (_) => refresh(() {}),
                        ),
                      ],
                    ),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: available,
                      onChanged: (v) => refresh(() => available = v),
                      title: const Text(
                        'Available to customers',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: const Text(
                        'Turn off to hide this item from the customer menu.',
                      ),
                      activeColor: _FoodMerchantScreenState.blue,
                    ),
                    if (formError != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        formError!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ],
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: _FoodMerchantScreenState.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: _saving
                            ? null
                            : () async {
                                final parsedPrice = num.tryParse(
                                  price.text.trim(),
                                );
                                if (name.text.trim().isEmpty ||
                                    parsedPrice == null ||
                                    parsedPrice <= 0) {
                                  refresh(
                                    () => formError =
                                        'Enter a food name and a price greater than zero.',
                                  );
                                  return;
                                }
                                if (description.text.trim().length > 1000 ||
                                    category.text.trim().isEmpty) {
                                  refresh(
                                    () => formError =
                                        'Add a category and keep the description under 1,000 characters.',
                                  );
                                  return;
                                }
                                Navigator.of(ctx).pop();
                                await _submitMenuItem(
                                  existing: existing,
                                  name: name.text.trim(),
                                  description: description.text.trim(),
                                  category: category.text.trim(),
                                  price: parsedPrice,
                                  available: available,
                                  imageUrl: imageUrl.text.trim(),
                                  selectedImage: selectedImage,
                                );
                              },
                        icon: const Icon(Icons.save_outlined),
                        label: Text(
                          existing == null ? 'Save menu item' : 'Save changes',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
      name.dispose();
      description.dispose();
      category.dispose();
      price.dispose();
      imageUrl.dispose();
    }

  Widget _imagePlaceholder() => const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo_outlined, size: 36, color: _FoodMerchantScreenState.blue),
        SizedBox(height: 8),
        Text(
          'Food photo preview',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 3),
        Text(
          'JPG, PNG or WebP · max 5 MB',
          style: TextStyle(color: _FoodMerchantScreenState.muted, fontSize: 12),
        ),
      ],
    );

  InputDecoration _inputDecoration(String label, String hint) =>
        InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(color: _FoodMerchantScreenState.muted),
          hintStyle: TextStyle(color: _FoodMerchantScreenState.muted.withOpacity(.7)),
          filled: true,
          fillColor: Colors.white.withOpacity(.055),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _FoodMerchantScreenState.line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _FoodMerchantScreenState.cyan),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _FoodMerchantScreenState.line),
          ),
        );

  Widget _textField(
      TextEditingController controller,
      String label,
      String hint, {
      int maxLines = 1,
      TextInputType? keyboard,
    }) => TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboard,
      decoration: _inputDecoration(label, hint),
    );

  Future<void> _submitMenuItem({
      Map<String, dynamic>? existing,
      required String name,
      required String description,
      required String category,
      required num price,
      required bool available,
      required String imageUrl,
      XFile? selectedImage,
    }) async {
      setState(() => _saving = true);
      try {
        var finalImageUrl = imageUrl;
        if (selectedImage != null) {
          _toast('Uploading food image…');
          finalImageUrl = await _uploadImage(selectedImage);
        }
        if (finalImageUrl.isNotEmpty && !finalImageUrl.startsWith('https://')) {
          throw Exception('Image URL must start with https://');
        }
        final body = <String, dynamic>{
          'name': name,
          'description': description,
          'category': category,
          'price': price,
          'imageUrl': finalImageUrl,
          ...(existing == null
              ? <String, dynamic>{'available': available}
              : <String, dynamic>{'active': available}),
        };
        final headers = await _headers();
        final response = existing == null
            ? await http.post(
                _uri('/api/food/merchant/menu'),
                headers: headers,
                body: jsonEncode(body),
              )
            : await http.patch(
                _uri('/api/food/merchant/menu/${existing['id']}'),
                headers: headers,
                body: jsonEncode(body),
              );
        _decode(response);
        await _loadMenu();
        _toast(
          existing == null ? 'Food item added to menu.' : 'Menu item updated.',
        );
      } catch (e) {
        _toast(_error(e));
      } finally {
        if (mounted) setState(() => _saving = false);
      }
    }

  Future<void> _setAvailability(Map<String, dynamic> item, bool active) async {
      try {
        final response = await http.patch(
          _uri('/api/food/merchant/menu/${item['id']}'),
          headers: await _headers(),
          body: jsonEncode({'active': active}),
        );
        _decode(response);
        await _loadMenu();
        _toast(
          active
              ? 'Item is available to customers.'
              : 'Item hidden from customer menu.',
        );
      } catch (e) {
        _toast(_error(e));
      }
    }

  Widget _menuTab() {
      if (_loadingMenu) return const Center(child: CircularProgressIndicator());
      if (_menuError != null) return _errorState(_menuError!, _loadMenu);
      if (_menu.isEmpty)
        return _emptyState(
          Icons.restaurant_menu,
          'Your menu starts here',
          'Add your first dish with a photo, description and price.',
          'Add first item',
          () => _saveMenuItem(),
        );
      return RefreshIndicator(
        onRefresh: _loadMenu,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${_menu.length} menu item${_menu.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _loadMenu,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            for (final item in _menu) _menuItemCard(item),
          ],
        ),
      );
    }

  Widget _menuItemCard(Map<String, dynamic> item) {
      final active = item['active'] == true;
      final imageUrl = '${item['imageUrl'] ?? ''}';
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.065),
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: _FoodMerchantScreenState.line),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 92,
                height: 92,
                child: imageUrl.startsWith('https://')
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _smallImagePlaceholder(),
                      )
                    : _smallImagePlaceholder(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${item['name'] ?? 'Food item'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: active
                              ? const Color(0xFFE6F7EE)
                              : const Color(0xFFFFF0E5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          active ? 'Live' : 'Hidden',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: active
                                ? const Color(0xFF16784B)
                                : const Color(0xFF9A4D13),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item['category'] ?? 'Meals'}',
                    style: const TextStyle(color: _FoodMerchantScreenState.muted, fontSize: 12),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _money(item['price']),
                    style: const TextStyle(
                      color: _FoodMerchantScreenState.blue,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: TextButton.icon(
                          onPressed: () => _saveMenuItem(existing: item),
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('Edit'),
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.only(right: 8),
                          ),
                        ),
                      ),
                      Flexible(
                        child: TextButton.icon(
                          onPressed: () => _setAvailability(item, !active),
                          icon: Icon(
                            active
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 16,
                          ),
                          label: Text(active ? 'Hide' : 'Publish'),
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

  Widget _smallImagePlaceholder() => Container(
      color: Colors.white.withOpacity(.055),
      child: const Icon(Icons.restaurant, color: _FoodMerchantScreenState.cyan, size: 30),
    );
}
