import 'package:flutter/material.dart';

class AppTheme {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color greyText;
  final Color textFieldBg;
  final Color iconColor;
  final Color borderColor;
  final Color text;
  final Color error;
  final Color pending;
  final Color shimmerBase;
  final Color shimmerHighLight;
  final Color heartColor;

  const AppTheme({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.borderColor,
    required this.greyText,
    required this.textFieldBg,
    required this.iconColor,
    required this.text,
    required this.error,
    required this.pending,
    required this.shimmerBase,
    required this.shimmerHighLight,
    required this.heartColor,
  });
}

// Light Theme
const lightTheme = AppTheme(
  primary: Color(0xFF0066FF),
  secondary: Color(0xFF19b65b),
  borderColor: Color(0xFFEBEBEB),
  background: Colors.white,
  greyText: Colors.grey,
  text: Colors.black,
  iconColor: Colors.black26,
  textFieldBg: Colors.black12,
  error: Colors.red,
  pending: Colors.orange,
  shimmerBase: Color(0xFFdbdbdb),
  shimmerHighLight: Color(0xFFc4c4c4),
  heartColor: Colors.black,
);

// Dark Theme
const darkTheme = AppTheme(
  primary: Color(0xFF448AFF),
  secondary: Color(0xFF00E676),
  borderColor: Color(0xFFEBEBEB),
  background: Colors.black,
  greyText: Colors.grey,
  iconColor: Colors.white,
  text: Colors.white,
  textFieldBg: Colors.grey,
  error: Colors.redAccent,
  pending: Colors.orangeAccent,
  shimmerBase: Color(0xFF1C1C1E),
  shimmerHighLight: Colors.grey,
  heartColor: Colors.white,
);

/// 🔹 Convert AppTheme to ThemeData
ThemeData toThemeData(AppTheme theme) {
  return ThemeData(
    primaryColor: theme.primary,
    scaffoldBackgroundColor: theme.background,
    appBarTheme: AppBarTheme(
      backgroundColor: theme.primary,
      foregroundColor: theme.text,
    ),
    textTheme: TextTheme(bodyMedium: TextStyle(color: theme.text)),
    iconTheme: IconThemeData(color: theme.iconColor),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: theme.textFieldBg,
      filled: true,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: theme.borderColor),
      ),
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: theme.secondary,
      error: theme.error,
    ),
  );
}
