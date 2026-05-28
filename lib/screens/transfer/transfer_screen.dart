import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_input.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _recipientController = TextEditingController();
  final _accountController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _recipientController.dispose();
    _accountController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submitTransfer() {
    if (_recipientController.text.trim().isEmpty ||
        _accountController.text.trim().isEmpty ||
        _amountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lengkapi data transfer terlebih dahulu.'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transfer demo berhasil dibuat.')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              child: const Text(
                'Gunakan simulasi ini untuk memastikan alur transfer dan validasi form berjalan normal.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 24),
            CustomInput(
              label: 'Nama Penerima',
              hint: 'Contoh: Budi Santoso',
              controller: _recipientController,
            ),
            const SizedBox(height: 18),
            CustomInput(
              label: 'Nomor Rekening',
              hint: 'Masukkan nomor rekening',
              controller: _accountController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 18),
            CustomInput(
              label: 'Nominal',
              hint: 'Masukkan nominal transfer',
              controller: _amountController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            CustomButton(
              label: 'Kirim Transfer',
              onPressed: _submitTransfer,
              icon: Icons.send_rounded,
            ),
          ],
        ),
      ),
    );
  }
}
