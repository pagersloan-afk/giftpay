import 'package:flutter/material.dart';
import 'package:utilityhub/features/auth/login/signup/screens/signup_pin_screen.dart';
import 'package:utilityhub/features/wallet/services/virtual_account_service.dart';

class SignupBankAccountScreen extends StatefulWidget {
  final String initialBvn;
  final bool returnToWallet;
  final bool returnToHome;
  const SignupBankAccountScreen({
    super.key,
    this.initialBvn = '',
    this.returnToWallet = false,
    this.returnToHome = false,
  });

  @override
  State<SignupBankAccountScreen> createState() =>
      _SignupBankAccountScreenState();
}

class _SignupBankAccountScreenState extends State<SignupBankAccountScreen> {
  final _service = VirtualAccountService();
  final _bvnController = TextEditingController();
  final _accountController = TextEditingController();
  List<Map<String, String>> _banks = [];
  String? _bankCode;
  bool _loadingBanks = true;
  bool _submitting = false;
  bool _consent = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _bvnController.text = widget.initialBvn;
    _loadBanks();
  }

  @override
  void dispose() {
    _bvnController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  Future<void> _loadBanks() async {
    try {
      final banks = await _service.getNigerianBanks();
      if (!mounted) return;
      setState(() {
        _banks = banks;
        _loadingBanks = false;
        if (banks.isNotEmpty) _bankCode = banks.first['code'];
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingBanks = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _continue() async {
    if (_bvnController.text.trim().length != 11) {
      setState(
        () => _error =
            'Enter your 11-digit BVN. Gift Technology Ltd requires BVN for bank-account validation.',
      );
      return;
    }
    if (_accountController.text.trim().length != 10) {
      setState(() => _error = 'Enter your 10-digit bank account number.');
      return;
    }
    if (_bankCode == null) {
      setState(() => _error = 'Select your bank.');
      return;
    }
    if (!_consent) {
      setState(
        () => _error =
            'Please provide consent to verify your bank details with Gift Technology Ltd.',
      );
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final result = await _service.preparePaystackAccount(
        bvn: _bvnController.text.trim(),
        accountNumber: _accountController.text.trim(),
        bankCode: _bankCode!,
        consent: _consent,
      );
      if (!mounted) return;
      final verifiedName = result['verifiedAccountName'];
      if (verifiedName != null && verifiedName.toString().isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bank account verified: $verifiedName')),
        );
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SignupPinScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Bank Account')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Icon(Icons.account_balance, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Confirm your bank details',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'To complete your account setup, please provide the details of your personal bank account. We’ll use these details to verify your identity and help protect your GiftPay account.',
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _bvnController,
                keyboardType: TextInputType.number,
                maxLength: 11,
                decoration: const InputDecoration(
                  labelText: 'BVN (11 digits)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              if (_loadingBanks)
                const LinearProgressIndicator()
              else
                DropdownButtonFormField<String>(
                  value: _bankCode,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Select your bank',
                    border: OutlineInputBorder(),
                  ),
                  items: _banks
                      .map(
                        (bank) => DropdownMenuItem<String>(
                          value: bank['code'],
                          child: Text(bank['name'] ?? ''),
                        ),
                      )
                      .toList(),
                  onChanged: _submitting
                      ? null
                      : (value) => setState(() => _bankCode = value),
                ),
              const SizedBox(height: 12),
              TextField(
                controller: _accountController,
                keyboardType: TextInputType.number,
                maxLength: 10,
                decoration: const InputDecoration(
                  labelText: 'Personal bank account number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _consent,
                onChanged: _submitting
                    ? null
                    : (value) => setState(() => _consent = value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text(
                  'I authorize Gift Technology Ltd to securely share my BVN and bank account details with its verification partners for identity and account verification.',
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 16),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _submitting || _loadingBanks ? null : _continue,
                  child: _submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Verify Bank & Continue'),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your BVN and bank account details are used only for verification. We do not store your full bank account number or BVN in your GiftPay profile.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
