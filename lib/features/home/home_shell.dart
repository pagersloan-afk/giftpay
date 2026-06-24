import 'package:flutter/material.dart';
import 'package:utilityhub/features/home/home_screen.dart';
import 'package:utilityhub/features/services/services_screen.dart';
import 'package:utilityhub/features/transaction-history/transaction_history_screen.dart';
import 'package:utilityhub/settings/settings_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;

  final screens = const [
    HomeScreen(),
    TransactionHistoryScreen(),
    ServicesScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F1115),
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.10), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: index,
          onTap: (i) => setState(() => index = i),
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF0AC8FF),
          unselectedItemColor: Colors.white54,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.swap_horiz),
              label: "History",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
              label: "Services",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "Settings",
            ),
          ],
        ),
      ),
    );
  }
}
