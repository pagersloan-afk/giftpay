import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

// ROUTES
import 'app/routes.dart';

// SCREENS
import 'package:utilityhub/features/auth/login/login_screen.dart';
import 'package:utilityhub/features/home/home_screen.dart';

// GLOBAL THEME
import 'package:utilityhub/core/theme/giftpay_theme.dart';

// ⭐ NOTIFICATION CENTER
import 'package:utilityhub/features/notifications/notification_center.dart';

// ⭐ GLOBAL BACKGROUND WRAPPER
import 'package:utilityhub/core/widgets/giftpay_background.dart';

// ⭐ SPLASH SCREEN
import 'package:utilityhub/features/splash/giftpay_splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Supabase
  await supa.Supabase.initialize(
    url: "https://mzvwtxozwnprsiipoxkx.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im16dnd0eG96d25wcnNpaXBveGt4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUwMjEyOTksImV4cCI6MjA5MDU5NzI5OX0.wchked2h0b5OMvu8qKi9pkYIPJs4_PX5Mqx7HNEpmto",
  );

  // ⭐ Attach NotificationCenter to FirebaseAuth
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

      // ⭐ GLOBAL THEME
      theme: GiftPayTheme.theme,

      // ⭐ GLOBAL BACKGROUND FOR ALL SCREENS EXCEPT SPLASH
      builder: (context, child) {
        if (child is GiftPaySplash) return child;
        return GiftPayBackground(child: child!);
      },

      // ⭐ SHOW SPLASH FIRST
      home: const GiftPaySplash(),

      // ⭐ ROUTES STILL WORK AS BEFORE
      routes: appRoutes,
    );
  }
}

/// ⭐ AUTH GATE — Controls whether user sees Login or Home
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
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
