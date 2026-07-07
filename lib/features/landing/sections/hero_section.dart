import 'package:flutter/material.dart';
import '../widgets/phone_showcase_carousel.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) return "Good morning";
    if (hour < 17) return "Good afternoon";
    return "Good evening";
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;

    return Center(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 1400),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 20,
          vertical: isMobile ? 24 : 50,
        ),
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 243, 241, 241),
        ),
        child: isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _loginPanel(isMobile),
                  const SizedBox(height: 28),
                  _walletPromo(context, isMobile),
                  const SizedBox(height: 28),
                  _servicesPromo(context, isMobile),
                  const SizedBox(height: 28),
                  _phonePreview(isMobile),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 1, child: _loginPanel(isMobile)),
                  const SizedBox(width: 40),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        _walletPromo(context, isMobile),
                        const SizedBox(height: 28),
                        _servicesPromo(context, isMobile),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                  Expanded(flex: 1, child: _phonePreview(isMobile)),
                ],
              ),
      ),
    );
  }

  // ⭐ COLUMN 1 — LOGIN PANEL
  Widget _loginPanel(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 18 : 28),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getGreeting(),
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: isMobile ? 18 : 20,
              color: Colors.black,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 20),

          TextField(
            decoration: InputDecoration(
              labelText: "Username",
              labelStyle: const TextStyle(color: Colors.black87),
              border: const OutlineInputBorder(),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black38),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
            style: const TextStyle(color: Colors.black),
          ),
          const SizedBox(height: 14),

          TextField(
            obscureText: true,
            decoration: InputDecoration(
              labelText: "Password",
              labelStyle: const TextStyle(color: Colors.black87),
              border: const OutlineInputBorder(),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black38),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
            style: const TextStyle(color: Colors.black),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Checkbox(value: false, onChanged: (_) {}),
              Text(
                "Save username",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: isMobile ? 13 : 15,
                  color: Colors.black,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB31B1B),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 26 : 32,
                    vertical: isMobile ? 14 : 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  "Sign On",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 15 : 17,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 26 : 32,
                    vertical: isMobile ? 14 : 16,
                  ),
                  side: const BorderSide(color: Colors.black87),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  "Enroll",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: isMobile ? 15 : 17,
                    color: Colors.black,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _link("Forgot username or password?", isMobile),
              _link("Security Center", isMobile),
              _link("Privacy, Cookies, and Legal", isMobile),
            ],
          ),
        ],
      ),
    );
  }

  // ⭐ COLUMN 2 — GIFT PAY WALLET PROMO
  Widget _walletPromo(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 18 : 28),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your Digital Wallet, Supercharged",
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: isMobile ? 18 : 20,
              color: Colors.black,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            "Fund your wallet instantly, withdraw anytime, and manage all your payments in one secure place.",
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: isMobile ? 14 : 15,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB31B1B),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 30 : 38,
                vertical: isMobile ? 16 : 18,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text(
              "Open Wallet",
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 17,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ⭐ COLUMN 2 — GIFT PAY SERVICES PROMO
  Widget _servicesPromo(BuildContext context, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 18 : 28),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "All Your Utilities, One Platform",
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: isMobile ? 18 : 20,
              color: Colors.black,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            "Electricity, Airtime, Data, Gift Cards, TV, Health — fast, reliable, and always available.",
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: isMobile ? 14 : 15,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB31B1B),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 26 : 32,
                vertical: isMobile ? 14 : 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text(
              "Explore Services",
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ⭐ COLUMN 3 — PHONE PREVIEW (animated screenshots)
  Widget _phonePreview(bool isMobile) {
    return PhoneShowcaseCarousel(
      screens: [
        'assets/screens/screen1.png',
        'assets/screens/screen2.png',
        'assets/screens/screen3.png',
        'assets/screens/screen4.png',
        'assets/screens/screen5.png',
        'assets/screens/screen6.png',
        'assets/screens/screen7.png',
        'assets/screens/screen8.png',
        'assets/screens/screen9.png',
        'assets/screens/screen10.png',
      ],
      height: isMobile ? 300 : 420,
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _link(String text, bool isMobile) {
    return TextButton(
      onPressed: () {},
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: isMobile ? 13 : 15,
          color: Colors.black87,
          height: 1.4,
        ),
      ),
    );
  }
}
