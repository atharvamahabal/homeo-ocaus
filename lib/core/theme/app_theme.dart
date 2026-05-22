import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Green and white color theme representing natural healing
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color secondaryGreen = Color(0xFFE8F5E9);

  static ThemeData light = FlexThemeData.light(
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
    scaffoldBackground: Colors.black,
    surface: Colors.black,
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
    scaffoldBackgroundColor: Colors.black,
    cardColor: Colors.grey[900],
    textTheme: GoogleFonts.plusJakartaSansTextTheme(
      const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
        titleLarge: TextStyle(color: Colors.white),
        titleMedium: TextStyle(color: Colors.white),
      ),
    ),
  );

  static ThemeData dark = FlexThemeData.dark(
    colors: const FlexSchemeColor(
      primary: Color(0xFF81C784),
      primaryContainer: Color(0xFF1B5E20),
      secondary: Color(0xFF4DB6AC),
      secondaryContainer: Color(0xFF004D40),
      tertiary: Color(0xFFAED581),
      tertiaryContainer: Color(0xFF33691E),
      appBarColor: Color(0xFF004D40),
      error: Color(0xFFCF6679),
    ),
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 13,
    scaffoldBackground: Colors.black,
    surface: Colors.black,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 20,
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
    scaffoldBackgroundColor: Colors.black,
    cardColor: Colors.grey[900],
    textTheme: GoogleFonts.plusJakartaSansTextTheme(
      const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
        titleLarge: TextStyle(color: Colors.white),
        titleMedium: TextStyle(color: Colors.white),
      ),
    ),
  );
}
