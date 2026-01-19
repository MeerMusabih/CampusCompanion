import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF7F9FC);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final navyColor = const Color(0xFF0E3A5D);
    final textColor = isDark ? Colors.white : const Color(0xFF0F2643);
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final dividerColor = isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: navyColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Help & Support",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined, color: Colors.white),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Help Options Section
            // FAQs Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildFAQTile(
                    context,
                    "How do I reset my password?",
                    "Go to the login screen and tap on 'Forgot Password'. Follow the instructions sent to your email to reset it.",
                    cardColor, textColor, subTextColor!
                  ),
                  _buildFAQTile(
                    context,
                    "How do I post in Lost & Found?",
                    "Navigate to the Lost & Found section, tap the '+' button, and fill in the details about the item you found or lost.",
                    cardColor, textColor, subTextColor
                  ),
                  _buildFAQTile(
                    context,
                    "Can I edit my forum posts?",
                    "Yes, you can edit your own posts by tapping the three dots menu on your post and selecting 'Edit'.",
                    cardColor, textColor, subTextColor
                  ),
                  _buildFAQTile(
                    context,
                    "How do I register for an event?",
                    "Go to the Events tab, select the event you're interested in, and tap the 'Register' button.",
                    cardColor, textColor, subTextColor
                  ),
                  _buildFAQTile(
                    context,
                    "Who do I contact for technical issues?",
                    "You can contact our IT support team via email at it.helpdesk@university.edu or call us at +1 (234) 567-890.",
                    cardColor, textColor, subTextColor
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Contact Support Section
            _buildSectionHeader("Contact Support", subTextColor),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    _buildContactItem(Icons.email_outlined, "Email Support", "it.helpdesk@university.edu", textColor, subTextColor),
                    Divider(height: 32, color: dividerColor),
                    _buildContactItem(Icons.phone_outlined, "Phone Support", "+1 (234) 567-890", textColor, subTextColor),
                    Divider(height: 32, color: dividerColor),
                    _buildContactItem(Icons.access_time_outlined, "Office Hours", "Mon–Fri, 9 AM – 5 PM", textColor, subTextColor),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color subTextColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(color: subTextColor, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildFAQTile(BuildContext context, String question, String answer, Color cardColor, Color textColor, Color subTextColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: textColor,
          collapsedIconColor: textColor,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          title: Text(
            question,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
          ),
          children: [
            Text(
              answer,
              style: TextStyle(fontSize: 14, color: subTextColor, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String title, String value, Color textColor, Color subTextColor) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 12, color: subTextColor, fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(fontSize: 15, color: textColor, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}
