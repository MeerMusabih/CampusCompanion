import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Notification States
  bool _noticesEnabled = true;
  bool _eventsEnabled = true;
  bool _forumRepliesEnabled = true;
  bool _messagesEnabled = true;
  bool _lostFoundEnabled = true;

  // App Preferences
  bool _wifiOnly = false;
  String _cacheSize = "128 MB";

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authProv = context.watch<AuthProvider>();
    final isDark = themeProvider.isDarkMode;

    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF7F9FC);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final navyColor = const Color(0xFF0E3A5D);
    final highlightColor = const Color(0xFFE3A42B);
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
          "Settings",
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
            
            // Appearance Section
            _buildSectionHeader("Appearance", subTextColor!),
            _buildSettingsGroup([
              _buildThemeToggle(themeProvider, isDark, cardColor, textColor, subTextColor),
            ], cardColor, dividerColor!),

            // Notifications Section
            _buildSectionHeader("Notifications", subTextColor),
            _buildSettingsGroup([
              _buildSwitchTile("Notices & Announcements", _noticesEnabled, (val) => setState(() => _noticesEnabled = val), highlightColor, textColor),
              _buildSwitchTile("Events", _eventsEnabled, (val) => setState(() => _eventsEnabled = val), highlightColor, textColor),
              _buildSwitchTile("Forum Replies", _forumRepliesEnabled, (val) => setState(() => _forumRepliesEnabled = val), highlightColor, textColor),
              _buildSwitchTile("Private Messages", _messagesEnabled, (val) => setState(() => _messagesEnabled = val), highlightColor, textColor),
              _buildSwitchTile("Lost & Found Updates", _lostFoundEnabled, (val) => setState(() => _lostFoundEnabled = val), highlightColor, textColor),
            ], cardColor, dividerColor),

            // App Preferences Section
            _buildSectionHeader("App Preferences", subTextColor),
            _buildSettingsGroup([
              _buildSwitchTile("Data usage (Wi-Fi only)", _wifiOnly, (val) => setState(() => _wifiOnly = val), highlightColor, textColor),
              _buildLinkTile("Clear cached data", Icons.delete_sweep_outlined, textColor, () {
                setState(() {
                  _cacheSize = "0 B";
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Cache cleared successfully")),
                );
              }, trailingText: _cacheSize),
            ], cardColor, dividerColor),

            const SizedBox(height: 32),
            
            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: OutlinedButton(
                onPressed: () => _showLogoutDialog(context, authProv),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red[400],
                  side: BorderSide(color: Colors.red[200]!),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("Log Out", style: TextStyle(fontWeight: FontWeight.bold)),
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
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(color: subTextColor, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children, Color cardColor, Color dividerColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: List.generate(children.length, (index) {
          if (index == children.length - 1) return children[index];
          return Column(
            children: [
              children[index],
              Divider(height: 1, color: dividerColor, indent: 16, endIndent: 16),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildThemeToggle(ThemeProvider tp, bool isDark, Color cardColor, Color textColor, Color subTextColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Theme Mode", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor)),
              const SizedBox(height: 2),
              Text(isDark ? "Dark Mode Active" : "Light Mode Active", style: TextStyle(fontSize: 12, color: subTextColor)),
            ],
          ),
          Switch(
            value: isDark,
            onChanged: (val) => tp.toggleTheme(),
            activeColor: const Color(0xFFE3A42B),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged, Color activeColor, Color textColor) {
    return ListTile(
      title: Text(title, style: TextStyle(fontSize: 15, color: textColor, fontWeight: FontWeight.w500)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: activeColor,
      ),
    );
  }

  Widget _buildLinkTile(String title, IconData icon, Color textColor, VoidCallback? onTap, {String? trailingText}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, size: 20, color: textColor.withOpacity(0.7)),
      title: Text(title, style: TextStyle(fontSize: 15, color: textColor, fontWeight: FontWeight.w500)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(trailingText, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
          if (onTap != null)
            const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProv) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to log out of your account?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Close dialog
              await authProv.logout();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
            child: const Text("Log Out", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
