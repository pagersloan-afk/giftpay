import 'package:flutter/material.dart';

class GiftPayWalletHeroSection extends StatelessWidget {
  const GiftPayWalletHeroSection({super.key});

  static const Color navy = Color(0xFF273D68);
  static const Color blue = Color(0xFF4A6BB8);
  static const Color lightBlue = Color(0xFF75A1FF);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final bool mobile = width < 700;
    final bool tablet = width >= 700 && width < 1100;

    final double horizontalPadding = mobile
        ? 22
        : tablet
        ? 40
        : 64;

    final double verticalPadding = mobile ? 42 : 68;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3157), Color(0xFF273D68), Color(0xFF34548F)],
        ),
        borderRadius: BorderRadius.circular(mobile ? 22 : 28),
      ),
      child: Stack(
        children: [
          // Decorative glow
          Positioned(
            right: mobile ? -80 : -40,
            top: mobile ? -70 : -55,
            child: IgnorePointer(
              child: Container(
                width: mobile ? 210 : 300,
                height: mobile ? 210 : 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [lightBlue.withOpacity(0.20), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),

          // Content
          Column(
            crossAxisAlignment: mobile
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withOpacity(0.14)),
                ),
                child: const Text(
                  'GIFTPAY WALLET',
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: 11,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Text(
                  'One wallet for your everyday digital payments.',
                  textAlign: mobile ? TextAlign.center : TextAlign.left,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: mobile
                        ? 34
                        : tablet
                        ? 42
                        : 50,
                    height: 1.08,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.8,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Text(
                  'Fund your GiftPay balance and use it to pay for airtime, '
                  'data, electricity, entertainment and other supported '
                  'digital services — quickly and from one secure account.',
                  textAlign: mobile ? TextAlign.center : TextAlign.left,
                  style: TextStyle(
                    fontFamily: 'SegoeUI',
                    fontSize: mobile ? 16 : 18,
                    height: 1.65,
                    color: Colors.white.withOpacity(0.82),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Product highlights
              Wrap(
                alignment: mobile ? WrapAlignment.center : WrapAlignment.start,
                spacing: 10,
                runSpacing: 10,
                children: const [
                  _HeroPill(
                    icon: Icons.account_balance_wallet_rounded,
                    label: 'Wallet balance',
                  ),
                  _HeroPill(
                    icon: Icons.flash_on_rounded,
                    label: 'Fast payments',
                  ),
                  _HeroPill(
                    icon: Icons.receipt_long_rounded,
                    label: 'Transaction history',
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Trust note
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Row(
                  mainAxisAlignment: mobile
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.10),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_user_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Flexible(
                      child: Text(
                        'Designed to give you a clear view of your balance, '
                        'payments and transaction activity in one place.',
                        textAlign: mobile ? TextAlign.center : TextAlign.left,
                        style: TextStyle(
                          fontFamily: 'SegoeUI',
                          fontSize: 13,
                          height: 1.5,
                          color: Colors.white.withOpacity(0.68),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.085),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 17),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
