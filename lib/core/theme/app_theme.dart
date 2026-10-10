import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const serifFamily = 'Playfair';

  // Master Palette
  static const Color forestGreen = Color(0xFF0F382A);
  static const Color deepPine = Color(0xFF0B281E);
  static const Color sage = Color(0xFF4D7C5F);
  static const Color lightSage = Color(0xFFDDE6D5);
  static const Color softBg = Color(0xFFF7F8F4);
  static const Color creamCard = Color(0xFFF7F3EC);
  static const Color warmBeige = Color(0xFFF3EFE7);
  static const Color charcoal = Color(0xFF2A3F35);
  static const Color muted = Color(0xFF6E8276);
  static const Color borderLight = Color(0xFFE2E7DA);
  static const Color goldAccent = Color(0xFFD9822B);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: softBg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: forestGreen,
          brightness: Brightness.light,
          surface: softBg,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: forestGreen),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: borderLight),
          ),
        ),
      );

  static ThemeData get dark => light;

  static TextStyle serif(
    double size, {
    FontWeight weight = FontWeight.w700,
    Color color = forestGreen,
    double? letterSpacing,
  }) =>
      TextStyle(
        fontFamily: serifFamily,
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
      );
}