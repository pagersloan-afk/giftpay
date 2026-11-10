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
        // Do not preselect a bank: the customer must choose their own bank.
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingBanks = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  String get _selectedBankName {
    for (final bank in _banks) {
      if (bank['code'] == _bankCode) return bank['name'] ?? 'Select your bank';
    }
    return 'Select your bank';
  }

  Future<void> _selectBank() async {
    final selected = await showDialog<Map<String, String>>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.82),
      builder: (_) => _BankSearchDialog(banks: _banks),
    );
    if (selected != null && mounted) {
      setState(() {
        _bankCode = selected['code'];
        _error = null;
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
                'Paystack requires your BVN and personal bank-account details to validate your identity and assign your dedicated GiftPay account. Enter details that belong to you.',
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
                InkWell(
                  onTap: _submitting || _banks.isEmpty ? null : _selectBank,
                  borderRadius: BorderRadius.circular(14),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Select your bank',
                      suffixIcon: Icon(Icons.search_rounded),
                    ),
                    child: Text(
                      _selectedBankName,
                      style: TextStyle(
                        color: _bankCode == null ? Colors.white54 : Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
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
                'Your BVN is submitted securely to Paystack for dedicated-account verification. GiftPay stores only the verification result and masked bank-account details, not your full BVN or account number.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _BankSearchDialog extends StatefulWidget {
  final List<Map<String, String>> banks;
  const _BankSearchDialog({required this.banks});

  @override
  State<_BankSearchDialog> createState() => _BankSearchDialogState();
}

class _BankSearchDialogState extends State<_BankSearchDialog> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _filtered {
    final query = _query.trim().toLowerCase();
    final result = widget.banks.where((bank) {
      final name = (bank['name'] ?? '').toLowerCase();
      return query.isEmpty || name.contains(query);
    }).toList();
    result.sort((a, b) {
      final an = (a['name'] ?? '').toLowerCase();
      final bn = (b['name'] ?? '').toLowerCase();
      if (query.isNotEmpty) {
        final aStarts = an.startsWith(query);
        final bStarts = bn.startsWith(query);
        if (aStarts != bStarts) return aStarts ? -1 : 1;
        final aWord = an.split(RegExp(r'\s+')).any((part) => part.startsWith(query));
        final bWord = bn.split(RegExp(r'\s+')).any((part) => part.startsWith(query));
        if (aWord != bWord) return aWord ? -1 : 1;
      }
      return an.compareTo(bn);
    });
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final banks = _filtered;
    return Dialog(
      backgroundColor: const Color(0xFF05070A),
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withOpacity(.14)),
      ),
      child: SizedBox(
        width: 480,
        height: MediaQuery.sizeOf(context).height * .72,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Expanded(child: Text('Choose your bank', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w700))),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white70)),
              ]),
              const SizedBox(height: 8),
              TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: 'Type bank name',
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  suffixIcon: _query.isEmpty ? null : IconButton(
                    onPressed: () { _searchController.clear(); setState(() => _query = ''); },
                    icon: const Icon(Icons.close, color: Colors.white70),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF111827),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white24)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white24)),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: banks.isEmpty
                    ? const Center(child: Text('No matching bank found', style: TextStyle(color: Colors.white70)))
                    : ListView.separated(
                        itemCount: banks.length,
                        separatorBuilder: (_, __) => Divider(height: 1, color: Colors.white.withOpacity(.08)),
                        itemBuilder: (context, index) {
                          final bank = banks[index];
                          return ListTile(
                            dense: true,
                            title: Text(bank['name'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                            trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                            onTap: () => Navigator.pop(context, bank),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
