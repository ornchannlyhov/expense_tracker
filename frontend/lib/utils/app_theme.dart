import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.blue[900],
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.light(
        primary: Colors.blue[900]!,
        secondary: Colors.lightBlueAccent,
      ),
      fontFamily: 'Poppins',
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(fontSize: 48.0, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 16.0),
        bodyMedium: TextStyle(fontSize: 14.0),
        bodySmall: TextStyle(fontSize: 12.0),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.blue[900],
      scaffoldBackgroundColor: Colors.grey[900],
      colorScheme: ColorScheme.dark(
        primary: Colors.blue[900]!,
        secondary: Colors.lightBlueAccent,
      ),
      fontFamily: 'Poppins',
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(fontSize: 48.0, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 16.0),
        bodyMedium: TextStyle(fontSize: 14.0),
        bodySmall: TextStyle(fontSize: 12.0),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}
