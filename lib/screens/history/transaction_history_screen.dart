import 'package:flutter/material.dart';

import '../../core/widgets/transaction_tile.dart';
import '../../models/transaction_model.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = [
      TransactionModel(
        id: '3',
        type: TransactionType.payment,
        amount: 375000,
        recipientName: 'PLN Pascabayar',
        recipientAccount: 'BILL-001',
        timestamp: DateTime.now().subtract(const Duration(hours: 8)),
        status: TransactionStatus.success,
      ),
      TransactionModel(
        id: '4',
        type: TransactionType.transfer,
        amount: 1200000,
        recipientName: 'Siti Rahma',
        recipientAccount: '99887766',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        status: TransactionStatus.pending,
      ),
      TransactionModel(
        id: '5',
        type: TransactionType.receive,
        amount: 750000,
        recipientName: 'Refund Marketplace',
        recipientAccount: 'REFUND-01',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        status: TransactionStatus.success,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Transaksi')),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          return TransactionTile(transaction: transactions[index]);
        },
      ),
    );
  }
}
