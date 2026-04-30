import 'package:flutter/material.dart';

class BankLogo extends StatelessWidget {
  final String code;

  const BankLogo({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    final networkUrl = "https://assets.paystack.com/bank-logos/$code.png";
    final pngPath = "assets/banks/$code.png";
    final jpgPath = "assets/banks/$code.jpg";

    return SizedBox(
      width: 40,
      height: 40,
      child: ClipOval(
        child: Image.network(
          networkUrl,
          fit: BoxFit.cover,
          cacheWidth: 80,
          cacheHeight: 80,
          errorBuilder: (_, _, _) {
            return Image.asset(
              pngPath,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                return Image.asset(
                  jpgPath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) {
                    return Icon(
                      Icons.account_balance,
                      size: 22,
                      color: Colors.grey.shade500,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
