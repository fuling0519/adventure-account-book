import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  const ink = Color(0xFF344641);
  const background = Color(0xFFFFFAF0);
  const primary = Color(0xFF5F9BB1);
  const green = Color(0xFF4F8772);
  const gold = Color(0xFFEFC260);

  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: green,
      surface: const Color(0xFFFFFDF8),
      brightness: Brightness.light,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: ink),
      bodyMedium: TextStyle(color: ink),
      titleLarge: TextStyle(color: ink, fontWeight: FontWeight.w800),
      headlineSmall: TextStyle(color: ink, fontWeight: FontWeight.w800),
      displaySmall: TextStyle(color: ink, fontWeight: FontWeight.w800),
    ),
    cardTheme: const CardThemeData(
      color: Color(0xFFFFFDF8),
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      foregroundColor: ink,
      elevation: 0,
      centerTitle: false,
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Color(0xFFFFFDF8),
      indicatorColor: Color(0xFFDCECF2),
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFFF8F3E8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: primary, width: 2),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: gold,
      foregroundColor: ink,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: ink,
      contentTextStyle: TextStyle(color: Color(0xFFFFFDF8)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
