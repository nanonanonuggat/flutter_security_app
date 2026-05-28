import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/sensitive_data_service.dart';
import '../../core/services/transaction_service.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/input_validator.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_input.dart';
import '../../core/widgets/session_guard.dart';
import '../login/login_screen.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _recipientController = TextEditingController();
  final _accountController = TextEditingController();
  final _amountController = TextEditingController();

  bool _isSubmitting = false;
  double _availableBalance = 0;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _accountController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadBalance() async {
    final profile = await SensitiveDataService.instance.loadProfile();
    if (!mounted) {
      return;
    }
    setState(() {
      _availableBalance = profile.balance;
    });
  }

  Future<void> _logout() async {
    await AuthService.instance.clearSession();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _submitTransfer() async {
    final recipientValidation = InputValidator.validateRecipient(
      _recipientController.text,
    );
    if (!recipientValidation.isValid) {
      _showMessage(recipientValidation.message!);
      return;
    }

    final accountValidation = InputValidator.validateAccountNumber(
      _accountController.text,
    );
    if (!accountValidation.isValid) {
      _showMessage(accountValidation.message!);
      return;
    }

    final amountValidation = InputValidator.validateAmount(
      _amountController.text,
    );
    if (!amountValidation.isValid) {
      _showMessage(amountValidation.message!);
      return;
    }

    final amount = double.parse(
      _amountController.text.replaceAll(RegExp(r'[^0-9]'), ''),
    );

    setState(() => _isSubmitting = true);

    try {
      await TransactionService.instance.saveTransfer(
        recipientName: _recipientController.text,
        recipientAccount: _accountController.text,
        amount: amount,
      );
      if (!mounted) {
        return;
      }
      _showMessage('Transfer terenkripsi berhasil disimpan.');
      Navigator.of(context).pop(true);
    } on ArgumentError catch (error) {
      _showMessage(error.message.toString());
    } on StateError catch (error) {
      _showMessage(error.message);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return SessionGuard(
      onSessionExpired: _logout,
      child: Scaffold(
        appBar: AppBar(title: const Text('Transfer Aman')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saldo tersedia: ${CurrencyFormatter.format(_availableBalance)}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CustomInput(
                label: 'Nama Penerima',
                hint: 'Contoh: Budi Santoso',
                controller: _recipientController,
                maxLength: 60,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r"[A-Za-z0-9 .,'-]"),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              CustomInput(
                label: 'Nomor Rekening',
                hint: 'Masukkan nomor rekening',
                controller: _accountController,
                keyboardType: TextInputType.number,
                maxLength: 20,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 18),
              CustomInput(
                label: 'Nominal',
                hint: 'Masukkan nominal transfer',
                controller: _amountController,
                keyboardType: TextInputType.number,
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 24),
              CustomButton(
                label: _isSubmitting
                    ? 'Menyimpan transaksi...'
                    : 'Kirim Transfer',
                onPressed: _isSubmitting ? null : _submitTransfer,
                icon: Icons.send_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
