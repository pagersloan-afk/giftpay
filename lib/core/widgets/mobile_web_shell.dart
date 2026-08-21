import 'package:flutter/material.dart';

import 'package:utilityhub/core/widgets/app_header.dart';
import 'package:utilityhub/core/widgets/giftpay_background.dart';
import 'package:utilityhub/core/widgets/sidebar/app_sidebar.dart';

class MobileWebShell extends StatefulWidget {
  final Widget child;

  const MobileWebShell({super.key, required this.child});

  @override
  State<MobileWebShell> createState() => _MobileWebShellState();
}

class _MobileWebShellState extends State<MobileWebShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final routeName = ModalRoute.of(context)?.settings.name ?? "/home";

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      appBar: AppHeader(
        mobileWeb: true,
        onMenuTap: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      drawer: Drawer(
        elevation: 24,
        backgroundColor: const Color(0xFF0F1115),
        width: 280,
        child: SafeArea(child: AppSidebar(activeRoute: routeName)),
      ),
      body: GiftPayBackground(child: widget.child),
    );
  }
}
