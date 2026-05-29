import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/sensitive_data_service.dart';
import '../../core/services/transaction_service.dart';
import '../../core/widgets/balance_card.dart';
import '../../core/widgets/section_title.dart';
import '../../core/widgets/session_guard.dart';
import '../../core/widgets/transaction_tile.dart';
import '../../models/transaction_model.dart';
import '../bills/bills_screen.dart';
import '../gov_pay/gov_pay_screen.dart';
import '../history/transaction_history_screen.dart';
import '../login/login_screen.dart';
import '../transfer/transfer_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  SensitiveProfile? _profile;
  List<TransactionModel> _transactions = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshDashboard();
  }

  Future<void> _refreshDashboard() async {
    final profile = await SensitiveDataService.instance.loadProfile();
    final items = await TransactionService.instance.loadTransactions();
    if (!mounted) {
      return;
    }

    setState(() {
      _profile = profile;
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
    final recentTransactions = _transactions.take(3).toList();

    return SessionGuard(
      onSessionExpired: _logout,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.scaffoldBg,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: CircleAvatar(
              backgroundColor: AppColors.primaryDark,
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Good Morning,',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              Text(
                _profile?.displayName ?? 'National Citizen',
                style: const TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: AppColors.primaryDark),
              onPressed: _logout,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryDark),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BalanceCard(balance: _profile?.balance ?? 0),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildActionItem(
                          context,
                          Icons.send,
                          'Transfer',
                          () async {
                            final created = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TransferScreen(),
                              ),
                            );
                            if (created == true) {
                              _refreshDashboard();
                            }
                          },
                        ),
                        _buildActionItem(
                          context,
                          Icons.account_balance,
                          'Gov Pay',
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const GovPayScreen(),
                              ),
                            );
                          },
                        ),
                        _buildActionItem(
                          context,
                          Icons.receipt_long,
                          'Bills',
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const BillsScreen(),
                              ),
                            );
                          },
                        ),
                        _buildActionItem(
                          context,
                          Icons.history,
                          'History',
                          () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const TransactionHistoryScreen(),
                              ),
                            );
                            _refreshDashboard();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SectionTitle(
                      title: 'Recent Transactions',
                      onSeeAll: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TransactionHistoryScreen(),
                          ),
                        );
                        _refreshDashboard();
                      },
                    ),
                    const SizedBox(height: 16),
                    if (recentTransactions.isEmpty)
                      const Text(
                        'Belum ada transaksi aman yang tersimpan.',
                        style: TextStyle(color: AppColors.textSecondary),
                      )
                    else
                      ...recentTransactions.map(
                        (tx) => TransactionTile(transaction: tx),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Icon(icon, color: AppColors.primaryDark, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
