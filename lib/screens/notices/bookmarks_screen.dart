import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notice_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../home/feed_card.dart';

class BookmarkedNoticesScreen extends StatelessWidget {
  const BookmarkedNoticesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final noticeProv = context.watch<NoticeProvider>();
    final authProv = context.watch<AuthProvider>();
    final userId = authProv.user?.uid;

    final bookmarkedNotices = noticeProv.notices.where((n) => userId != null && n.bookmarks.contains(userId)).toList();

    final bgColor = isDark ? const Color(0xFF0B1623) : Colors.grey[50];
    final titleColor = isDark ? Colors.white : const Color(0xFF0F2643);
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("My Bookmarks", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0F2643),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined, color: Colors.white),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: bookmarkedNotices.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 80, color: subTextColor!.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(
                    "No bookmarked notices yet",
                    style: TextStyle(color: subTextColor, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Notices you bookmark will appear here.",
                    style: TextStyle(color: subTextColor.withOpacity(0.7), fontSize: 13),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookmarkedNotices.length,
              itemBuilder: (context, index) {
                return FeedCard(notice: bookmarkedNotices[index]);
              },
            ),
    );
  }
}
