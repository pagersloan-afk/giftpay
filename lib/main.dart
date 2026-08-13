import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:utilityhub/app/gifttech_routes.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

// ROUTES
import 'app/routes.dart';

// GLOBAL THEME
import 'package:utilityhub/core/theme/giftpay_theme.dart';

// ⭐ NOTIFICATION CENTER
import 'package:utilityhub/features/notifications/notification_center.dart';

// ⭐ GLOBAL BACKGROUND WRAPPER
import 'package:utilityhub/core/widgets/giftpay_background.dart';

// ⭐ SPLASH SCREEN
import 'package:utilityhub/features/splash/giftpay_splash.dart';

// ⭐ AUTH GATE
import 'package:utilityhub/features/auth/login/login_screen.dart';
import 'package:utilityhub/features/home/home_shell.dart';

// ⭐ NEW PARENT LANDING PAGE (WEB)
import 'package:utilityhub/features/gift_techlanding/gift_techlanding_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await supa.Supabase.initialize(
    url: "https://mzvwtxozwnprsiipoxkx.supabase.co",
    anonKey: "YOUR_KEY",
  );

  FirebaseAuth.instance.authStateChanges().listen((user) {
    if (user != null) {
      NotificationCenter.I.setUser(user.uid);
    } else {
      NotificationCenter.I.dispose();
    }
  });

  runApp(const UtilityHubApp());
}

class UtilityHubApp extends StatelessWidget {
  const UtilityHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UtilityHub',
      debugShowCheckedModeBanner: false,
      theme: GiftPayTheme.theme,
      builder: (context, child) {
        // Splash and parent landing must NOT be wrapped
        if (child is GiftPaySplash || child is GiftTechLandingPage) {
          return child!;
        }
        return GiftPayBackground(child: child!);
      },

      // ⭐ MOBILE → Splash → Login
      // ⭐ WEB → Parent Landing
      home: kIsWeb ? const GiftTechLandingPage() : const GiftPaySplash(),

      routes: {
        ...appRoutes, // GiftPay app routes
        ...giftTechRoutes, // GiftTech parent landing routes
      },
    );
  }
}

/// ⭐ AUTH GATE — Controls whether user sees Login or HomeShell
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const HomeShell();
        }

        return const LoginScreen();
      },
    );
  }
}
