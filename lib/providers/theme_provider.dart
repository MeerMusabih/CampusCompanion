import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  ThemeData get currentTheme {
    final pageTransitionsTheme = PageTransitionsTheme(
      builders: {
        TargetPlatform.android: const SharedAxisPageTransitionsBuilder(
          transitionType: SharedAxisTransitionType.horizontal,
        ),
        TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: const SharedAxisPageTransitionsBuilder(
          transitionType: SharedAxisTransitionType.horizontal,
        ),
      },
    );

    if (_isDarkMode) {
      return ThemeData.dark().copyWith(
        primaryColor: const Color(0xFFE3A42B),
        scaffoldBackgroundColor: const Color(0xFF0B1623),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F2643),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE3A42B),
          secondary: Color(0xFF0F2643),
          surface: Color(0xFF1F2937),
        ),
        pageTransitionsTheme: pageTransitionsTheme,
      );
    } else {
      return ThemeData.light().copyWith(
        primaryColor: const Color(0xFF0E3A5D),
        scaffoldBackgroundColor: const Color(0xFFF7F9FC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0E3A5D),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF0E3A5D),
          secondary: Color(0xFFE3A42B),
          surface: Colors.white,
        ),
        pageTransitionsTheme: pageTransitionsTheme,
      );
    }
  }
}
