import 'package:flutter/material.dart';

const Color kPrimaryGreen = Color(0xFF1B5E3B);
const Color kLightGreen = Color(0xFF4CAF50);
const Color kAccentGreen = Color(0xFF2E7D52);
const Color kBackgroundColor = Color(0xFFF8F9FA);
const Color kCardBackground = Color(0xFFFFFFFF);
const Color kBorderColor = Color(0xFFE0E0E0);
const Color kTextPrimary = Color(0xFF1A1A1A);
const Color kTextSecondary = Color(0xFF6B7280);
const Color kTextLight = Color(0xFF9CA3AF);

class AppColors {
  static const Color primary = Color(0xFF1B5E3B);
  static const Color primaryLight = Color(0xFF2E7D52);
  static const Color primaryDark = Color(0xFF0D3D22);
  static const Color accent = Color(0xFF4CAF50);
  static const Color background = Color(0xFFF8F9FA);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
}

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppBorderRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 100.0;
}
