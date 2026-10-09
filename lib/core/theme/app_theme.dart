import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: const ColorScheme.light(
        primary: AppColors.leadsLime,
        onPrimary: AppColors.leadsCharcoal,
        surface: Colors.white,
        onSurface: Color(0xFF2C302E),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.cyberBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.cyberCyan,
        onPrimary: Colors.black,
        primaryContainer: AppColors.cyberCyanDark,
        onPrimaryContainer: AppColors.cyberCyan,
        secondary: AppColors.cyberPurple,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.cyberPurpleDark,
        onSecondaryContainer: AppColors.cyberPurple,
        surface: AppColors.cyberSurface,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.cyberSurfaceVariant,
        error: AppColors.severityCritical,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cyberBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cyberSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.borderCyber, width: 1),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cyberSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderCyber, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderCyber,
        thickness: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.cyberSurface,
        indicatorColor: AppColors.cyberCyanDark.withAlpha(160),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.cyberCyan, size: 24);
          }
          return const IconThemeData(color: AppColors.textMuted, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.labelSmall.copyWith(
              color: AppColors.cyberCyan,
              fontWeight: FontWeight.bold,
            );
          }
          return AppTypography.labelSmall.copyWith(
            color: AppColors.textMuted,
            fontWeight: FontWeight.normal,
          );
        }),
      ),
    );
  }
}
