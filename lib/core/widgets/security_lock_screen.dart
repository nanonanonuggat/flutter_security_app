import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class SecurityLockScreen extends StatelessWidget {
  final Duration remainingDuration;
  final bool isDailyLock;

  const SecurityLockScreen({
    super.key,
    required this.remainingDuration,
    required this.isDailyLock,
  });

  String get _formattedDuration {
    final hours = remainingDuration.inHours;
    final minutes = remainingDuration.inMinutes.remainder(60);
    final seconds = remainingDuration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      color: AppColors.warningLight,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      size: 52,
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isDailyLock
                        ? 'Aplikasi Terkunci 24 Jam'
                        : 'Aplikasi Terkunci Sementara',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isDailyLock
                        ? 'Percobaan login melebihi batas aman. Coba lagi setelah waktu lock habis.'
                        : 'PIN salah 5x. Tunggu sebentar sebelum mencoba lagi.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Waktu tersisa',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formattedDuration,
                          style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
