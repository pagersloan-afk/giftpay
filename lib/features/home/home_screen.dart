import 'package:flutter/material.dart';
import 'package:utilityhub/core/widgets/app_header.dart';
import 'package:utilityhub/core/widgets/app_responsive_layout.dart';
import 'package:utilityhub/features/profile/profile_drawer.dart';
import 'package:utilityhub/core/widgets/giftpay_background.dart';
import 'home_body.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GiftPayBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        drawer: const ProfileDrawer(),
        appBar: const AppHeader(),
        body: const AppResponsiveLayout(child: HomeBody()),
      ),
    );
  }
}
