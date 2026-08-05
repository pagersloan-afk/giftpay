import 'package:flutter/material.dart';
import 'package:utilityhub/core/theme/giftpay_theme.dart';
import 'package:utilityhub/core/widgets/giftpay_background.dart';

class SignupPinScreen extends StatefulWidget {
  const SignupPinScreen({super.key});

  @override
  State<SignupPinScreen> createState() => _SignupPinScreenState();
}

class _SignupPinScreenState extends State<SignupPinScreen>
    with SingleTickerProviderStateMixin {
  String pin = "";

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 1.12,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void addDigit(String digit) {
    if (pin.length >= 4) return;

    setState(() => pin += digit);

    _controller.forward().then((_) => _controller.reverse());

    if (pin.length == 4) {
      Future.delayed(
        const Duration(milliseconds: 350),
        () => _showSecureAnimation(),
      );
    }
  }

  void removeDigit() {
    if (pin.isEmpty) return;

    setState(() {
      pin = pin.substring(0, pin.length - 1);
    });
  }

  void _showSecureAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: const Color(0xFF10141B),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: GiftPayTheme.primaryBlue.withOpacity(.18),
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    size: 45,
                    color: Color(0xFF4FC3F7),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Wallet Secured",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Your GiftPay PIN has been created successfully.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, "/signup-wallet");
                  },
                  child: const Text("Continue"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GiftPayBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                // ⭐ DESKTOP WIDTH LIMIT — adjust this to your taste
                maxWidth: isDesktop ? 450 : double.infinity,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 44,
                  vertical: 35,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Logo
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.blue.withOpacity(.35),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Image.asset(
                        "assets/logo/giftpay_1.png",
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 35),

                    const Text(
                      "Secure Your Wallet",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      "Create a 4-digit PIN to protect your GiftPay account and payments.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFFD1D5DB), fontSize: 15),
                    ),

                    const SizedBox(height: 35),

                    // Glass Card
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 30,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.06),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(.12),
                        ),
                      ),
                      child: Column(
                        children: [
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(4, (index) {
                                bool filled = index < pin.length;
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: filled
                                        ? const Color(0xFF4FC3F7)
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: filled
                                          ? const Color(0xFF4FC3F7)
                                          : Colors.white30,
                                      width: 2,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),

                          const SizedBox(height: 35),

                          // ⭐ KEYPAD HEIGHT — reduce this to shrink buttons
                          SizedBox(
                            height: isDesktop ? 310 : 320,
                            child: _buildNumberPad(isDesktop),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: pin.length == 4
                            ? _showSecureAnimation
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GiftPayTheme.primaryBlue,
                          disabledBackgroundColor: Colors.white12,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text("Continue"),
                      ),
                    ),

                    const SizedBox(height: 25),

                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 16,
                          color: Colors.white54,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Protected by GiftPay Security",
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ⭐ KEYPAD — now responsive for desktop & mobile
  Widget _buildNumberPad(bool isDesktop) {
    final numbers = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "", "0", "⌫"];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: numbers.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: isDesktop ? 10 : 12, // ⭐ reduce spacing on desktop
        crossAxisSpacing: isDesktop ? 10 : 12,
        childAspectRatio: isDesktop ? 1.75 : 1, // ⭐ shrink buttons on desktop
      ),
      itemBuilder: (context, index) {
        final value = numbers[index];

        if (value == "") return const SizedBox();

        return InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: () {
            if (value == "⌫") {
              removeDigit();
            } else {
              addDigit(value);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(.08),
              border: Border.all(color: Colors.white12),
            ),
            alignment: Alignment.center,
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: isDesktop ? 18 : 20, // ⭐ smaller text on desktop
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }
}
