import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';

class BillsScreen extends StatelessWidget {
  const BillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bills = [
      {
        'title': 'PLN Pascabayar',
        'id': 'ID: 543210987654',
        'amount': 350000.0,
        'dueDate': '20 Mei 2026',
        'status': 'Belum Dibayar',
      },
      {
        'title': 'IndiHome Internet',
        'id': 'ID: 122333444555',
        'amount': 455000.0,
        'dueDate': '25 Mei 2026',
        'status': 'Belum Dibayar',
      },
      {
        'title': 'BPJS Kesehatan',
        'id': 'VA: 88888123456789',
        'amount': 150000.0,
        'dueDate': '10 Mei 2026',
        'status': 'Lunas',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        title: const Text(
          'Tagihan Berjalan',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: bills.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final bill = bills[index];
          final isPaid = bill['status'] == 'Lunas';

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      bill['title'] as String,
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPaid ? AppColors.successLight : AppColors.warningLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        bill['status'] as String,
                        style: TextStyle(
                          color: isPaid ? AppColors.success : AppColors.warning,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  bill['id'] as String,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: AppColors.divider),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Tagihan',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.format(bill['amount'] as double),
                          style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (!isPaid)
                      ElevatedButton(
                        onPressed: () {
                           ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Proses enkripsi ke payment gateway...')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Bayar', style: TextStyle(color: Colors.white)),
                      )
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.lock, size: 12, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Text(
                      'Jatuh Tempo: ${bill['dueDate']}',
                      style: const TextStyle(color: AppColors.textHint, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
