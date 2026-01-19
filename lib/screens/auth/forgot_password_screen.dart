import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../core/utils.dart';
import '../../providers/theme_provider.dart'; 
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}
class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  void _handleReset() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final authProvider = context.read<AuthProvider>();
      
      
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Request Submitted", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mark_email_read_outlined, color: Colors.orange, size: 64),
            SizedBox(height: 16),
            Text(
              "Your password reset request has been submitted. An approval email will be sent to you shortly, and your password will be updated after admin review.",
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop(); 
                Navigator.of(context).pop(); 
              },
              child: const Text(
                "Back to Login",
                style: TextStyle(
                  color: Color(0xFF0E3A5D),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    
    final bgColor = isDark ? const Color(0xFF0B1623) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F2643);
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey;
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F2643), 
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Forgot Password",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
            IconButton(
                icon: Icon(isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round, color: Colors.white),
                onPressed: () => themeProvider.toggleTheme(),
            )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Text(
                  "Enter your university ID and new password.\nYour request will be processed after admin approval.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: subTextColor, fontSize: 16),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                "University Email / ID",
                style: TextStyle(
                  color: textColor, 
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _emailController,
                hintText: "Enter your email or university ID",
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                    if (value == null || value.isEmpty) {
                        return "Please enter your email";
                    }
                    return null;
                },
              ),
              const SizedBox(height: 20),
              Text(
                "New Password",
                style: TextStyle(
                  color: textColor, 
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _passwordController,
                hintText: "Enter new password",
                isPassword: true,
                validator: (value) {
                    if (value == null || value.length < 6) {
                        return "Password must be at least 6 characters";
                    }
                    return null;
                },
              ),
              const SizedBox(height: 20),
              Text(
                "Confirm New Password",
                style: TextStyle(
                  color: textColor, 
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _confirmPasswordController,
                hintText: "Confirm new password",
                isPassword: true,
                validator: (value) {
                    if (value != _passwordController.text) {
                        return "Passwords do not match";
                    }
                    return null;
                },
              ),
              const SizedBox(height: 30),
              CustomButton(
                text: "Submit Reset Request",
                onPressed: _handleReset,
                color: Colors.orange,
                isLoading: isLoading,
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  "The admin team will review your identity and approve the change.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: subTextColor, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
