import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/transaction_service.dart';
import '../../core/widgets/session_guard.dart';
import '../../core/widgets/transaction_tile.dart';
import '../../models/transaction_model.dart';
import '../login/login_screen.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  List<TransactionModel> _transactions = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final items = await TransactionService.instance.loadTransactions();
    if (!mounted) {
      return;
    }
    setState(() {
      _transactions = items;
      _isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    return SessionGuard(
      onSessionExpired: _logout,
      child: Scaffold(
        appBar: AppBar(title: const Text('Riwayat Transaksi')),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryDark),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _transactions.length,
                itemBuilder: (context, index) {
                  return TransactionTile(transaction: _transactions[index]);
                },
              ),
      ),
    );
  }
}
