import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'radius_tokens.dart';

/// App-wide [ThemeData] aligned with Liquid Glass (no purple seed).
abstract final class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'PingFang SC',
      scaffoldBackgroundColor: AppColors.neutral,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSurface,
        tertiary: AppColors.tertiary,
        surface: AppColors.neutral,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.divider,
        error: Color(0xFFC45C4A),
        onError: AppColors.onPrimary,
      ),
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.onSurface,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'PingFang SC',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
          height: 1.25,
        ),
      ),
      textTheme: _textTheme,
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size.fromHeight(48),
          shape: const RoundedRectangleBorder(
            borderRadius: RadiusTokens.borderMd,
          ),
          textStyle: const TextStyle(
            fontFamily: 'PingFang SC',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static const TextTheme _textTheme = TextTheme(
    displaySmall: TextStyle(
      fontFamily: 'PingFang SC',
      fontSize: 30,
      fontWeight: FontWeight.w600,
      height: 1.25,
      color: AppColors.onSurface,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'PingFang SC',
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.25,
      color: AppColors.onSurface,
    ),
    titleMedium: TextStyle(
      fontFamily: 'PingFang SC',
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.25,
      color: AppColors.onSurface,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'PingFang SC',
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.45,
      color: AppColors.onSurface,
    ),
    bodySmall: TextStyle(
      fontFamily: 'PingFang SC',
      fontSize: 15,
      fontWeight: FontWeight.w400,
      height: 1.45,
      color: AppColors.onSurface,
    ),
    labelMedium: TextStyle(
      fontFamily: 'PingFang SC',
      fontSize: 13,
      fontWeight: FontWeight.w500,
      height: 1.3,
      color: AppColors.onSurface,
    ),
    labelSmall: TextStyle(
      fontFamily: 'PingFang SC',
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.35,
      color: AppColors.onSurfaceVariant,
    ),
  );
}
