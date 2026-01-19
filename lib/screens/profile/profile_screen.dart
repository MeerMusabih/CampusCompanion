import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/forum_provider.dart';
import '../../providers/comment_provider.dart';
import '../../providers/lost_found_provider.dart';
import '../../core/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<UserProvider>().currentUser;
      if (user != null) {
        context.read<UserProvider>().fetchUserStats(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final userProv = context.watch<UserProvider>();
    final authProv = context.read<AuthProvider>();
    final user = userProv.currentUser;
    final isDark = themeProvider.isDarkMode;

    // Colors
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF7F9FC);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final navyColor = const Color(0xFF0E3A5D);
    final highlightColor = const Color(0xFFE3A42B);
    final textColor = isDark ? Colors.white : const Color(0xFF0F2643);
    final subTextColor = (isDark ? Colors.grey[400] : Colors.grey[600]) ?? Colors.grey;
    final dividerColor = (isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200]) ?? Colors.black12;

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
          "Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined, color: Colors.white),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (user?.status == 'pending') _buildPendingBanner(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildProfileHeader(user, isDark, cardColor, navyColor, textColor, subTextColor),
                  const SizedBox(height: 24),
                  _buildStatsSection(userProv, isDark, cardColor, highlightColor, textColor),
                  const SizedBox(height: 24),
                  _buildOptionsSection("Quick Actions", [
                    _OptionItem(Icons.post_add, "My Posts", () => Navigator.pushNamed(context, '/profile/my-posts')),
                    if (user?.role == 'admin')
                      _OptionItem(Icons.admin_panel_settings_outlined, "Admin Dashboard", () => Navigator.pushNamed(context, '/admin/dashboard')),
                    _OptionItem(Icons.bookmark_border, "Bookmarked Items", () => Navigator.pushNamed(context, '/bookmarks')),
                    _OptionItem(Icons.notifications_none, "Notifications", () => Navigator.pushNamed(context, '/notifications')),
                    _OptionItem(Icons.settings_outlined, "Settings", () => Navigator.pushNamed(context, '/settings')),
                    _OptionItem(Icons.help_outline, "Help & Support", () => Navigator.pushNamed(context, '/help-support')),
                  ], cardColor, textColor, dividerColor),
                  const SizedBox(height: 24),
                  _buildOptionsSection("Account", [
                    _OptionItem(Icons.logout, "Logout", () async {
                      await authProv.logout();
                      if (context.mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                      }
                    }, isDestructive: true),
                  ], cardColor, textColor, dividerColor),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingBanner() {
    return Container(
      width: double.infinity,
      color: Colors.amber.withOpacity(0.1),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.amber, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Account pending admin approval. Please check your email.",
              style: TextStyle(color: Colors.amber[800], fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(user, bool isDark, Color cardColor, Color navyColor, Color textColor, Color subTextColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: navyColor.withOpacity(0.1),
                    child: Text(
                      user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : "?",
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: navyColor),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle, border: Border.all(color: cardColor, width: 2)),
                    child: const Icon(Icons.edit, size: 12, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.name ?? "Campus User", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: navyColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text(user?.role.toUpperCase() ?? "STUDENT", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: navyColor)),
                    ),
                    const SizedBox(height: 8),
                    Text("${user?.department ?? 'General'} • Sem ${user?.semester ?? 'N/A'}", style: TextStyle(fontSize: 13, color: subTextColor)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.email_outlined, size: 16, color: subTextColor),
              const SizedBox(width: 12),
              Text(user?.email ?? "email@university.edu", style: TextStyle(fontSize: 13, color: textColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(UserProvider userProv, bool isDark, Color cardColor, Color highlightColor, Color textColor) {
    return Row(
      children: [
        _buildStatCard("Forum Posts", "${userProv.forumPostsCount}", Icons.forum_outlined, cardColor, highlightColor, textColor),
        const SizedBox(width: 12),
        _buildStatCard("Comments", "0", Icons.chat_bubble_outline, cardColor, highlightColor, textColor),
        const SizedBox(width: 12),
        _buildStatCard("Items", "${userProv.lostFoundCount}", Icons.shopping_bag_outlined, cardColor, highlightColor, textColor),
      ],
    );
  }

  Widget _buildStatCard(String label, String count, IconData icon, Color cardColor, Color highlightColor, Color textColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: highlightColor),
            const SizedBox(height: 8),
            Text(count, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsSection(String title, List<_OptionItem> items, Color cardColor, Color textColor, Color? dividerColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
        ),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  ListTile(
                    leading: Icon(item.icon, size: 22, color: item.isDestructive ? Colors.red[300] : textColor.withOpacity(0.7)),
                    title: Text(item.label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: item.isDestructive ? Colors.red[300] : textColor)),
                    trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                    onTap: item.onTap,
                  ),
                  if (idx < items.length - 1) Divider(height: 1, color: dividerColor),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _OptionItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  _OptionItem(this.icon, this.label, this.onTap, {this.isDestructive = false});
}
