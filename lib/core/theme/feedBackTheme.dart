import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      primarySwatch: Colors.indigo,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.grey[50],
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(fontSize: 14),
      ),
    );
  }
}
