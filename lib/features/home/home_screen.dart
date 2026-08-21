import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:utilityhub/core/widgets/app_header.dart';
import 'package:utilityhub/core/widgets/app_responsive_layout.dart';
import 'package:utilityhub/core/widgets/giftpay_background.dart';
import 'package:utilityhub/core/widgets/sidebar/app_sidebar.dart';

import 'home_body.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ✅ Persist the ScaffoldKey across rebuilds
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isMobileWeb = kIsWeb && width < 750;
    final activeRoute = ModalRoute.of(context)?.settings.name ?? "/home";

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,

      drawer: isMobileWeb
          ? Drawer(
              backgroundColor: const Color(0xFF0F1115),
              child: SafeArea(
                child: AppSidebar(
                  activeRoute: activeRoute,
                  closeDrawerOnNavigate: true,
                ),
              ),
            )
          : null,

      appBar: AppHeader(
        mobileWeb: isMobileWeb,
        onMenuTap: isMobileWeb
            ? () {
                _scaffoldKey.currentState?.openDrawer();
              }
            : null,
      ),

      body: GiftPayBackground(
        child: const AppResponsiveLayout(child: HomeBody()),
      ),
    );
  }
}
