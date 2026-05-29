import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class GovPayScreen extends StatelessWidget {
  const GovPayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = [
      {'icon': Icons.health_and_safety, 'label': 'BPJS Kesehatan'},
      {'icon': Icons.work, 'label': 'BPJS Ketenagakerjaan'},
      {'icon': Icons.electric_bolt, 'label': 'PLN Prabayar'},
      {'icon': Icons.lightbulb, 'label': 'PLN Pascabayar'},
      {'icon': Icons.water_drop, 'label': 'PDAM'},
      {'icon': Icons.wifi, 'label': 'Internet & TV'},
      {'icon': Icons.home, 'label': 'PBB'},
      {'icon': Icons.train, 'label': 'Tiket KAI'},
    ];

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        title: const Text(
          'Gov Pay',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.success),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield, color: AppColors.success),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Semua pembayaran dienkripsi dan terhubung langsung dengan gateway pemerintah.',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Layanan Publik',
              style: TextStyle(
                color: AppColors.primaryDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Layanan ${service['label']} belum tersedia di simulasi.')),
                    );
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Icon(
                          service['icon'] as IconData,
                          color: AppColors.primaryDark,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        service['label'] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
