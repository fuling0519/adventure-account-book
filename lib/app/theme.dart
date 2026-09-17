import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  const primary = Color(0xFF72A9C9);
  const background = Color(0xFFFFFBF2);
  const text = Color(0xFF5E625F);
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.fromSeed(
        seedColor: primary, surface: background, brightness: Brightness.light),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: text),
      bodyMedium: TextStyle(color: text),
      titleLarge: TextStyle(color: text, fontWeight: FontWeight.w700),
      headlineSmall: TextStyle(color: text, fontWeight: FontWeight.w700),
    ),
    cardTheme: const CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18))),
    ),
    appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        elevation: 0,
        centerTitle: false),
    navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: background, indicatorColor: Color(0xFFDCECF2)),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFFF8F4EA),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: primary, width: 2)),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFF0C86A),
        foregroundColor: text,
        elevation: 2),
  );
}
