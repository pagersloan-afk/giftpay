import 'package:flutter/material.dart';
import 'package:utilityhub/features/gift_techlanding/screens/about.dart';
import 'package:utilityhub/features/gift_techlanding/screens/community.dart';
import 'package:utilityhub/features/gift_techlanding/screens/contact.dart';
import 'package:utilityhub/features/gift_techlanding/screens/footer/about_gift_technology.dart';
import 'package:utilityhub/features/gift_techlanding/screens/footer/accessibility.dart';
import 'package:utilityhub/features/gift_techlanding/screens/footer/airtime_distribution.dart';
import 'package:utilityhub/features/gift_techlanding/screens/footer/brand_resources.dart';
import 'package:utilityhub/features/gift_techlanding/screens/footer/bulk_electricity_token.dart';
import 'package:utilityhub/features/gift_techlanding/screens/footer/businesses.dart';
import 'package:utilityhub/features/gift_techlanding/screens/footer/careers.dart';
import 'package:utilityhub/features/gift_techlanding/screens/footer/community_standards.dart';
import 'package:utilityhub/features/gift_techlanding/screens/footer/company_info.dart';
import 'package:utilityhub/features/gift_techlanding/screens/footer/cookie_policy.dart';
import 'package:utilityhub/features/gift_techlanding/screens/footer/corporate_data_plans.dart';
import 'package:utilityhub/features/gift_techlanding/screens/footer/creators.dart';
import 'package:utilityhub/features/gift_techlanding/screens/footer/data_privacy.dart';
import 'package:utilityhub/features/gift_techlanding/screens/footer/developers.dart';
import 'package:utilityhub/features/gift_techlanding/screens/footer/download_sdk.dart';
import 'package:utilityhub/features/gift_techlanding/screens/footer/elections.dart';
import 'package:utilityhub/features/gift_techlanding/screens/footer/find_store.dart';
import 'package:utilityhub/features/gift_techlanding/screens/footer/gift_pos.dart';
import 'package:utilityhub/features/gift_techlanding/screens/footer/giftcard_market_place.dart';
import 'package:utilityhub/features/gift_techlanding/screens/footer/giftpay_wallet.dart';
import 'package:utilityhub/features/gift_techlanding/screens/footer/help_center.dart';
import 'package:utilityhub/features/gift_techlanding/screens/footer/investors.dart';
import 'package:utilityhub/features/gift_techlanding/screens/footer/legal.dart';
import 'package:utilityhub/features/gift_techlanding/screens/footer/media_gallery.dart';
import 'package:utilityhub/features/gift_techlanding/screens/footer/newsroom.dart';
import 'package:utilityhub/features/gift_techlanding/screens/footer/non_profits.dart';
import 'package:utilityhub/features/gift_techlanding/screens/footer/order_status.dart';
import 'package:utilityhub/features/gift_techlanding/screens/footer/partner_program.dart';
import 'package:utilityhub/features/gift_techlanding/screens/footer/privacy_policy.dart';
import 'package:utilityhub/features/gift_techlanding/screens/footer/responsible_practices.dart';
import 'package:utilityhub/features/gift_techlanding/screens/footer/returns.dart';
import 'package:utilityhub/features/gift_techlanding/screens/footer/safety_center.dart';
import 'package:utilityhub/features/gift_techlanding/screens/footer/tech_for_good.dart';
import 'package:utilityhub/features/gift_techlanding/screens/footer/terms.dart';
import 'package:utilityhub/features/gift_techlanding/screens/footer/terms_of_sale.dart';
import 'package:utilityhub/features/gift_techlanding/screens/footer/utilities_hub.dart';

// ⭐ PARENT LANDING
import 'package:utilityhub/features/gift_techlanding/gift_techlanding_page.dart';
import 'package:utilityhub/features/gift_techlanding/screens/products.dart';
import 'package:utilityhub/settings/sections/terms_of_service.dart';

final Map<String, WidgetBuilder> giftTechRoutes = {
  // ⭐ Parent Landing
  '/gifttech': (_) => const GiftTechLandingPage(),

  // ⭐ STORE
  '/giftpay-wallet': (_) => const GiftPayWalletScreen(),
  '/giftpos': (_) => const GiftPOSScreen(),
  '/giftcard-marketplace': (_) => const GiftCardMarketplaceScreen(),
  '/utilities-hub': (_) => const UtilitiesHubScreen(),
  '/bulk-electricity': (_) => const GiftTechBulkElectricityScreen(),
  '/corporate-data': (_) => const CorporateDataScreen(),
  '/airtime-distribution': (_) => const AirtimeDistributionScreen(),

  // ⭐ SUPPORT & LEGAL
  '/gift-tech-help-center': (_) => const GiftTechHelpCenterScreen(),
  '/order-status': (_) => const OrderStatusScreen(),
  '/returns': (_) => const ReturnsScreen(),
  '/find-store': (_) => const FindStoreScreen(),
  '/legal': (_) => const LegalScreen(),
  '/terms-of-sale': (_) => const TermsOfSaleScreen(),
  '/safety-center': (_) => const SafetyCenterScreen(),

  // ⭐ COMMUNITY
  '/creators': (_) => const CreatorsScreen(),
  '/developers': (_) => const DevelopersScreen(),
  '/business': (_) => const GiftTechBusinessesScreen(),
  '/nonprofits': (_) => const NonProfitsScreen(),
  '/download-sdks': (_) => const DownloadSDKsScreen(),
  '/partner-program': (_) => const PartnerProgramScreen(),
  '/tech-for-good': (_) => const TechForGoodScreen(),

  // ⭐ OUR ACTIONS
  '/data-privacy': (_) => const DataPrivacyScreen(),
  '/responsibility': (_) => const ResponsiblePracticesScreen(),
  '/accessibility': (_) => const AccessibilityScreen(),
  '/elections': (_) => const ElectionsScreen(),

  // ⭐ ABOUT US
  '/about': (_) => const AboutGiftTechScreen(),
  '/company-info': (_) => const CompanyInfoScreen(),
  '/careers': (_) => const CareersScreen(),
  '/media': (_) => const MediaGalleryScreen(),
  '/brand-resources': (_) => const BrandResourcesScreen(),
  '/investors': (_) => const InvestorsScreen(),
  '/newsroom': (_) => const NewsroomScreen(),

  // ⭐ POLICIES
  '/community-standards': (_) => const CommunityStandardsScreen(),
  '/privacy-policy': (_) => const PrivacyPolicyScreen(),
  '/terms': (_) => const GiftTechTermsScreen(),
  '/cookie-policy': (_) => const CookiePolicyScreen(),

  // ⭐ PRIMARY SITE NAVIGATION
  '/about-gifttech': (_) => const GiftTechAboutScreen(),
  '/products': (_) => const GiftTechProductsScreen(),
  '/community': (_) => const GiftTechCommunityScreen(),
  '/contact': (_) => const GiftTechContactScreen(),
};
