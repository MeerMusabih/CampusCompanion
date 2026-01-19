import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/forum_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/forum_post_model.dart';
import 'package:intl/intl.dart';

class ForumsScreen extends StatefulWidget {
  const ForumsScreen({super.key});
  @override
  State<ForumsScreen> createState() => _ForumsScreenState();
}

class _ForumsScreenState extends State<ForumsScreen> {
  int _currentIndex = 2;

  void _onBottomNavTapped(int index) {
      if (index == _currentIndex) return;
      if (index == 0) {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else if (index == 1) {
          Navigator.pushReplacementNamed(context, '/chat');
      } else if (index == 3) {
          Navigator.pushReplacementNamed(context, '/profile');
      }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    
    final bgColor = isDark ? const Color(0xFF0B1623) : Colors.white;
    final bottomNavBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final bottomNavUnselected = isDark ? Colors.grey[500] : Colors.grey;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F2643),
        title: const Text("Student Forum", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
            IconButton(
                icon: const Icon(Icons.add, color: Colors.amber),
                onPressed: () => Navigator.pushNamed(context, '/forums/add'),
            ),
             IconButton(
                icon: Icon(isDark ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined, color: Colors.white),
                onPressed: () => themeProvider.toggleTheme(),
            ),
        ],
      ),
      body: Consumer<ForumProvider>(
        builder: (context, forumProv, _) {
          if (forumProv.isLoading && forumProv.posts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (forumProv.posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.forum_outlined, size: 64, color: isDark ? Colors.white24 : Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text("No discussions yet", style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/forums/add'),
                    icon: const Icon(Icons.add),
                    label: const Text("Start a Discussion"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F2643),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: forumProv.posts.length,
            itemBuilder: (context, index) {
                return _buildPostCard(forumProv.posts[index], isDark);
            },
          );
        },
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
            BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: "Forums"), 
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildPostCard(ForumPostModel post, bool isDark) {
    final cardColor = isDark ? const Color(0xFF152336) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F2643);
    final bodyColor = isDark ? Colors.grey[300] : Colors.grey[600];
    final metaColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final borderColor = isDark ? Colors.transparent : Colors.grey[200]!;

    final initials = post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : "?";
    final timeStr = DateFormat('MMM d, hh:mm A').format(post.timestamp);

    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/forums/post', arguments: post),
      child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
              boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4)),
              ],
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    children: [
                        CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 12),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Text(post.authorName, style: TextStyle(color: titleColor.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.bold)),
                                Text(timeStr, style: TextStyle(color: metaColor, fontSize: 11)),
                            ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            post.category,
                            style: const TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                ),
                const SizedBox(height: 12),
                Text(post.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: titleColor)),
                const SizedBox(height: 8),
                Text(
                    post.content, 
                    style: TextStyle(color: bodyColor, fontSize: 14, height: 1.4),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                    children: [
                        const Icon(Icons.thumb_up_alt_outlined, size: 20, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text("${post.likes}", style: TextStyle(color: metaColor, fontSize: 13)),
                        const SizedBox(width: 16),
                        Icon(Icons.chat_bubble_outline, size: 20, color: metaColor),
                        const SizedBox(width: 4),
                        Text("${post.comments}", style: TextStyle(color: metaColor, fontSize: 13)),
                    ],
                ),
            ],
        ),
      ),
    );
  }
}
