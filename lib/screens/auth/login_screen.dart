import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../providers/theme_provider.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); 
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  void _handleLogin() async {
    print('🔘 Login button pressed');
    if (_formKey.currentState!.validate()) {
      print('✅ Form validation passed');
      final authProvider = context.read<AuthProvider>();
      final userProvider = context.read<UserProvider>();
      
      print('📧 Attempting login with email: ${_emailController.text.trim()}');
      final error = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (error != null && mounted) {
        print('❌ Login error: $error');
        AppUtils.showSnackBar(context, error);
      } else if (mounted) {
        print('✅ Login successful, fetching user details...');
        await userProvider.fetchUserDetails(authProvider.user!.uid);
        
        if (mounted) {
          print('🏠 Navigating to home screen');
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } else {
      print('❌ Form validation failed');
    }
  }
  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    
    final bgColor = isDark ? const Color(0xFF0B1623) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F2643);
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey;
    final inputBg = isDark ? const Color(0xFF1F2937) : Colors.white;
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round, color: isDark ? Colors.white : Colors.black),
            onPressed: () => themeProvider.toggleTheme(),
          )
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F2643), 
                        borderRadius: BorderRadius.circular(4), 
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        'assets/logo_riphah.png', 
                        fit: BoxFit.contain,
                        errorBuilder: (c, o, s) => const Icon(Icons.school, color: Colors.white, size: 50),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      "Welcome",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      "Login to your campus account",
                      style: TextStyle(color: subTextColor, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    "Email",
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _emailController,
                    hintText: "Enter your email",
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                   Text(
                    "Password",
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: _passwordController,
                    hintText: "Enter your password",
                    isPassword: true,
                  ),
                  const SizedBox(height: 30),
                  CustomButton(
                    text: "Login",
                    onPressed: _handleLogin,
                    isLoading: isLoading,
                    color: Colors.orange, 
                    textColor: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                         Navigator.pushNamed(context, '/forgot-password');
                      },
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 80), 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Text(
                        "Don't have an account? ",
                        style: TextStyle(color: subTextColor),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: const Text(
                          "Contact Department",
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
