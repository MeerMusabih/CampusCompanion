import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/user_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/notice_provider.dart';
import '../../providers/forum_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/forum_post_model.dart';
import '../../models/notice_model.dart';
import '../../models/lost_found_model.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final user = context.watch<UserProvider>().currentUser;
    final isDark = themeProvider.isDarkMode;

    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF7F9FC);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final navyColor = const Color(0xFF0E3A5D);
    final highlightColor = const Color(0xFFE3A42B);
    final textColor = isDark ? Colors.white : const Color(0xFF0F2643);
    final subTextColor = (isDark ? Colors.grey[400] : Colors.grey[600]) ?? Colors.grey;

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
          "Bookmarks",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: highlightColor,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "Notices"),
            Tab(text: "Forums"),
            Tab(text: "Lost & Found"),
          ],
        ),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildNoticesList(user.uid, isDark, cardColor, textColor, subTextColor, highlightColor),
                _buildForumsList(user.uid, isDark, cardColor, textColor, subTextColor, highlightColor),
                _buildLostFoundList(user.uid, isDark, cardColor, textColor, subTextColor, highlightColor),
              ],
            ),
    );
  }

  Widget _buildNoticesList(String userId, bool isDark, Color cardColor, Color textColor, Color subTextColor, Color highlightColor) {
    final noticeProv = context.watch<NoticeProvider>();
    final bookmarks = noticeProv.notices.where((n) => n.bookmarks.contains(userId)).toList();

    if (bookmarks.isEmpty) return _buildEmptyState(isDark, textColor, "notices");

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: bookmarks.length,
      itemBuilder: (context, index) {
        return _buildBookmarkCard(bookmarks[index], "Notice", isDark, cardColor, textColor, subTextColor, highlightColor, () {
          noticeProv.toggleBookmark(bookmarks[index].id, userId);
        });
      },
    );
  }

  Widget _buildForumsList(String userId, bool isDark, Color cardColor, Color textColor, Color subTextColor, Color highlightColor) {
    return StreamBuilder<List<ForumPostModel>>(
      stream: _firestoreService.getForumPosts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        final bookmarks = snapshot.data!.where((p) => p.bookmarks.contains(userId)).toList();
        if (bookmarks.isEmpty) return _buildEmptyState(isDark, textColor, "forum posts");

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: bookmarks.length,
          itemBuilder: (context, index) {
            return _buildBookmarkCard(bookmarks[index], "Forum", isDark, cardColor, textColor, subTextColor, highlightColor, () {
              _firestoreService.toggleBookmarkForumPost(bookmarks[index].id, userId);
            });
          },
        );
      },
    );
  }

  Widget _buildLostFoundList(String userId, bool isDark, Color cardColor, Color textColor, Color subTextColor, Color highlightColor) {
    return StreamBuilder<List<String>>(
      stream: _firestoreService.getBookmarkedLostFoundIds(userId),
      builder: (context, idSnapshot) {
        if (!idSnapshot.hasData) return const Center(child: CircularProgressIndicator());
        final bookmarkedIds = idSnapshot.data!;

        return StreamBuilder<List<LostFoundModel>>(
          stream: _firestoreService.getLostFoundItems(),
          builder: (context, itemSnapshot) {
            if (!itemSnapshot.hasData) return const Center(child: CircularProgressIndicator());
            
            final bookmarks = itemSnapshot.data!.where((item) => bookmarkedIds.contains(item.id)).toList();
            if (bookmarks.isEmpty) return _buildEmptyState(isDark, textColor, "lost & found items");

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: bookmarks.length,
              itemBuilder: (context, index) {
                return _buildBookmarkCard(bookmarks[index], "Lost & Found", isDark, cardColor, textColor, subTextColor, highlightColor, () {
                  _firestoreService.toggleBookmarkLostFound(bookmarks[index].id, userId);
                });
              },
            );
          },
        );
      },
    );
  }

  Widget _buildBookmarkCard(dynamic item, String type, bool isDark, Color cardColor, Color textColor, Color subTextColor, Color highlightColor, VoidCallback onRemove) {
    String title = "";
    String description = "";
    DateTime timestamp = DateTime.now();

    if (item is NoticeModel) {
      title = item.title;
      description = item.content;
      timestamp = item.timestamp;
    } else if (item is ForumPostModel) {
      title = item.title;
      description = item.content;
      timestamp = item.timestamp;
    } else if (item is LostFoundModel) {
      title = item.title;
      description = item.description;
      timestamp = item.dateTime;
    }

    final dateStr = DateFormat('MMM d, yyyy').format(timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: InkWell(
        onTap: () {
          if (item is ForumPostModel) {
            Navigator.pushNamed(context, '/forums/post', arguments: item);
          } else if (item is NoticeModel) {
            // Navigator.pushNamed(context, '/notices/detail', arguments: item); // Assuming route exists
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: highlightColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(color: highlightColor, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.bookmark, color: Color(0xFFE3A42B), size: 20),
                    onPressed: onRemove,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 6),
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: subTextColor, height: 1.4),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time, size: 12, color: Colors.grey[400]),
                  const SizedBox(width: 6),
                  Text("Saved from $dateStr", style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, Color textColor, String type) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 80, color: Colors.grey.withOpacity(0.3)),
            const SizedBox(height: 24),
            Text(
              "You haven’t bookmarked any $type yet.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: textColor, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0E3A5D),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Browse Content"),
            ),
          ],
        ),
      ),
    );
  }
}
