import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/firestore_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  int _totalUsers = 0;
  int _pendingApprovals = 0;
  int _activeContent = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final totalUsers = await _firestoreService.getUsersCount();
      final pending = await _firestoreService.getPendingApprovalsCount();
      final activeContent = await _firestoreService.getActiveNoticesEventsCount();

      if (mounted) {
        setState(() {
          _totalUsers = totalUsers;
          _pendingApprovals = pending;
          _activeContent = activeContent;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDarkMode = themeProvider.isDarkMode;

    final bgColor = isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF7F9FC);
    final cardColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final navyColor = const Color(0xFF0E3A5D);
    final highlightColor = const Color(0xFFE3A42B);
    final textColor = isDarkMode ? Colors.white : const Color(0xFF0F2643);
    final subTextColor = (isDarkMode ? Colors.grey[400] : Colors.grey[600]) ?? Colors.grey;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: navyColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined, color: Colors.white),
            onPressed: () => themeProvider.toggleTheme(),
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(navyColor, highlightColor),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overview Section
                  _buildSectionHeader("Overview", subTextColor),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.4,
                    children: [
                      _buildStatCard("Total Users", _totalUsers.toString(), Icons.people_outline, highlightColor, cardColor, textColor),
                      _buildStatCard("Pending", _pendingApprovals.toString(), Icons.pending_actions, highlightColor, cardColor, textColor),
                      _buildStatCard("Active Content", _activeContent.toString(), Icons.campaign_outlined, highlightColor, cardColor, textColor),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Quick Actions Section
                  _buildSectionHeader("Quick Actions", subTextColor),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.1,
                    children: [
                      _buildActionCard("Approve Users", "Review registrations", Icons.how_to_reg_outlined, highlightColor, cardColor, textColor, subTextColor, () => Navigator.pushNamed(context, '/admin/users')),
                      _buildActionCard("Post Notice", "Broadcasting news", Icons.add_alert_outlined, highlightColor, cardColor, textColor, subTextColor, () => Navigator.pushNamed(context, '/admin/notices')),
                      _buildActionCard("Manage Events", "Add or remove", Icons.event_available_outlined, highlightColor, cardColor, textColor, subTextColor, () => Navigator.pushNamed(context, '/admin/events')),
                      _buildActionCard("Moderate Forum", "Reported content", Icons.forum_outlined, highlightColor, cardColor, textColor, subTextColor, () => Navigator.pushNamed(context, '/forums')),
                      _buildActionCard("Edit Timetable", "Schedule management", Icons.calendar_month_outlined, highlightColor, cardColor, textColor, subTextColor, () => Navigator.pushNamed(context, '/admin/timetable')),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Recent Activity Section
                  _buildSectionHeader("Recent Activity", subTextColor),
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _activityItem("Alex Johnson requested approval", "2 mins ago", Icons.person_add_outlined, Colors.blue),
                        _activityItem("Event 'Tech Gala 2024' posted", "1 hour ago", Icons.event_available_outlined, Colors.green),
                        _activityItem("Lost 'Black Wallet' item added", "3 hours ago", Icons.search_outlined, Colors.orange),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: TextButton(
                            onPressed: () {},
                            child: Text("View All Activity", style: TextStyle(color: highlightColor, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: cardColor,
        selectedItemColor: highlightColor,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) return; // Dashboard
          if (index == 1) { // Users
             Navigator.pushNamed(context, '/admin/users');
          } else if (index == 2) { // Notices
             Navigator.pushNamed(context, '/admin/notices');
          } else if (index == 3) { // Profile
             Navigator.pushNamed(context, '/profile');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: "Users"),
          BottomNavigationBarItem(icon: Icon(Icons.campaign_outlined), label: "Notices"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color subTextColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(color: subTextColor, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
              Text(title, style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.6))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, Color color, Color cardColor, Color textColor, Color subTextColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 22),
            ),
            const Spacer(),
            Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 11, color: subTextColor), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _activityItem(String title, String time, IconData icon, Color color) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      subtitle: Text(time, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      dense: true,
    );
  }

  Widget _buildDrawer(Color navyColor, Color highlightColor) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: navyColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(radius: 30, backgroundColor: Colors.white24, child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 30)),
                const SizedBox(height: 12),
                const Text("Admin Portal", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text("University Administrator", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
              ],
            ),
          ),
          _drawerItem(Icons.dashboard_outlined, "Dashboard", true, highlightColor, () => Navigator.pop(context)),
          _drawerItem(Icons.people_outline, "User Management", false, highlightColor, () => Navigator.pushNamed(context, '/admin/users')),
          _drawerItem(Icons.campaign_outlined, "Notices", false, highlightColor, () => Navigator.pushNamed(context, '/admin/notices')),
          _drawerItem(Icons.event_note, "Events", false, highlightColor, () => Navigator.pushNamed(context, '/admin/events')),
          _drawerItem(Icons.calendar_month, "Timetable", false, highlightColor, () => Navigator.pushNamed(context, '/admin/timetable')),
          const Divider(),
          _drawerItem(Icons.logout, "Exit Admin Mode", false, Colors.red[400]!, () {
            Navigator.pop(context); // Close drawer
            Navigator.pop(context); // Go back to previous screen (Home)
          }),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, bool selected, Color highlightColor, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: selected ? highlightColor : Colors.grey),
      title: Text(title, style: TextStyle(color: selected ? highlightColor : Colors.grey[700], fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
      selected: selected,
      onTap: onTap,
    );
  }
}
