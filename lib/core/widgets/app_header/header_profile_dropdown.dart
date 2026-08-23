import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:utilityhub/core/security/device_trust.dart';

class HeaderProfileDropdown extends StatefulWidget {
  final String? photoUrl;
  final bool alignRight;
  final bool compact;

  const HeaderProfileDropdown({
    super.key,
    this.photoUrl,
    this.alignRight = false,
    this.compact = false,
  });

  @override
  State<HeaderProfileDropdown> createState() => _HeaderProfileDropdownState();
}

class _HeaderProfileDropdownState extends State<HeaderProfileDropdown> {
  static const Color navy = Color(0xFF273D68);
  static const Color blue = Color(0xFF4A6BB8);
  static const Color lightBlue = Color(0xFF75A1FF);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return _buildDropdown(widget.photoUrl);
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        String? profileUrl = widget.photoUrl;

        final data = snapshot.data?.data();

        if (data != null) {
          final firestoreUrl = data['profileUrl'];

          if (firestoreUrl is String && firestoreUrl.trim().isNotEmpty) {
            profileUrl = firestoreUrl;
          }
        }

        return _buildDropdown(profileUrl);
      },
    );
  }

  Widget _buildDropdown(String? profileUrl) {
    final avatar = _ProfileAvatar(
      photoUrl: profileUrl,
      compact: widget.compact,
    );

    return PopupMenuButton<String>(
      tooltip: 'Account',
      offset: const Offset(0, 12),
      color: navy,
      elevation: 20,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(widget.compact ? 18 : 20),
        side: BorderSide(color: Colors.white.withOpacity(0.10)),
      ),
      onSelected: (value) {
        _handleAction(context, value);
      },
      itemBuilder: (context) => _menuItems(),
      child: widget.compact
          ? avatar
          : Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.055),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.10)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  avatar,
                  const SizedBox(width: 8),
                  const Text(
                    'Account',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 17,
                    color: Colors.white60,
                  ),
                ],
              ),
            ),
    );
  }

  List<PopupMenuEntry<String>> _menuItems() {
    return const [
      PopupMenuItem<String>(
        value: 'profile',
        child: _ProfileMenuItem(
          icon: Icons.person_outline_rounded,
          label: 'Profile',
        ),
      ),
      PopupMenuItem<String>(
        value: 'wallet',
        child: _ProfileMenuItem(
          icon: Icons.account_balance_wallet_outlined,
          label: 'Wallet',
        ),
      ),
      PopupMenuItem<String>(
        value: 'settings',
        child: _ProfileMenuItem(
          icon: Icons.settings_outlined,
          label: 'Settings',
        ),
      ),
      PopupMenuItem<String>(
        value: 'security',
        child: _ProfileMenuItem(icon: Icons.shield_outlined, label: 'Security'),
      ),
      PopupMenuDivider(),
      PopupMenuItem<String>(
        value: 'logout',
        child: _ProfileMenuItem(
          icon: Icons.logout_rounded,
          label: 'Sign out',
          danger: true,
        ),
      ),
    ];
  }

  void _handleAction(BuildContext context, String value) {
    switch (value) {
      case 'profile':
        Navigator.pushNamed(context, '/profile');
        break;

      case 'wallet':
        Navigator.pushNamed(context, '/wallet');
        break;

      case 'settings':
        Navigator.pushNamed(context, '/settings');
        break;

      case 'security':
        Navigator.pushNamed(context, '/security');
        break;

      case 'logout':
        _showLogoutDialog(context);
        break;
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: navy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Sign out?',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          content: const Text(
            'Are you sure you want to sign out of GiftPay?',
            style: TextStyle(
              fontFamily: 'Inter',
              height: 1.5,
              color: Colors.white70,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  color: Colors.white70,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                await DeviceTrust.clearDeviceTrust();
                await FirebaseAuth.instance.signOut();

                if (!context.mounted) {
                  return;
                }

                Navigator.of(
                  context,
                  rootNavigator: true,
                ).pushNamedAndRemoveUntil('/login', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: blue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              child: const Text(
                'Sign out',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String? photoUrl;
  final bool compact;

  const _ProfileAvatar({required this.photoUrl, required this.compact});

  static const Color navy = Color(0xFF273D68);
  static const Color blue = Color(0xFF4A6BB8);

  @override
  Widget build(BuildContext context) {
    const size = 34.0;

    final hasPhoto = photoUrl != null && photoUrl!.trim().isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF75A1FF), Color(0xFF4A6BB8)],
        ),
        boxShadow: [
          BoxShadow(
            color: blue.withOpacity(0.24),
            blurRadius: 13,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(2),
      child: CircleAvatar(
        backgroundColor: navy,
        backgroundImage: hasPhoto ? NetworkImage(photoUrl!) : null,
        child: !hasPhoto
            ? const Icon(Icons.person_rounded, size: 18, color: Colors.white)
            : null,
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool danger;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger
        ? const Color(0xFFFF8A8A)
        : Colors.white.withOpacity(0.88);

    return SizedBox(
      width: 180,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 11),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
