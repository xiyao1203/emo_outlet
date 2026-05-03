import 'package:flutter/material.dart';

class AppColors {
  // 主色
  static const Color primary = Color(0xFFFF7A56);
  static const Color primaryLight = Color(0xFFFF9A76);
  static const Color primaryDark = Color(0xFFE06040);

  // 辅助色
  static const Color secondary = Color(0xFF4F8B9C);
  static const Color accent = Color(0xFF6B5CE7);

  // 背景色
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFFEF5F0);

  // 文字色
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textHint = Color(0xFF999999);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // 边框与分割线
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFEEEEEE);

  // 情绪颜色
  static const Color emotionAnger = Color(0xFFFF6B6B);
  static const Color emotionAnxiety = Color(0xFFFFB347);
  static const Color emotionPower = Color(0xFF6B5CE7);
  static const Color emotionSadness = Color(0xFF4F8B9C);
  static const Color emotionCalm = Color(0xFF51C7A8);

  // 渐变色
  static const List<Color> primaryGradient = [
    Color(0xFFFF7A56),
    Color(0xFFFF6B6B),
  ];

  static const List<Color> splashGradient = [
    Color(0xFFFF7A56),
    Color(0xFFFFB088),
  ];

  // 阴影
  static BoxShadow cardShadow = BoxShadow(
    color: Colors.black.withOpacity(0.08),
    blurRadius: 12,
    offset: const Offset(0, 4),
  );

  static BoxShadow buttonShadow = BoxShadow(
    color: Colors.black.withOpacity(0.15),
    blurRadius: 8,
    offset: const Offset(0, 4),
  );
}

class AppTextStyles {
  static const String fontFamily = 'PingFangSC';

  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle heading1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle heading3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
    height: 1.4,
  );

  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w500,
    color: AppColors.textOnPrimary,
    height: 1.4,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textOnPrimary,
    height: 1.4,
  );
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 16,
  );

  static const EdgeInsets cardPadding = EdgeInsets.all(16);

  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 14,
  );
}

class AppRadius {
  static const double xs = 6;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double full = 999;
}
