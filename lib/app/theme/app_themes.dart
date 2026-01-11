import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bontrack/core/constants/color_constants.dart';

class AppThemes {
  // --- TEMA TERANG ---
  static ThemeData get light {
    final baseTheme = ThemeData.light(useMaterial3: true);
    return baseTheme.copyWith(
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightOnSurface,
        secondary: AppColors.lightTextField,
        onSecondary: AppColors.lightOnSurface,
        onSurfaceVariant: AppColors.lightSecondaryText,
        error: Colors.redAccent,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(baseTheme.textTheme).apply(
        bodyColor: AppColors.lightOnSurface,
        displayColor: AppColors.lightOnSurface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightOnSurface,
        surfaceTintColor: AppColors.lightBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.lightOnSurface),
      ),
      cardTheme: CardThemeData(
        elevation: 0.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        color: AppColors.lightSurface,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightBackground,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.lightOnSurface,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.lightSecondaryText,
        contentTextStyle: TextStyle(color: AppColors.lightOnSurface),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        ),
      ),
    );
  }

  // --- TEMA GELAP ---
  static ThemeData get dark {
    final baseTheme = ThemeData.dark(useMaterial3: true);
    return baseTheme.copyWith(
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkOnSurface,
        secondary: AppColors.darkTextField,
        onSecondary: AppColors.darkOnSurface,
        onSurfaceVariant: AppColors.darkSecondaryText,
        error: Colors.redAccent,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(baseTheme.textTheme).apply(
        bodyColor: AppColors.darkOnSurface,
        displayColor: AppColors.darkOnSurface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkOnSurface,
        surfaceTintColor: AppColors.darkBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.darkOnSurface),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        color: AppColors.darkSurface,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkBackground,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.darkOnSurface,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.darkSecondaryText,
        contentTextStyle: TextStyle(color: AppColors.darkOnSurface),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
      ),
    );
  }
}