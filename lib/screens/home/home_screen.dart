import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/notice_provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/constants.dart';
import 'quick_action_button.dart';
import 'feed_card.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Exam', 'Holiday', 'Event', 'Technical', 'General', 'Placement'];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<UserProvider>().fetchUserDetails(user.uid);
      }
      context.read<NoticeProvider>().fetchNotices();
    });
  }
  void _onBottomNavTapped(int index) {
      if (index == 0) return;
      setState(() {
        _currentIndex = index;
      });
      if (index == 1) {
         Navigator.pushNamed(context, '/chat');
      } else if (index == 2) {
         Navigator.pushNamed(context, '/notifications');
      } else if (index == 3) {
         Navigator.pushNamed(context, '/profile');
      }
      setState(() {
        _currentIndex = 0; 
      });
  }
  @override
  Widget build(BuildContext context) {
    final userProv = context.watch<UserProvider>();
    final noticeProv = context.watch<NoticeProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    
    final isDark = themeProvider.isDarkMode;
    final userName = userProv.currentUser?.name ?? "Student";
    final isAdmin = userProv.currentUser?.role == 'admin';
    
    final bgColor = isDark ? const Color(0xFF0B1623) : Colors.grey[50];
    final welcomeCardColor = isDark ? const Color(0xFF152336) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F2643);
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final bottomNavBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final bottomNavUnselected = isDark ? Colors.grey[500] : Colors.grey;
    final filteredNotices = _selectedCategory == 'All' 
        ? noticeProv.notices 
        : noticeProv.notices.where((n) => n.category == _selectedCategory).toList();
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF0F2643),
        title: Row(
          children: [
            Image.asset(
              'assets/logo_riphah.png',
              height: 32,
            ),
            const SizedBox(width: 10),
            const Text(
              "Campus Companion",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        actions: [
            IconButton(
                icon: Icon(isDark ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined, color: Colors.white),
                onPressed: () => themeProvider.toggleTheme(),
            ),
            IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () => Navigator.pushNamed(context, '/notifications'),
            ),
             IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () {
                   context.read<AuthProvider>().logout();
                   Navigator.pushReplacementNamed(context, '/login');
                },
            ),
            const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: welcomeCardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? Colors.transparent : Colors.grey[200]!),  
                boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text(
                        "Welcome, ${isAdmin ? "$userName (Admin)" : userName}",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: titleColor,
                        ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                        "Stay updated with campus activity",
                        style: TextStyle(color: subTextColor, fontSize: 14),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Quick Actions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: subTextColor),
            ),
            const SizedBox(height: 16),
            SizedBox(
                height: 100,
                child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                        QuickActionButton(
                            title: "Timetable",
                            icon: Icons.calendar_today_outlined,
                            onTap: () => Navigator.pushNamed(context, '/timetable'),
                        ),
                        QuickActionButton(
                            title: "Lost & Found",
                            icon: Icons.search,
                            onTap: () => Navigator.pushNamed(context, '/lost-found'),
                        ),
                        QuickActionButton(
                            title: "Chat",
                            icon: Icons.chat_bubble_outline,
                            onTap: () => Navigator.pushNamed(context, '/chat'),
                        ),
                        QuickActionButton(
                            title: "Events",
                            icon: Icons.event,
                            onTap: () => Navigator.pushNamed(context, '/events'),
                        ),
                        QuickActionButton(
                            title: "Forums",
                            icon: Icons.people_outline,
                            onTap: () {
                                Navigator.pushNamed(context, '/forums'); 
                            },
                        ),
                        if (isAdmin) 
                             QuickActionButton(
                                title: "Admin",
                                icon: Icons.admin_panel_settings_outlined,
                                color: Colors.red,
                                onTap: () => Navigator.pushNamed(context, '/admin'),
                            ),
                    ],
                ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Live Campus Feed",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: titleColor),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      },
                      selectedColor: Colors.orange,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : titleColor,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: isDark ? const Color(0xFF152336) : Colors.white,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
             if (noticeProv.isLoading)
                const Center(child: CircularProgressIndicator())
            else if (filteredNotices.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(Icons.feed_outlined, size: 48, color: subTextColor!.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text(
                          _selectedCategory == 'All' 
                              ? "No updates yet." 
                              : "No notices in this category.", 
                          style: TextStyle(color: subTextColor)
                        ),
                      ],
                    ),
                  ),
                )
            else
                ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredNotices.length,
                    itemBuilder: (context, index) {
                        return FeedCard(notice: filteredNotices[index]);
                    },
                ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: bottomNavBg,
        currentIndex: _currentIndex,
        onTap: _onBottomNavTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.orange,
        unselectedItemColor: bottomNavUnselected,
        showUnselectedLabels: true,
        items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "Chat"),
            BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), label: "Notifications"),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }
}
