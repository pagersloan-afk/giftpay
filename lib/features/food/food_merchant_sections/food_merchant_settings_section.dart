part of '../food_merchant_screen.dart';

extension _FoodMerchantSettingsSection on _FoodMerchantScreenState {
  Future<void> _editRestaurantSettings() async {
    final s = _restaurantSettings;
    final name = TextEditingController(
      text: '${s['restaurantName'] ?? 'GiftPay Food'}',
    );
    final description = TextEditingController(
      text: '${s['description'] ?? ''}',
    );
    final phone = TextEditingController(text: '${s['phone'] ?? ''}');
    final email = TextEditingController(text: '${s['email'] ?? ''}');
    final address = TextEditingController(text: '${s['address'] ?? ''}');
    final hours = TextEditingController(text: '${s['openingHours'] ?? ''}');
    final deliveryNotes = TextEditingController(
      text: '${s['deliveryNotes'] ?? ''}',
    );
    final logoUrl = TextEditingController(text: '${s['logoUrl'] ?? ''}');
    final facebookUrl = TextEditingController(
      text: '${s['facebookUrl'] ?? ''}',
    );
    final instagramUrl = TextEditingController(
      text: '${s['instagramUrl'] ?? ''}',
    );
    final tiktokUrl = TextEditingController(text: '${s['tiktokUrl'] ?? ''}');
    final linkedinUrl = TextEditingController(
      text: '${s['linkedinUrl'] ?? ''}',
    );
    final youtubeUrl = TextEditingController(text: '${s['youtubeUrl'] ?? ''}');
    final xUrl = TextEditingController(text: '${s['xUrl'] ?? ''}');
    final payoutAccountNumber = TextEditingController(text: '${s['payoutAccountNumber'] ?? ''}');
    List<Map<String, String>> payoutBanks = [];
    String? selectedPayoutBankCode = '${s['payoutBankCode'] ?? ''}'.isEmpty ? null : '${s['payoutBankCode']}';
    try { payoutBanks = await _loadFoodPayoutBanks(); } catch (_) { /* Show an empty list with an explanatory form error below. */ }
    if (!payoutBanks.any((bank) => bank['code'] == selectedPayoutBankCode)) selectedPayoutBankCode = null;
    bool accepting = s['acceptingOrders'] != false;
    XFile? selectedLogo;
    Uint8List? selectedBytes;
    String? formError;
    bool saving = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (ctx, refresh) {
          Future<void> pickLogo() async {
            try {
              final picked = await _picker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 84,
                maxWidth: 1400,
              );
              if (picked == null) return;
              final bytes = await picked.readAsBytes();
              if (!sheetContext.mounted) return;
              if (bytes.length > 5 * 1024 * 1024) {
                refresh(() => formError = 'Choose an image smaller than 5 MB.');
                return;
              }
              refresh(() {
                selectedLogo = picked;
                selectedBytes = bytes;
                formError = null;
              });
            } catch (e) {
              if (!sheetContext.mounted) return;
              refresh(() => formError = _error(e));
            }
          }

          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * .94,
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
              border: Border(
                top: BorderSide(color: _FoodMerchantScreenState.line),
              ),
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
                  const Text(
                    'Restaurant settings',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Manage the business profile customers associate with your restaurant.',
                    style: TextStyle(color: _FoodMerchantScreenState.muted),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: InkWell(
                      onTap: pickLogo,
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        width: 96,
                        height: 96,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(.06),
                          border: Border.all(
                            color: _FoodMerchantScreenState.line,
                          ),
                        ),
                        child: selectedBytes != null
                            ? Image.memory(selectedBytes!, fit: BoxFit.cover)
                            : '${logoUrl.text}'.startsWith('https://')
                            ? Image.network(
                                logoUrl.text,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.storefront_rounded,
                                  color: _FoodMerchantScreenState.cyan,
                                  size: 38,
                                ),
                              )
                            : const Icon(
                                Icons.storefront_rounded,
                                color: _FoodMerchantScreenState.cyan,
                                size: 38,
                              ),
                      ),
                    ),
                  ),
                  Center(
                    child: TextButton.icon(
                      onPressed: pickLogo,
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      label: const Text('Change restaurant logo'),
                    ),
                  ),
                  _textField(name, 'Restaurant name', 'e.g. GiftPay Kitchen'),
                  const SizedBox(height: 12),
                  _textField(
                    description,
                    'Restaurant description',
                    'Tell customers about your food and restaurant',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  _textField(
                    phone,
                    'Business phone',
                    '+234...',
                    keyboard: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  _textField(
                    email,
                    'Business email',
                    'restaurant@example.com',
                    keyboard: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  _textField(
                    address,
                    'Restaurant address',
                    'Street, city, state',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  _textField(
                    hours,
                    'Opening hours',
                    'Mon-Sat 9:00 AM - 9:00 PM',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  _textField(
                    deliveryNotes,
                    'Delivery / pickup notes',
                    'Service area, pickup instructions, etc.',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Merchant settlement account',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Add the bank account where GiftPay should send your restaurant earnings when Flutterwave is selected for automatic settlement. The account name is verified with Flutterwave before saving.',
                    style: TextStyle(color: _FoodMerchantScreenState.muted, fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedPayoutBankCode,
                    dropdownColor: _FoodMerchantScreenState.surface,
                    decoration: const InputDecoration(
                      labelText: 'Settlement bank',
                      border: OutlineInputBorder(),
                    ),
                    items: payoutBanks.map((bank) => DropdownMenuItem<String>(
                      value: bank['code'],
                      child: Text(bank['name']!, overflow: TextOverflow.ellipsis),
                    )).toList(),
                    onChanged: (value) => refresh(() => selectedPayoutBankCode = value),
                  ),
                  const SizedBox(height: 12),
                  _textField(
                    payoutAccountNumber,
                    'Settlement account number',
                    '10-digit bank account number',
                    keyboard: TextInputType.number,
                  ),
                  if (payoutBanks.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text('Bank list could not be loaded. Check your Flutterwave API credentials and try again.', style: TextStyle(color: Color(0xFFFFC66D), fontSize: 12)),
                    ),
                  const SizedBox(height: 18),
                  const Text(
                    'Social media links',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Add full HTTPS links. Leave any field blank if you do not use that platform.',
                    style: TextStyle(
                      color: _FoodMerchantScreenState.muted,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _textField(
                    facebookUrl,
                    'Facebook URL',
                    'https://facebook.com/yourrestaurant',
                    keyboard: TextInputType.url,
                  ),
                  const SizedBox(height: 10),
                  _textField(
                    instagramUrl,
                    'Instagram URL',
                    'https://instagram.com/yourrestaurant',
                    keyboard: TextInputType.url,
                  ),
                  const SizedBox(height: 10),
                  _textField(
                    tiktokUrl,
                    'TikTok URL',
                    'https://tiktok.com/@yourrestaurant',
                    keyboard: TextInputType.url,
                  ),
                  const SizedBox(height: 10),
                  _textField(
                    linkedinUrl,
                    'LinkedIn URL',
                    'https://linkedin.com/company/yourrestaurant',
                    keyboard: TextInputType.url,
                  ),
                  const SizedBox(height: 10),
                  _textField(
                    youtubeUrl,
                    'YouTube URL',
                    'https://youtube.com/@yourrestaurant',
                    keyboard: TextInputType.url,
                  ),
                  const SizedBox(height: 10),
                  _textField(
                    xUrl,
                    'X URL',
                    'https://x.com/yourrestaurant',
                    keyboard: TextInputType.url,
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: accepting,
                    activeColor: _FoodMerchantScreenState.cyan,
                    onChanged: (v) => refresh(() => accepting = v),
                    title: const Text(
                      'Accepting orders',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: const Text(
                      'Turn off when the restaurant is temporarily unavailable.',
                      style: TextStyle(color: _FoodMerchantScreenState.muted),
                    ),
                  ),
                  if (formError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        formError!,
                        style: const TextStyle(color: Color(0xFFFF6B78)),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: _FoodMerchantScreenState.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: saving
                          ? null
                          : () async {
                              if (name.text.trim().isEmpty) {
                                refresh(
                                  () => formError =
                                      'Restaurant name is required.',
                                );
                                return;
                              }
                              refresh(() {
                                saving = true;
                                formError = null;
                              });
                              try {
                                var finalLogo = logoUrl.text.trim();
                                if (selectedLogo != null)
                                  finalLogo = await _uploadImage(selectedLogo!);
                                final response = await http.patch(
                                  _uri('/api/food/merchant/settings'),
                                  headers: await _headers(),
                                  body: jsonEncode({
                                    'restaurantName': name.text.trim(),
                                    'description': description.text.trim(),
                                    'phone': phone.text.trim(),
                                    'email': email.text.trim(),
                                    'address': address.text.trim(),
                                    'openingHours': hours.text.trim(),
                                    'deliveryNotes': deliveryNotes.text.trim(),
                                    'logoUrl': finalLogo,
                                    'facebookUrl': facebookUrl.text.trim(),
                                    'instagramUrl': instagramUrl.text.trim(),
                                    'tiktokUrl': tiktokUrl.text.trim(),
                                    'linkedinUrl': linkedinUrl.text.trim(),
                                    'youtubeUrl': youtubeUrl.text.trim(),
                                    'xUrl': xUrl.text.trim(),
                                    'acceptingOrders': accepting,
                                    if (selectedPayoutBankCode != null && payoutAccountNumber.text.trim().isNotEmpty) 'payoutBankCode': selectedPayoutBankCode,
                                    if (selectedPayoutBankCode != null && payoutAccountNumber.text.trim().isNotEmpty) 'payoutAccountNumber': payoutAccountNumber.text.trim(),
                                  }),
                                );
                                _decode(response);
                                await _loadRestaurantSettings();
                                if (!sheetContext.mounted) return;
                                Navigator.of(sheetContext).pop();
                                if (mounted)
                                  _toast('Restaurant profile updated.');
                              } catch (e) {
                                if (!sheetContext.mounted) return;
                                refresh(() {
                                  saving = false;
                                  formError = _error(e);
                                });
                              }
                            },
                      icon: const Icon(Icons.save_outlined),
                      label: Text(
                        saving ? 'Saving…' : 'Save restaurant settings',
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
    phone.dispose();
    email.dispose();
    address.dispose();
    hours.dispose();
    deliveryNotes.dispose();
    logoUrl.dispose();
    facebookUrl.dispose();
    instagramUrl.dispose();
    tiktokUrl.dispose();
    linkedinUrl.dispose();
    youtubeUrl.dispose();
    xUrl.dispose();
    payoutAccountNumber.dispose();
  }

  Widget _settingsTab() {
    if (_loadingSettings)
      return const Center(
        child: CircularProgressIndicator(color: _FoodMerchantScreenState.cyan),
      );
    if (_settingsError != null)
      return _errorState(_settingsError!, _loadRestaurantSettings);
    final s = _restaurantSettings;
    final logo = '${s['logoUrl'] ?? ''}';
    final accepting = s['acceptingOrders'] != false;
    final payoutAccount = '${s['payoutAccountNumber'] ?? ''}';
    final payoutAccountMasked = payoutAccount.length >= 4 ? '******${payoutAccount.substring(payoutAccount.length - 4)}' : '';
    return RefreshIndicator(
      color: _FoodMerchantScreenState.cyan,
      backgroundColor: _FoodMerchantScreenState.surface,
      onRefresh: _loadRestaurantSettings,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 110),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: _glass(opacity: .07, radius: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(.06),
                        border: Border.all(
                          color: _FoodMerchantScreenState.line,
                        ),
                      ),
                      child: logo.startsWith('https://')
                          ? Image.network(
                              logo,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.storefront_rounded,
                                color: _FoodMerchantScreenState.cyan,
                                size: 30,
                              ),
                            )
                          : const Icon(
                              Icons.storefront_rounded,
                              color: _FoodMerchantScreenState.cyan,
                              size: 30,
                            ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${s['restaurantName'] ?? 'GiftPay Food'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(
                                accepting
                                    ? Icons.check_circle_rounded
                                    : Icons.pause_circle_rounded,
                                size: 15,
                                color: accepting
                                    ? const Color(0xFF43D9A3)
                                    : const Color(0xFFFFC66D),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                accepting
                                    ? 'Accepting orders'
                                    : 'Not accepting orders',
                                style: const TextStyle(
                                  color: _FoodMerchantScreenState.muted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if ('${s['description'] ?? ''}'.trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    '${s['description']}',
                    style: const TextStyle(
                      color: _FoodMerchantScreenState.muted,
                      height: 1.45,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          _settingsInfoCard(
            Icons.phone_outlined,
            'Business phone',
            '${s['phone'] ?? ''}',
          ),
          _settingsInfoCard(
            Icons.email_outlined,
            'Business email',
            '${s['email'] ?? ''}',
          ),
          _settingsInfoCard(
            Icons.location_on_outlined,
            'Restaurant address',
            '${s['address'] ?? ''}',
          ),
          _settingsInfoCard(
            Icons.schedule_rounded,
            'Opening hours',
            '${s['openingHours'] ?? ''}',
          ),
          _settingsInfoCard(
            Icons.account_balance_rounded,
            'Settlement bank',
            '${s['payoutBankName'] ?? ''}${payoutAccountMasked.isNotEmpty ? ' • $payoutAccountMasked' : ''}${s['payoutAccountVerified'] == true ? ' • Verified' : ''}',
          ),
          _settingsInfoCard(
            Icons.delivery_dining_outlined,
            'Delivery / pickup notes',
            '${s['deliveryNotes'] ?? ''}',
          ),
          _settingsInfoCard(
            Icons.facebook_rounded,
            'Facebook',
            '${s['facebookUrl'] ?? ''}',
          ),
          _settingsInfoCard(
            Icons.camera_alt_outlined,
            'Instagram',
            '${s['instagramUrl'] ?? ''}',
          ),
          _settingsInfoCard(
            Icons.music_note_rounded,
            'TikTok',
            '${s['tiktokUrl'] ?? ''}',
          ),
          _settingsInfoCard(
            Icons.business_center_outlined,
            'LinkedIn',
            '${s['linkedinUrl'] ?? ''}',
          ),
          _settingsInfoCard(
            Icons.play_circle_outline_rounded,
            'YouTube',
            '${s['youtubeUrl'] ?? ''}',
          ),
          _settingsInfoCard(
            Icons.alternate_email_rounded,
            'X',
            '${s['xUrl'] ?? ''}',
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: _FoodMerchantScreenState.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            onPressed: _editRestaurantSettings,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit restaurant profile'),
          ),
        ],
      ),
    );
  }

  Widget _settingsInfoCard(IconData icon, String label, String value) =>
      Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: _glass(opacity: .055, radius: 17),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: _FoodMerchantScreenState.cyan, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: _FoodMerchantScreenState.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value.trim().isEmpty ? 'Not added yet' : value,
                    style: TextStyle(
                      color: value.trim().isEmpty
                          ? _FoodMerchantScreenState.muted
                          : Colors.white,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
