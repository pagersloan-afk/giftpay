import 'package:flutter/material.dart';

class GiftPayApiHeroSection extends StatelessWidget {
  const GiftPayApiHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final bool mobile = width < 700;
    final bool tablet = width >= 700 && width < 1050;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: mobile
            ? 22
            : tablet
            ? 38
            : 64,
        vertical: mobile ? 34 : 58,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF172B50), Color(0xFF273D68), Color(0xFF345A9C)],
        ),
        borderRadius: BorderRadius.circular(mobile ? 22 : 28),
      ),
      child: mobile ? const _MobileHero() : const _DesktopHero(),
    );
  }
}

class _DesktopHero extends StatelessWidget {
  const _DesktopHero();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final bool compact = width < 1050;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: compact ? 11 : 10, child: const _HeroCopy()),
        SizedBox(width: compact ? 28 : 55),
        const Expanded(flex: 9, child: _ApiTerminal()),
      ],
    );
  }
}

class _MobileHero extends StatelessWidget {
  const _MobileHero();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_HeroCopy(), SizedBox(height: 30), _ApiTerminal()],
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final bool mobile = width < 700;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.code_rounded, color: Color(0xFF75A1FF), size: 16),
              SizedBox(width: 7),
              Text(
                'GIVE YOUR PRODUCT ACCESS TO GIFTPAY',
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 10,
                  letterSpacing: 0.9,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Build on GiftPay.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: mobile ? 38 : 48,
            height: 1.05,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Power your platform with real-time utility infrastructure.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: mobile ? 23 : 30,
            height: 1.15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFDCE8FF),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Connect your applications to GiftPay services and give your '
          'customers access to airtime, data, electricity, TV and other '
          'digital services through a single integration layer.',
          style: TextStyle(
            fontFamily: 'SegoeUI',
            fontSize: mobile ? 15 : 17,
            height: 1.65,
            color: Colors.white.withOpacity(0.76),
          ),
        ),
        const SizedBox(height: 25),
        const Wrap(
          spacing: 9,
          runSpacing: 9,
          children: [
            _HeroBadge(icon: Icons.bolt_rounded, label: 'Real-time vending'),
            _HeroBadge(icon: Icons.webhook_rounded, label: 'Webhooks'),
            _HeroBadge(icon: Icons.security_rounded, label: 'Secure APIs'),
          ],
        ),
      ],
    );
  }
}

class _HeroBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.075),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.11)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF9FC0FF)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'SegoeUI',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ApiTerminal extends StatelessWidget {
  const _ApiTerminal();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final bool mobile = width < 700;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0E1A31),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 35,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.035),
              border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
            ),
            child: Row(
              children: [
                _Dot(color: Colors.redAccent.withOpacity(0.75)),
                const SizedBox(width: 6),
                _Dot(color: Colors.amber.withOpacity(0.75)),
                const SizedBox(width: 6),
                _Dot(color: Colors.greenAccent.withOpacity(0.75)),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text(
                    'giftpay_api',
                    style: TextStyle(
                      fontFamily: 'SegoeUI',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF9BA9C4),
                    ),
                  ),
                ),
                const Icon(
                  Icons.more_horiz_rounded,
                  color: Color(0xFF64738F),
                  size: 18,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(mobile ? 17 : 22),
            child: const _CodeContent(),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;

  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _CodeContent extends StatelessWidget {
  const _CodeContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'POST /v1/transactions/vend',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF82AFFF),
          ),
        ),
        const SizedBox(height: 15),
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11.5,
              height: 1.65,
              color: Color(0xFFCAD5E8),
            ),
            children: [
              TextSpan(
                text: '{\n',
                style: TextStyle(color: Color(0xFFB7C7DF)),
              ),
              TextSpan(
                text: '  "service": ',
                style: TextStyle(color: Color(0xFF9AA9C1)),
              ),
              TextSpan(
                text: '"airtime",\n',
                style: TextStyle(color: Color(0xFFA7D7B2)),
              ),
              TextSpan(
                text: '  "network": ',
                style: TextStyle(color: Color(0xFF9AA9C1)),
              ),
              TextSpan(
                text: '"MTN",\n',
                style: TextStyle(color: Color(0xFFA7D7B2)),
              ),
              TextSpan(
                text: '  "amount": ',
                style: TextStyle(color: Color(0xFF9AA9C1)),
              ),
              TextSpan(
                text: '500,\n',
                style: TextStyle(color: Color(0xFFE5C27A)),
              ),
              TextSpan(
                text: '  "recipient": ',
                style: TextStyle(color: Color(0xFF9AA9C1)),
              ),
              TextSpan(
                text: '"080********",\n',
                style: TextStyle(color: Color(0xFFA7D7B2)),
              ),
              TextSpan(
                text: '  "reference": ',
                style: TextStyle(color: Color(0xFF9AA9C1)),
              ),
              TextSpan(
                text: '"GP-8F21A7"\n',
                style: TextStyle(color: Color(0xFFA7D7B2)),
              ),
              TextSpan(
                text: '}',
                style: TextStyle(color: Color(0xFFB7C7DF)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: const Color(0xFF183A2C),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: const Color(0xFF4E9B76)),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: 15,
                color: Color(0xFF6ED49A),
              ),
              SizedBox(width: 7),
              Text(
                'Transaction accepted',
                style: TextStyle(
                  fontFamily: 'SegoeUI',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFB9E9CB),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
