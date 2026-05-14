import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:utilityhub/features/wallet/services/wallet_service.dart';

class WalletCard extends StatefulWidget {
  const WalletCard({super.key});

  @override
  State<WalletCard> createState() => _WalletCardState();
}

class _WalletCardState extends State<WalletCard>
    with SingleTickerProviderStateMixin {
  final WalletService wallet = WalletService();

  late AnimationController _controller;
  late Animation<double> _balanceAnimation;

  double _oldBalance = 0;
  double _newBalance = 0;

  bool _isHidden = false;

  StreamSubscription<double>? _balanceSub;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _balanceAnimation = Tween<double>(begin: 0, end: 0).animate(_controller);

    _balanceSub = wallet.balanceStream().listen((value) {
      if (!mounted) return;

      setState(() {
        _oldBalance = _newBalance;
        _newBalance = value;

        _balanceAnimation = Tween<double>(begin: _oldBalance, end: _newBalance)
            .animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
            );

        _controller.forward(from: 0);
      });
    });
  }

  @override
  void dispose() {
    _balanceSub?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [const Color(0x334FC3F7), Colors.transparent],
                radius: 1.2,
                center: Alignment.topCenter,
              ),
            ),
          ),
        ),

        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4FC3F7).withOpacity(0.10),
                blurRadius: 22,
                offset: const Offset(0, 6),
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        color: Colors.white70,
                        size: 20,
                      ),
                      SizedBox(width: 6),
                      Text(
                        "Wallet Balance",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  GestureDetector(
                    onTap: () {
                      setState(() => _isHidden = !_isHidden);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                        ),
                      ),
                      child: Icon(
                        _isHidden ? Icons.visibility_off : Icons.visibility,
                        size: 18,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _isHidden
                    ? const Text(
                        "•••••••",
                        key: ValueKey("hidden"),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      )
                    : AnimatedBuilder(
                        key: const ValueKey("visible"),
                        animation: _controller,
                        builder: (context, child) {
                          final formatted = NumberFormat(
                            "#,##0",
                          ).format(_balanceAnimation.value);

                          return Text(
                            "₦$formatted",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 26),

              Row(
                children: [
                  _walletButton(
                    label: "Deposit",
                    icon: Icons.add,
                    route: "/fund",
                    color: const Color(0xFF4FC3F7),
                  ),
                  const SizedBox(width: 12),
                  _walletButton(
                    label: "Withdraw",
                    icon: Icons.arrow_upward,
                    route: "/transfer",
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 12),
                  _walletButton(
                    label: "History",
                    icon: Icons.receipt_long,
                    route: "/transactions",
                    color: Colors.white70,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _walletButton({
    required String label,
    required IconData icon,
    required String route,
    required Color color,
  }) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Expanded(
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, route),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8), // compact height
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ⭐ ICON ONLY ON DESKTOP
              if (!isMobile) ...[
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 6),
              ],

              // ⭐ TEXT ALWAYS CENTERED
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
