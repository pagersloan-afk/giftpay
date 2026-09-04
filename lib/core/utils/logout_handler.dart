import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:utilityhub/core/security/device_trust.dart';

Future<void> showLogoutDialog(BuildContext context) async {
  // ==============================================================
  // CAPTURE THE ROOT NAVIGATOR BEFORE AUTH STATE CHANGES
  // ==============================================================
  //
  // Firebase signOut() causes the authenticated part of the app
  // to rebuild. Therefore, we must not depend on the original
  // BuildContext after signOut() completes.
  //
  // Capturing the NavigatorState now gives us a stable navigator
  // reference for the final redirect to /login.
  // ==============================================================

  final rootNavigator = Navigator.of(context, rootNavigator: true);

  final confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        backgroundColor: const Color(0xFF1A1D21),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.logout, size: 48, color: Colors.redAccent),

              const SizedBox(height: 16),

              const Text(
                "Logout",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Are you sure you want to logout?",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  // ==================================================
                  // CANCEL
                  // ==================================================
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(false);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // ==================================================
                  // LOGOUT
                  // ==================================================
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Logout",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );

  // ================================================================
  // USER CANCELLED
  // ================================================================

  if (confirmed != true) {
    return;
  }

  // ================================================================
  // CLEAR DEVICE TRUST
  // ================================================================

  try {
    await DeviceTrust.clearDeviceTrust();
  } catch (error) {
    debugPrint('Logout: failed to clear device trust: $error');
  }

  // ================================================================
  // SIGN OUT FROM FIREBASE
  // ================================================================

  try {
    await FirebaseAuth.instance.signOut();
  } catch (error) {
    debugPrint('Logout: Firebase sign-out error: $error');
  }

  // ================================================================
  // NAVIGATE TO LOGIN
  // ================================================================
  //
  // IMPORTANT:
  //
  // Do NOT use the original `context` here.
  //
  // The Firebase signOut() above can cause the dashboard/auth
  // widget tree to unmount.
  //
  // We captured `rootNavigator` before the auth state changed.
  // ==============================================================

  if (!rootNavigator.mounted) {
    return;
  }

  rootNavigator.pushNamedAndRemoveUntil('/login', (route) => false);
}
