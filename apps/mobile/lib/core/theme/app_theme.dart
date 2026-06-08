import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light {
    const seedColor = Color(0xFF2563EB);

    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF6F7F9),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Color(0xFFFFFFFF),
        foregroundColor: Color(0xFF18181B),
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFFFFFFFF),
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
    );
  }
}
