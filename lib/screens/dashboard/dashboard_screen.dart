import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/balance_card.dart';
import '../../core/widgets/section_title.dart';
import '../../core/widgets/transaction_tile.dart';
import '../../models/transaction_model.dart';
import '../transfer/transfer_screen.dart';
import '../history/transaction_history_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy Data
    final recentTransactions = [
      TransactionModel(
        id: '1',
        type: TransactionType.transfer,
        amount: 2500000,
        recipientName: 'Budi Santoso',
        recipientAccount: '12345678',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        status: TransactionStatus.success,
      ),
      TransactionModel(
        id: '2',
        type: TransactionType.receive,
        amount: 5000000,
        recipientName: 'Kementerian Keuangan',
        recipientAccount: 'GOV001',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        status: TransactionStatus.success,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: CircleAvatar(
            backgroundColor: AppColors.primaryDark,
            child: const Icon(Icons.person, color: Colors.white),
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good Morning,',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            Text(
              'National Citizen',
              style: TextStyle(
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
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BalanceCard(balance: 12450000),
            const SizedBox(height: 24),

            // Quick Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionItem(context, Icons.send, 'Transfer', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TransferScreen()),
                  );
                }),
                _buildActionItem(
                  context,
                  Icons.account_balance,
                  'Gov Pay',
                  () {},
                ),
                _buildActionItem(context, Icons.receipt_long, 'Bills', () {}),
                _buildActionItem(context, Icons.history, 'History', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TransactionHistoryScreen(),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 32),

            SectionTitle(
              title: 'Recent Transactions',
              onSeeAll: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TransactionHistoryScreen(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...recentTransactions.map((tx) => TransactionTile(transaction: tx)),
          ],
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
