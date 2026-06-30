import 'package:flutter/material.dart';
import 'package:utilityhub/core/widgets/giftpay_background.dart';

// Auth
import 'package:utilityhub/features/auth/login/login_screen.dart';
import 'package:utilityhub/features/auth/login/login_security_screen.dart';
import 'package:utilityhub/features/auth/pin/authorization_pin_screen.dart';
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
import 'package:utilityhub/features/limits/edit_daily_airtime_limit_screen.dart';
import 'package:utilityhub/features/limits/edit_daily_transfer_limit_screen.dart';
import 'package:utilityhub/features/limits/limits_screen.dart';
import 'package:utilityhub/features/services/services_screen.dart';
import 'package:utilityhub/features/statement/statement_download_screen.dart';
import 'package:utilityhub/features/statement/statement_pdf_screen.dart';
import 'package:utilityhub/features/statement/statement_screen.dart';

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
import 'package:utilityhub/settings/change_password_screen.dart';
import 'package:utilityhub/settings/currency_display_screen.dart';
import 'package:utilityhub/settings/language_screen.dart';
import 'package:utilityhub/settings/linked_devices_screen.dart';
import 'package:utilityhub/settings/quick_actions_customization_screen.dart';
import 'package:utilityhub/settings/sections/contact_support_screen.dart';
import 'package:utilityhub/settings/sections/cookie_policy_screen.dart';
import 'package:utilityhub/settings/sections/help_center_section.dart';
import 'package:utilityhub/settings/sections/kyc_aml_screen.dart';
import 'package:utilityhub/settings/sections/privacy_policy_section.dart';
import 'package:utilityhub/settings/sections/refund_policy_screen.dart';
import 'package:utilityhub/settings/sections/terms_of_service.dart';
import 'package:utilityhub/settings/sections/user_agreement_screen.dart';
import 'package:utilityhub/settings/settings_screen.dart';
import 'package:utilityhub/settings/two_factor_screen.dart';

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

  // Change Password
  '/change-password': (_) => wrap(const ChangePasswordScreen()),

  // Two-Factor Authentication
  '/2fa': (_) => wrap(const TwoFactorScreen()),

  // Linked Devices
  '/linked-devices': (_) => wrap(const LinkedDevicesScreen()),

  // ⭐ PREFERENCES
  '/currency-display': (_) => wrap(const CurrencyDisplayScreen()),
  '/language': (_) => wrap(const LanguageScreen()),
  '/quick-actions-customization': (_) =>
      wrap(const QuickActionsCustomizationScreen()),

  // ⭐ SUPPORT & LEGAL
  '/help-center': (_) => wrap(const HelpCenterScreen()),
  '/contact-support': (_) => wrap(const ContactSupportScreen()),
  '/terms': (_) => wrap(const TermsScreen()),
  '/privacy': (_) => wrap(const PrivacyScreen()),
  '/refund-policy': (_) => wrap(const RefundPolicyScreen()),
  '/cookie-policy': (_) => wrap(const CookiePolicyScreen()),
  '/user-agreement': (_) => wrap(const UserAgreementScreen()),
  '/kyc-aml': (_) => wrap(const KycAmlScreen()),

  // ⭐ STATEMENT & LIMITS
  '/statement': (_) => wrap(const StatementScreen()),
  '/limits': (_) => wrap(const LimitsScreen()),
  '/edit-daily-transfer-limit': (_) =>
      wrap(const EditDailyTransferLimitScreen()),
  '/edit-daily-airtime-limit': (_) => wrap(const EditDailyAirtimeLimitScreen()),
  '/statement-download': (_) => wrap(const StatementDownloadScreen()),
  '/statement-pdf': (_) => wrap(const StatementPdfScreen()),

  // ⭐ ACCOUNT & SECURITY
  '/auth-pin': (_) => wrap(const AuthorizationPinScreen()),
  '/login-security': (_) => wrap(const LoginSecurityScreen()),
};
