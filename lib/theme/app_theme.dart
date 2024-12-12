import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    primaryColor: Colors.black,
    colorScheme: const ColorScheme.light(
      primary: Colors.black,
      secondary: Colors.grey,
      surface: Colors.white,
      error: Colors.red,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(color: Colors.black),
      bodyLarge: TextStyle(color: Colors.black87),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF2C3E50),
    primaryColor: const Color(0xFF34495E),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF34495E),
      secondary: Color(0xFF2C3E50),
      surface: Color(0xFF34495E),
      error: Colors.red,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(color: Colors.white),
      bodyLarge: TextStyle(color: Colors.white70),
    ),
  );
}
