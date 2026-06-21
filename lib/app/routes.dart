import 'package:flutter/material.dart';
import 'package:utilityhub/core/widgets/giftpay_background.dart';

// Auth
import 'package:utilityhub/features/auth/login/login_screen.dart';
import 'package:utilityhub/features/auth/verify_email_screen.dart';

// Home
import 'package:utilityhub/features/home/home_screen.dart';

// Electricity
import 'package:utilityhub/features/electricity/electricity_screen.dart';

// Airtime & Data
import 'package:utilityhub/features/airtime/airtime_screen.dart';
import 'package:utilityhub/features/data/data_screen.dart';

// Cable
import 'package:utilityhub/features/cable/cable_screen.dart';

// Gift Cards
import 'package:utilityhub/features/giftcards/buy/buy_giftcard_screen.dart';
import 'package:utilityhub/features/giftcards/trade/submit_trade.dart';
import 'package:utilityhub/features/services/services_screen.dart';

// Wallet
import 'package:utilityhub/features/wallet/wallet_screen.dart';
import 'package:utilityhub/features/wallet/fund_wallet_screen.dart';
import 'package:utilityhub/features/wallet/withdraw_screen.dart';
import 'package:utilityhub/features/wallet/transfer/transfer_screen.dart';

// Transactions
import 'package:utilityhub/features/transaction-history/transaction_history_screen.dart';

// Notifications
import 'package:utilityhub/features/notifications/notification_screen.dart';

// KYC
import 'package:utilityhub/features/kyc/kyc_screen.dart';
import 'package:utilityhub/features/kyc/kyc_pending_screen.dart';
import 'package:utilityhub/features/kyc/kyc_success_screen.dart';

// Profile
import 'package:utilityhub/features/profile/profile_screen.dart';

// PS Games
import 'package:utilityhub/features/ps_games/ps_games_screen.dart';

// Betting
import 'package:utilityhub/features/betting/betting_screen.dart';

// Paystack callback
import 'package:utilityhub/features/payments/paystack_web_callback_screen.dart';
import 'package:utilityhub/settings/settings_screen.dart';

// ⭐ WRAPPER — applies GiftPayBackground to every screen
Widget wrap(Widget screen) {
  return GiftPayBackground(child: screen);
}

final Map<String, WidgetBuilder> appRoutes = {
  '/login': (_) => wrap(const LoginScreen()),
  '/home': (_) => wrap(const HomeScreen()),

  // Electricity
  '/electricity': (_) => wrap(const ElectricityScreen()),

  // Airtime
  '/airtime': (_) => wrap(const AirtimeScreen()),

  // Data
  '/data': (_) => wrap(const DataScreen()),

  // Gift Cards
  '/giftcards': (_) => wrap(const BuyGiftCardScreen()),
  '/trade': (_) => wrap(const SubmitTradePage()),

  // PS5 Games
  '/psgames': (_) => wrap(const PSGamesScreen()),

  // Cable TV
  '/cable': (_) => wrap(const CableScreen()),

  // Profile
  '/profile': (_) => wrap(const ProfileScreen()),

  // Paystack callback
  '/payment-complete': (_) => wrap(const PaystackWebCallbackScreen()),

  // Wallet
  '/wallet': (_) => wrap(WalletScreen()),
  '/fund': (_) => wrap(FundWalletScreen()),
  '/withdraw': (_) => wrap(WithdrawScreen()),
  '/transactions': (_) => wrap(TransactionHistoryScreen()),

  // KYC
  '/kyc': (_) => wrap(const KycScreen()),
  '/kyc-success': (_) => wrap(const KycSuccessScreen()),
  '/kyc-pending': (_) => wrap(const KycPendingScreen()),

  // Notifications
  '/notifications': (_) => wrap(const NotificationScreen()),

  // Verify email
  '/verify-email': (_) => wrap(const VerifyEmailScreen()),

  // Transfer
  '/transfer': (_) => wrap(const TransferScreen()),

  // Betting
  '/betting': (_) => wrap(const BettingScreen()),

  // Settings
  '/settings': (_) => wrap(const SettingsScreen()),

  // Services
  '/services': (_) => wrap(const ServicesScreen()),
};
