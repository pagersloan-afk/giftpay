import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_web_plugins/url_strategy.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import 'firebase_options.dart';

// ROUTES
import 'app/routes.dart';
import 'package:utilityhub/app/gifttech_routes.dart';

// GLOBAL THEME
import 'package:utilityhub/core/theme/giftpay_theme.dart';

// NOTIFICATION CENTER
import 'package:utilityhub/features/notifications/notification_center.dart';

// GLOBAL BACKGROUND WRAPPER
import 'package:utilityhub/core/widgets/giftpay_background.dart';

// SPLASH SCREEN
import 'package:utilityhub/features/splash/giftpay_splash.dart';

// AUTH GATE
import 'package:utilityhub/features/auth/login/login_screen.dart';
import 'package:utilityhub/features/home/home_shell.dart';

// PARENT LANDING PAGE
import 'package:utilityhub/features/gift_techlanding/gift_techlanding_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ===========================================================================
  // FLUTTER WEB CLEAN URL STRATEGY
  //
  // Changes:
  //
  //   https://giftpayhq.com/#/login
  //
  // into:
  //
  //   https://giftpayhq.com/login
  //
  // Browser history will now work with normal paths instead of hash fragments.
  // ===========================================================================

  if (kIsWeb) {
    usePathUrlStrategy();
  }

  // ===========================================================================
  // FIREBASE
  // ===========================================================================

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ===========================================================================
  // SUPABASE
  // ===========================================================================

  await supa.Supabase.initialize(
    url: "https://mzvwtxozwnprsiipoxkx.supabase.co",
    anonKey: "YOUR_KEY",
  );

  // ===========================================================================
  // AUTH STATE → NOTIFICATION CENTER
  // ===========================================================================

  FirebaseAuth.instance.authStateChanges().listen((user) {
    if (user != null) {
      NotificationCenter.I.setUser(user.uid);
    } else {
      NotificationCenter.I.dispose();
    }
  });

  // ===========================================================================
  // START APPLICATION
  // ===========================================================================

  runApp(const UtilityHubApp());
}

class UtilityHubApp extends StatelessWidget {
  const UtilityHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UtilityHub',
      debugShowCheckedModeBanner: false,

      // =========================================================================
      // GLOBAL THEME
      // =========================================================================
      theme: GiftPayTheme.theme,

      // =========================================================================
      // GLOBAL BACKGROUND
      // =========================================================================
      builder: (context, child) {
        final Widget currentChild = child ?? const SizedBox.shrink();

        // Splash and parent landing page already control their own backgrounds.
        if (currentChild is GiftPaySplash ||
            currentChild is GiftTechLandingPage) {
          return currentChild;
        }

        return GiftPayBackground(child: currentChild);
      },

      // =========================================================================
      // ROOT
      //
      // WEB:
      //   Gift Technology parent landing page
      //
      // MOBILE APP:
      //   GiftPay splash → authentication flow
      // =========================================================================
      home: kIsWeb ? const GiftTechLandingPage() : const GiftPaySplash(),

      // =========================================================================
      // ROUTES
      //
      // appRoutes:
      //   GiftPay application routes
      //
      // giftTechRoutes:
      //   Parent Gift Technology routes
      //
      // Both remain available.
      // =========================================================================
      routes: {...appRoutes, ...giftTechRoutes},
    );
  }
}

/// ============================================================================
/// AUTH GATE
///
/// Determines whether the user sees:
///
///   authenticated → HomeShell
///   unauthenticated → LoginScreen
///
/// This logic is intentionally unchanged.
/// ============================================================================

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),

      builder: (context, snapshot) {
        // ----------------------------------------------------------------------
        // AUTHENTICATION STATE LOADING
        // ----------------------------------------------------------------------

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ----------------------------------------------------------------------
        // AUTHENTICATED
        // ----------------------------------------------------------------------

        if (snapshot.hasData) {
          return const HomeShell();
        }

        // ----------------------------------------------------------------------
        // NOT AUTHENTICATED
        // ----------------------------------------------------------------------

        return const LoginScreen();
      },
    );
  }
}
