import 'package:flutter/material.dart';
import '../core/constants.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final Color? focusColor;
  final Color? fillColor;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
    this.focusColor,
    this.fillColor,
  });
  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    
    final defaultFillColor = isDark ? const Color(0xFF1E293B) : Colors.grey[100];
    final defaultHintColor = isDark ? Colors.grey[400] : Colors.grey;
    final defaultTextColor = isDark ? Colors.white : Colors.black87;
    final defaultBorderColor = isDark ? Colors.white12 : Colors.grey[300]!;

    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(color: defaultTextColor),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: defaultHintColor),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: focusColor ?? AppColors.primary)
            : null,
        filled: true,
        fillColor: fillColor ?? defaultFillColor,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.transparent : defaultBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: focusColor ?? AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
    );
  }
}
