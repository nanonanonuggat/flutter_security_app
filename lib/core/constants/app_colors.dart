import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Brand
  static const Color primaryDark = Color(0xFF0D2453);
  static const Color primaryNavy = Color(0xFF1A3A6B);
  static const Color primaryMid = Color(0xFF1E4080);
  static const Color accentBlue = Color(0xFF2563EB);
  static const Color accentLight = Color(0xFF3B82F6);

  // Backgrounds
  static const Color scaffoldBg = Color(0xFFF4F6FA);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFF8FAFF);
  static const Color inputFill = Color(0xFFF0F4FF);
  static const Color divider = Color(0xFFE8EDF5);

  // Text
  static const Color textPrimary = Color(0xFF0D2453);
  static const Color textSecondary = Color(0xFF6B7A99);
  static const Color textHint = Color(0xFFADB5C7);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textWhite70 = Color(0xB3FFFFFF);

  // Status
  static const Color success = Color(0xFF2ECC71);
  static const Color successLight = Color(0xFFD4F5E3);
  static const Color warning = Color(0xFFE74C3C);
  static const Color warningLight = Color(0xFFFDE8E8);
  static const Color pending = Color(0xFFF39C12);
  static const Color pendingLight = Color(0xFFFEF3CD);

  // Gradients
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D2453), Color(0xFF1A3A6B)],
  );

  static const LinearGradient balanceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A3A6B), Color(0xFF2563EB)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D2453), Color(0xFF2563EB)],
  );

  // Border
  static const Color borderLight = Color(0xFFDDE3EF);
  static const Color borderFocus = Color(0xFF2563EB);
}
