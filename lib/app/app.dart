import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/intro/splash_screen.dart';
import 'routes.dart';
class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ThemeProvider>(
      builder: (context, authProvider, themeProvider, _) {
        return MaterialApp(
          title: 'Campus Companion App',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.currentTheme,
          routes: AppRoutes.routes,
          home: const SplashScreen(),
        );
      },
    );
  }
}
