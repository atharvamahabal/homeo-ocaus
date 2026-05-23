import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Universal light green theme for consistency across modes
  static const Color primaryGreen = Color(0xFF1B5E20); // Darker green for text/icons
  static const Color backgroundGreen = Color(0xFFF1F8E9); // Very light green background
  static const Color surfaceGreen = Color(0xFFDCEDC8); // Slightly darker green for cards

  static ThemeData light = _buildTheme(Brightness.light);
  static ThemeData dark = _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    return FlexThemeData.light(
      colors: const FlexSchemeColor(
        primary: primaryGreen,
        primaryContainer: Color(0xFFA5D6A7),
        secondary: Color(0xFF004D40),
        secondaryContainer: Color(0xFFB2DFDB),
        tertiary: Color(0xFF558B2F),
        tertiaryContainer: Color(0xFFDCEDC8),
        appBarColor: Color(0xFFB2DFDB),
        error: Color(0xFFB00020),
      ),
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 7,
      scaffoldBackground: backgroundGreen,
      surface: surfaceGreen,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 10,
        blendOnColors: false,
        useMaterial3Typography: true,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
        inputDecoratorRadius: 12.0,
        inputDecoratorUnfocusedHasBorder: false,
        inputDecoratorFocusedHasBorder: true,
        inputDecoratorSchemeColor: SchemeColor.primary,
        fabRadius: 16.0,
        chipRadius: 10.0,
        cardRadius: 16.0,
        popupMenuRadius: 12.0,
        dialogRadius: 20.0,
        timePickerElementRadius: 12.0,
        snackBarRadius: 12.0,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    ).copyWith(
      scaffoldBackgroundColor: backgroundGreen,
      cardColor: surfaceGreen,
      datePickerTheme: DatePickerThemeData(
        backgroundColor: backgroundGreen,
        headerBackgroundColor: primaryGreen,
        headerForegroundColor: Colors.white,
        dayStyle: const TextStyle(fontWeight: FontWeight.bold),
        surfaceTintColor: Colors.transparent,
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: backgroundGreen,
        hourMinuteColor: surfaceGreen,
        hourMinuteTextColor: primaryGreen,
        dayPeriodColor: surfaceGreen,
        dayPeriodTextColor: primaryGreen,
        dialBackgroundColor: surfaceGreen,
        dialHandColor: primaryGreen,
        dialTextColor: primaryGreen,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundGreen,
        foregroundColor: primaryGreen,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryGreen),
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black87),
          titleLarge: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(color: primaryGreen),
          headlineSmall: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
