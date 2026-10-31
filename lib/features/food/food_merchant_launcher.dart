import 'package:flutter/material.dart';
import 'package:utilityhub/features/food/food_merchant_access.dart';
import 'package:utilityhub/features/food/food_merchant_screen.dart';

Future<void> openFoodMerchantDashboard(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);

  try {
    final allowed = await FoodMerchantAccess.check();
    if (!context.mounted) return;

    if (!allowed) {
      await _showMerchantApplication(context);
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const FoodMerchantScreen()),
    );
  } catch (e) {
    if (!context.mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(e.toString().replaceFirst('Exception: ', '')),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

Future<void> _showMerchantApplication(BuildContext context) async {
  final owner = TextEditingController();
  final restaurant = TextEditingController();
  final registrationNumber = TextEditingController();
  final phone = TextEditingController();
  final businessEmail = TextEditingController();
  final address = TextEditingController();
  final foodSafetyPermit = TextEditingController();
  final description = TextEditingController();
  final formKey = GlobalKey<FormState>();

  String businessType = 'sole_proprietorship';
  String registrationType = 'CAC';
  bool submitting = false;

  try {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          final baseTheme = Theme.of(context);
          final baseScheme = baseTheme.colorScheme;
          final theme = baseTheme.copyWith(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Colors.black,
            dialogBackgroundColor: Colors.black,
            colorScheme: baseScheme.copyWith(
              brightness: Brightness.dark,
              surface: Colors.black,
              onSurface: Colors.white,
              onSurfaceVariant: Colors.white70,
              outline: Colors.white54,
              outlineVariant: Colors.white24,
            ),
            textTheme: baseTheme.textTheme.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
          );
          final scheme = theme.colorScheme;
          final isPending = FoodMerchantAccess.applicationStatus == 'pending';

          return Theme(
            data: theme,
            child: Dialog(
            backgroundColor: Colors.black,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.black54,
            elevation: 18,
            insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.65)),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560, maxHeight: 720),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
                child: isPending
                    ? _PendingApplicationView(
                        onClose: () => Navigator.pop(dialogContext),
                      )
                    : Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: scheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(Icons.verified_user_outlined, color: scheme.onPrimaryContainer),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Food merchant application',
                                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Business verification protects customers and helps us confirm legitimate food businesses.',
                                        style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Close',
                                  onPressed: submitting ? null : () => Navigator.pop(dialogContext),
                                  icon: const Icon(Icons.close),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _SectionHeading(title: 'Owner and business'),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: owner,
                                      textCapitalization: TextCapitalization.words,
                                      decoration: const InputDecoration(
                                        labelText: 'Owner’s full legal name *',
                                        prefixIcon: Icon(Icons.person_outline),
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (v) => (v == null || v.trim().length < 2)
                                          ? 'Enter the owner’s full legal name'
                                          : null,
                                    ),
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      controller: restaurant,
                                      textCapitalization: TextCapitalization.words,
                                      decoration: const InputDecoration(
                                        labelText: 'Registered business / restaurant name *',
                                        prefixIcon: Icon(Icons.storefront_outlined),
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (v) => (v == null || v.trim().length < 2)
                                          ? 'Enter the registered business name'
                                          : null,
                                    ),
                                    const SizedBox(height: 12),
                                    DropdownButtonFormField<String>(
                                      value: businessType,
                                      isExpanded: true,
                                      decoration: const InputDecoration(
                                        labelText: 'Business structure *',
                                        prefixIcon: Icon(Icons.business_outlined),
                                        border: OutlineInputBorder(),
                                      ),
                                      items: const [
                                        DropdownMenuItem(value: 'sole_proprietorship', child: Text('Sole proprietorship')),
                                        DropdownMenuItem(value: 'partnership', child: Text('Partnership')),
                                        DropdownMenuItem(value: 'limited_company', child: Text('Limited company')),
                                        DropdownMenuItem(value: 'other', child: Text('Other registered structure')),
                                      ],
                                      onChanged: submitting ? null : (v) {
                                        if (v != null) setState(() => businessType = v);
                                      },
                                    ),
                                    const SizedBox(height: 18),
                                    _SectionHeading(title: 'Registration details'),
                                    const SizedBox(height: 8),
                                    DropdownButtonFormField<String>(
                                      value: registrationType,
                                      isExpanded: true,
                                      decoration: const InputDecoration(
                                        labelText: 'Registration authority *',
                                        prefixIcon: Icon(Icons.account_balance_outlined),
                                        border: OutlineInputBorder(),
                                      ),
                                      items: const [
                                        DropdownMenuItem(value: 'CAC', child: Text('Corporate Affairs Commission (CAC)')),
                                        DropdownMenuItem(value: 'government', child: Text('Other government authority')),
                                        DropdownMenuItem(value: 'other', child: Text('Other')),
                                      ],
                                      onChanged: submitting ? null : (v) {
                                        if (v != null) setState(() => registrationType = v);
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      controller: registrationNumber,
                                      textCapitalization: TextCapitalization.characters,
                                      decoration: const InputDecoration(
                                        labelText: 'Business registration number *',
                                        hintText: 'Enter the official registration number',
                                        prefixIcon: Icon(Icons.badge_outlined),
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (v) => (v == null || v.trim().length < 3)
                                          ? 'Enter a valid registration number'
                                          : null,
                                    ),
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      controller: foodSafetyPermit,
                                      decoration: const InputDecoration(
                                        labelText: 'Food safety / operating permit number',
                                        hintText: 'If required or available',
                                        prefixIcon: Icon(Icons.health_and_safety_outlined),
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    _SectionHeading(title: 'Contact and location'),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: phone,
                                      keyboardType: TextInputType.phone,
                                      decoration: const InputDecoration(
                                        labelText: 'Business phone number *',
                                        prefixIcon: Icon(Icons.phone_outlined),
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (v) => (v == null || v.trim().length < 7)
                                          ? 'Enter a valid business phone number'
                                          : null,
                                    ),
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      controller: businessEmail,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: const InputDecoration(
                                        labelText: 'Business email (optional)',
                                        prefixIcon: Icon(Icons.email_outlined),
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (v) {
                                        final value = v?.trim() ?? '';
                                        if (value.isEmpty) return null;
                                        return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)
                                            ? null
                                            : 'Enter a valid email address';
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      controller: address,
                                      minLines: 2,
                                      maxLines: 3,
                                      textCapitalization: TextCapitalization.sentences,
                                      decoration: const InputDecoration(
                                        labelText: 'Full physical business address *',
                                        prefixIcon: Icon(Icons.location_on_outlined),
                                        alignLabelWithHint: true,
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (v) => (v == null || v.trim().length < 5)
                                          ? 'Enter the full business address'
                                          : null,
                                    ),
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      controller: description,
                                      maxLines: 3,
                                      maxLength: 1000,
                                      decoration: const InputDecoration(
                                        labelText: 'Business description (optional)',
                                        hintText: 'Cuisine, opening hours, and other useful details',
                                        alignLabelWithHint: true,
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: scheme.tertiaryContainer.withValues(alpha: 0.55),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.shield_outlined, color: scheme.onTertiaryContainer),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              'Submitting this form does not grant merchant access. GiftPay must verify your registration details and any required food-safety permits before approval.',
                                              style: theme.textTheme.bodySmall?.copyWith(color: scheme.onTertiaryContainer),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: submitting ? null : () => Navigator.pop(dialogContext),
                                    child: const Text('Cancel'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: FilledButton.icon(
                                    onPressed: submitting ? null : () async {
                                      if (!(formKey.currentState?.validate() ?? false)) return;
                                      setState(() => submitting = true);
                                      try {
                                        final message = await FoodMerchantAccess.apply(
                                          legalOwnerName: owner.text,
                                          restaurantName: restaurant.text,
                                          businessType: businessType,
                                          registrationType: registrationType,
                                          registrationNumber: registrationNumber.text,
                                          phone: phone.text,
                                          businessEmail: businessEmail.text,
                                          address: address.text,
                                          foodSafetyPermitNumber: foodSafetyPermit.text,
                                          description: description.text,
                                        );
                                        if (!dialogContext.mounted) return;
                                        Navigator.pop(dialogContext);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
                                        );
                                      } catch (e) {
                                        if (!dialogContext.mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(e.toString().replaceFirst('Exception: ', '')),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                        setState(() => submitting = false);
                                      }
                                    },
                                    icon: submitting
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : const Icon(Icons.send_rounded),
                                    label: Text(submitting ? 'Submitting…' : 'Submit application'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            ),
          );
        },
      ),
    );
  } finally {
    owner.dispose();
    restaurant.dispose();
    registrationNumber.dispose();
    phone.dispose();
    businessEmail.dispose();
    address.dispose();
    foodSafetyPermit.dispose();
    description.dispose();
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
    );
  }
}

class _PendingApplicationView extends StatelessWidget {
  const _PendingApplicationView({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: scheme.tertiaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.hourglass_top_rounded, size: 32, color: scheme.onTertiaryContainer),
        ),
        const SizedBox(height: 16),
        Text(
          'Application under review',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        const Text(
          'Your application is awaiting review. Merchant access will remain disabled until the business registration and any required food-safety credentials are verified.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: FilledButton(onPressed: onClose, child: const Text('Got it')),
        ),
      ],
    );
  }
}
