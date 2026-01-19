import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/user_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _regNoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  String? _selectedDept;
  String? _selectedSemester;
  
  final _formKey = GlobalKey<FormState>();

  final List<String> _departments = ['CS', 'IT', 'SE', 'EE','AI','DS','CY', 'BBA', 'Psychology', 'English'];
  final List<String> _semesters = ['1st', '2nd', '3rd', '4th', '5th', '6th', '7th', '8th'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _regNoController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    print('🔘 Register button pressed');
    if (_formKey.currentState!.validate()) {
      print('✅ Form validation passed');
      if (_passwordController.text != _confirmPasswordController.text) {
        print('❌ Passwords do not match');
        AppUtils.showSnackBar(context, "Passwords do not match");
        return;
      }

      if (_selectedDept == null || _selectedSemester == null) {
        print('❌ Department or semester not selected');
        AppUtils.showSnackBar(context, "Please select department and semester");
        return;
      }

      final authProv = context.read<AuthProvider>();
      final userProv = context.read<UserProvider>();

      print('📧 Attempting registration with email: ${_emailController.text.trim()}');
      final error = await authProv.register(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        UserModel(
          uid: '', // UID will be set by the service
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          department: _selectedDept!,
          registrationNumber: _regNoController.text.trim(),
          semester: _selectedSemester!,
          profilePic: '',
          role: 'student',
          status: 'approved',
        ),
      );

      if (error == null) {
        print('✅ Registration and profile creation successful');
        
        if (mounted) {
          _showSuccessDialog();
        }
      } else {
        print('❌ Registration error: $error');
        if (mounted) AppUtils.showSnackBar(context, error);
      }
    } else {
      print('❌ Form validation failed');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Registration Submitted", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green, size: 64),
            SizedBox(height: 16),
            Text(
              "Please wait for the admin approval email. You will be able to log in once your account is approved.",
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop(); 
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: Text(
                "Go to Login",
                style: TextStyle(
                  color: context.read<ThemeProvider>().isDarkMode ? Colors.orange : const Color(0xFF0E3A5D),
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
    
    const navyColor = Color(0xFF0E3A5D);
    const goldColor = Color(0xFFE3A42B);
    final bgColor = isDark ? const Color(0xFF0B1623) : const Color(0xFFF7F9FC);
    final cardColor = isDark ? const Color(0xFF1F2937) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: navyColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Create Account",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round, color: Colors.white),
            onPressed: () => themeProvider.toggleTheme(),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildFieldLabel("Full Name", isDark),
                CustomTextField(
                  controller: _nameController,
                  hintText: "Enter your full name",
                  fillColor: cardColor,
                  focusColor: goldColor,
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 16),

                _buildFieldLabel("University Email Address", isDark),
                CustomTextField(
                  controller: _emailController,
                  hintText: "e.g. name@university.edu",
                  keyboardType: TextInputType.emailAddress,
                  fillColor: cardColor,
                  focusColor: goldColor,
                  validator: (v) => v!.isEmpty || !v.contains('@') ? "Valid email required" : null,
                ),
                const SizedBox(height: 16),

                _buildFieldLabel("Registration Number / Student ID", isDark),
                CustomTextField(
                  controller: _regNoController,
                  hintText: "Enter your ID",
                  fillColor: cardColor,
                  focusColor: goldColor,
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel("Department", isDark),
                          _buildDropdown(
                            value: _selectedDept,
                            items: _departments,
                            hint: "Select Dept",
                            onChanged: (v) => setState(() => _selectedDept = v),
                            isDark: isDark,
                            cardColor: cardColor,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel("Semester", isDark),
                          _buildDropdown(
                            value: _selectedSemester,
                            items: _semesters,
                            hint: "Select Sem",
                            onChanged: (v) => setState(() => _selectedSemester = v),
                            isDark: isDark,
                            cardColor: cardColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildFieldLabel("Password", isDark),
                CustomTextField(
                  controller: _passwordController,
                  hintText: "Enter password",
                  isPassword: true,
                  fillColor: cardColor,
                  focusColor: goldColor,
                  validator: (v) => v!.length < 6 ? "Min 6 characters" : null,
                ),
                const SizedBox(height: 16),

                _buildFieldLabel("Confirm Password", isDark),
                CustomTextField(
                  controller: _confirmPasswordController,
                  hintText: "Confirm password",
                  isPassword: true,
                  fillColor: cardColor,
                  focusColor: goldColor,
                  validator: (v) {
                    if (v != _passwordController.text) return "Passwords mismatch";
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 18, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        "Role: Student",
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                _buildApprovalNotice(isDark),
                const SizedBox(height: 32),

                CustomButton(
                  text: "Apply for Registration",
                  onPressed: _handleRegister,
                  isLoading: isLoading,
                  color: goldColor,
                  textColor: navyColor,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        label,
        style: TextStyle(
          color: isDark ? Colors.white70 : const Color(0xFF0E3A5D),
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required Function(String?) onChanged,
    required bool isDark,
    required Color cardColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
          isExpanded: true,
          dropdownColor: cardColor,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(color: isDark ? Colors.white : Colors.black87)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildApprovalNotice(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF162D3D) : const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF0E3A5D) : Colors.blue[100]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_rounded, color: isDark ? const Color(0xFFE3A42B) : Colors.blue[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Your account will be reviewed by the admin.",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.blue[900],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "You will receive an approval email before you can log in.",
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.blue[800],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
