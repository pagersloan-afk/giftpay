// lib/features/home/widgets/home_service_card.dart

import 'package:flutter/material.dart';
import 'package:utilityhub/core/services/user_services_api.dart';
import 'package:utilityhub/core/utils/logout_handler.dart';

class HomeServiceCard extends StatefulWidget {
  final String title;
  final IconData icon;

  // Optional route
  final String? route;

  // Optional action (e.g., logout)
  final String? action;

  final Color? iconColor;
  final String userId;

  // Fixed height
  final double? fixedHeight;

  const HomeServiceCard({
    super.key,
    required this.title,
    required this.icon,
    this.route,
    this.action,
    required this.userId,
    this.iconColor,
    this.fixedHeight,
  });

  @override
  State<HomeServiceCard> createState() => _HomeServiceCardState();
}

class _HomeServiceCardState extends State<HomeServiceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;

  double scale = 1.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0.15, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    // Tap animation
    setState(() => scale = 0.92);

    await Future.delayed(const Duration(milliseconds: 120));

    if (!mounted) return;

    setState(() => scale = 1.0);

    // Log usage
    final device = Theme.of(context).platform.name;

    await UserServicesApi.logUsage(
      userId: widget.userId,
      serviceName: widget.title,
      device: device,
    );

    if (!mounted) return;

    // Handle logout action
    if (widget.action == "logout") {
      await showLogoutDialog(context);
      return;
    }

    // Gift Card requires a Buy/Sell choice first.
    if (_isGiftCardService) {
      await _showGiftCardChooser();
      return;
    }

    // Normal navigation for all other services
    if (widget.route != null) {
      Navigator.pushNamed(context, widget.route!);
    }
  }

  bool get _isGiftCardService {
    final normalizedTitle = widget.title.trim().toLowerCase();

    return normalizedTitle == 'gift card' || normalizedTitle == 'gift cards';
  }

  Future<void> _showGiftCardChooser() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1115),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4FC3F7).withOpacity(0.12),
                  blurRadius: 30,
                  spreadRadius: 2,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 22),

                // Icon
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF4FC3F7).withOpacity(0.10),
                    border: Border.all(
                      color: const Color(0xFF4FC3F7).withOpacity(0.25),
                    ),
                  ),
                  child: const Icon(
                    Icons.card_giftcard_rounded,
                    color: Color(0xFF4FC3F7),
                    size: 28,
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Gift Cards',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  'What would you like to do?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.60),
                    fontSize: 13.5,
                  ),
                ),

                const SizedBox(height: 22),

                // BUY
                _GiftCardOption(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Buy Gift Card',
                  description: 'Purchase a gift card from available options.',
                  iconColor: const Color(0xFF4FC3F7),
                  onTap: () {
                    Navigator.pop(sheetContext);

                    Navigator.pushNamed(context, '/giftcards');
                  },
                ),

                const SizedBox(height: 12),

                // SELL
                _GiftCardOption(
                  icon: Icons.sell_outlined,
                  title: 'Sell Gift Card',
                  description: 'Submit your gift card and receive your payout.',
                  iconColor: const Color(0xFF81C784),
                  onTap: () {
                    Navigator.pop(sheetContext);

                    Navigator.pushNamed(context, '/trade');
                  },
                ),

                const SizedBox(height: 8),

                TextButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.55),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 150),
        child: InkWell(
          onTap: _handleTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            height: widget.fixedHeight ?? 78,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4FC3F7).withOpacity(0.10),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.icon,
                  size: 22,
                  color: widget.iconColor ?? Colors.white.withOpacity(0.90),
                ),

                const SizedBox(height: 6),

                SizedBox(
                  height: 20,
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                      color: widget.iconColor ?? const Color(0xFFE5E7EB),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GiftCardOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color iconColor;
  final VoidCallback onTap;

  const _GiftCardOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.055),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: iconColor.withOpacity(0.18)),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: Colors.white.withOpacity(0.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
