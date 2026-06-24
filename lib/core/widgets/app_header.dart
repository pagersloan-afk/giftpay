import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:utilityhub/features/notifications/notification_center.dart';
import 'package:utilityhub/features/notifications/notification_dropdown.dart';
import 'package:utilityhub/features/wallet/services/wallet_service.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final wallet = WalletService();

    final isMobile = MediaQuery.of(context).size.width < 600;

    return SafeArea(
      bottom: false,
      child: Container(
        height: 80,
        decoration: const BoxDecoration(color: Color(0xFF0F1115)),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 12,
                  left: 16,
                  right: 16,
                  bottom: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ⭐ LEFT SIDE
                    if (isMobile)
                      // MOBILE → PROFILE AVATAR ONLY
                      _ProfileDropdown(photoUrl: user?.photoURL)
                    else
                      // DESKTOP → BRAND BLOCK
                      Padding(
                        padding: const EdgeInsets.only(left: 46),
                        child: Row(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.95),
                                    Colors.white.withOpacity(0.55),
                                    Colors.white.withOpacity(0.95),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds);
                              },
                              blendMode: BlendMode.srcATop,
                              child: Text(
                                "GiftPay",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: Colors.white.withOpacity(0.9),
                                  shadows: [
                                    Shadow(
                                      blurRadius: 14,
                                      color: Colors.black.withOpacity(0.45),
                                      offset: const Offset(0, 2),
                                    ),
                                    Shadow(
                                      blurRadius: 22,
                                      color: Colors.blue.withOpacity(0.28),
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        Colors.blue.withOpacity(0.35),
                                        Colors.transparent,
                                      ],
                                      radius: 0.85,
                                    ),
                                  ),
                                ),
                                Transform.translate(
                                  offset: const Offset(0, 4),
                                  child: Image.asset(
                                    "assets/logo/giftpay_1.png",
                                    height: 94,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    // ⭐ RIGHT SIDE
                    Row(
                      children: [
                        // DESKTOP ONLY → WALLET BALANCE
                        if (!isMobile && user != null)
                          StreamBuilder<double>(
                            stream: wallet.balanceStream(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) return _walletShimmer();

                              final balance = snapshot.data ?? 0.0;
                              final formatted = NumberFormat(
                                "#,##0",
                              ).format(balance);

                              return GestureDetector(
                                onTap: () => Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pushNamed("/wallet"),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "₦$formatted",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                        const SizedBox(width: 14),

                        // ⭐ NOTIFICATION BELL (MOBILE + DESKTOP)
                        GestureDetector(
                          onTap: () async {
                            await showNotificationDropdown(context);
                          },
                          child: ValueListenableBuilder(
                            valueListenable: NotificationCenter.I.notifications,
                            builder: (context, List<AppNotification> list, _) {
                              final hasUnread = list.any((n) => !n.read);
                              return _NotificationBell(hasUnread: hasUnread);
                            },
                          ),
                        ),

                        const SizedBox(width: 14),

                        // DESKTOP ONLY → PROFILE DROPDOWN
                        if (!isMobile && user != null)
                          _ProfileDropdown(photoUrl: user.photoURL),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Container(height: 2, color: Colors.white.withOpacity(0.12)),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// ⭐ WALLET SHIMMER
// ------------------------------------------------------------
Widget _walletShimmer() {
  return Container(
    width: 70,
    height: 28,
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.3),
      borderRadius: BorderRadius.circular(20),
    ),
    child: const Center(
      child: SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      ),
    ),
  );
}

// ------------------------------------------------------------
// ⭐ NOTIFICATION BELL
// ------------------------------------------------------------
class _NotificationBell extends StatelessWidget {
  final bool hasUnread;

  const _NotificationBell({required this.hasUnread});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.notifications_none, color: Colors.white, size: 28),
        if (hasUnread)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

// ------------------------------------------------------------
// ⭐ PROFILE DROPDOWN
// ------------------------------------------------------------
class _ProfileDropdown extends StatefulWidget {
  final String? photoUrl;

  const _ProfileDropdown({required this.photoUrl});

  @override
  State<_ProfileDropdown> createState() => _ProfileDropdownState();
}

class _ProfileDropdownState extends State<_ProfileDropdown> {
  OverlayEntry? _entry;

  void _toggle() {
    if (_entry == null) {
      _entry = _createOverlay();
      Overlay.of(context, rootOverlay: true).insert(_entry!);
    } else {
      _entry?.remove();
      _entry = null;
    }
    setState(() {});
  }

  OverlayEntry _createOverlay() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) {
        return Positioned(
          left: offset.dx, // ⭐ anchor horizontally to avatar
          top: offset.dy + size.height, // ⭐ place directly under avatar
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 190,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1C20),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4FC3F7).withOpacity(0.15),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _item(
                    icon: Icons.person,
                    label: "Profile",
                    onTap: () {
                      _toggle();
                      Navigator.of(
                        context,
                        rootNavigator: true,
                      ).pushNamed("/profile");
                    },
                  ),
                  _item(
                    icon: Icons.settings,
                    label: "Settings",
                    onTap: () {
                      _toggle();
                      Navigator.of(
                        context,
                        rootNavigator: true,
                      ).pushNamed("/settings");
                    },
                  ),
                  _item(
                    icon: Icons.logout,
                    label: "Logout",
                    onTap: () {
                      _toggle();
                      FirebaseAuth.instance.signOut();
                      Navigator.of(
                        context,
                        rootNavigator: true,
                      ).pushNamed("/login");
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _entry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.white.withOpacity(0.25),
        backgroundImage: widget.photoUrl != null
            ? NetworkImage(widget.photoUrl!)
            : null,
        child: widget.photoUrl == null
            ? const Icon(Icons.person, color: Colors.white)
            : null,
      ),
    );
  }

  Widget _item({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.white.withOpacity(0.85)),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
