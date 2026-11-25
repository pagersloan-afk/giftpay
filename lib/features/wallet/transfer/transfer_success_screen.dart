import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:utilityhub/core/widgets/app_responsive_layout.dart';
import 'package:utilityhub/features/wallet/flutterwave_transfer_receipt_screen.dart';

class TransferSuccessScreen extends StatelessWidget {
  final String amount;
  final String name;
  final String bank;
  final String account;
  final String? reference;

  const TransferSuccessScreen({
    super.key,
    required this.amount,
    required this.name,
    required this.bank,
    required this.account,
    this.reference,
  });

  static const Color _background = Color(0xFF0F1115);
  static const Color _navy = Color(0xFF273D68);
  static const Color _blue = Color(0xFF4A6BB8);
  static const Color _accent = Color(0xFF4FC3F7);
  static const Color _muted = Color(0xFF9AA9BD);

  @override
  Widget build(BuildContext context) {
    final hasReference = reference != null && reference!.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Transfer complete',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.65),
                  radius: 1.15,
                  colors: [Color(0x33273D68), _background],
                ),
              ),
            ),
          ),
          AppResponsiveLayout(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.72, end: 1),
                        duration: const Duration(milliseconds: 520),
                        curve: Curves.easeOutBack,
                        builder: (context, scale, child) => Opacity(
                          opacity: scale.clamp(0.0, 1.0).toDouble(),
                          child: Transform.scale(scale: scale, child: child),
                        ),
                        child: Center(
                          child: Container(
                            width: 104,
                            height: 104,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF123B36),
                              border: Border.all(
                                color: const Color(0xFF34D399).withOpacity(.35),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF34D399).withOpacity(.16),
                                  blurRadius: 34,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Color(0xFF6EE7B7),
                              size: 58,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      const Text(
                        'Payment successful!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 27,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -.5,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        'Your transfer has been completed successfully.\nThe recipient can now receive the funds.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(.66),
                          fontSize: 14,
                          height: 1.55,
                        ),
                      ),
                      const SizedBox(height: 27),
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF1B2A42), Color(0xFF141E2B)],
                          ),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.white.withOpacity(.09)),
                          boxShadow: [
                            BoxShadow(
                              color: _blue.withOpacity(.12),
                              blurRadius: 28,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'AMOUNT SENT',
                              style: TextStyle(
                                color: _muted,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.7,
                              ),
                            ),
                            const SizedBox(height: 9),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '₦$amount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -.8,
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: const Color(0xFF34D399).withOpacity(.10),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: const Color(0xFF34D399).withOpacity(.22)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified_rounded, color: Color(0xFF6EE7B7), size: 15),
                                  SizedBox(width: 6),
                                  Text(
                                    'TRANSFER CONFIRMED',
                                    style: TextStyle(
                                      color: Color(0xFF6EE7B7),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 23),
                            _detailRow('Recipient', name),
                            const Divider(color: Colors.white12, height: 23),
                            _detailRow('Bank', bank),
                            const Divider(color: Colors.white12, height: 23),
                            _detailRow('Account number', account),
                            if (hasReference) ...[
                              const Divider(color: Colors.white12, height: 23),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Expanded(
                                    child: Text('Reference', style: TextStyle(color: _muted, fontSize: 12)),
                                  ),
                                  const SizedBox(width: 14),
                                  Flexible(
                                    flex: 3,
                                    child: SelectableText(
                                      reference!,
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    constraints: const BoxConstraints.tightFor(width: 30, height: 30),
                                    padding: EdgeInsets.zero,
                                    tooltip: 'Copy reference',
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: reference!));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Transfer reference copied.')),
                                      );
                                    },
                                    icon: const Icon(Icons.copy_rounded, color: _accent, size: 16),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 17),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.035),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withOpacity(.07)),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.shield_outlined, color: _accent, size: 19),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Keep your transfer receipt for your records. Multifactor authentication is required for transactions above ₦200,000.',
                                style: TextStyle(color: Color(0xFFB7C4D5), fontSize: 11, height: 1.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      if (hasReference)
                        SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => FlutterwaveTransferReceiptScreen(reference: reference!),
                                ),
                              );
                            },
                            icon: const Icon(Icons.receipt_long_rounded),
                            label: const Text('View transfer receipt'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _accent,
                              foregroundColor: const Color(0xFF08131D),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                            ),
                          ),
                        ),
                      if (hasReference) const SizedBox(height: 10),
                      SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(color: Colors.white.withOpacity(.20)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: _muted, fontSize: 12)),
        ),
        const SizedBox(width: 14),
        Flexible(
          flex: 3,
          child: Text(
            value.trim().isEmpty ? '—' : value,
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
