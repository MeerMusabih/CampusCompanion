import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/user_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/forum_post_model.dart';
import '../../models/notice_model.dart';
import '../../models/lost_found_model.dart';

class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({super.key});

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> with SingleTickerProviderStateMixin {
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
          "My Posts",
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
            Tab(text: "Forums"),
            Tab(text: "Notices"),
            Tab(text: "Lost & Found"),
          ],
        ),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildPostsList<ForumPostModel>(
                  _firestoreService.getUserForumPosts(user.uid),
                  "Forums",
                  isDark,
                  cardColor,
                  textColor,
                  subTextColor,
                  highlightColor,
                ),
                _buildPostsList<NoticeModel>(
                  _firestoreService.getUserNotices(user.uid),
                  "Notices",
                  isDark,
                  cardColor,
                  textColor,
                  subTextColor,
                  highlightColor,
                ),
                _buildPostsList<LostFoundModel>(
                  _firestoreService.getLostFoundItems(), // We'll filter this in stream map if needed, but getLostFoundItems is currently global. 
                  // Let's assume we filter by user in a custom stream if we had one, for now we filter in UI for demonstration if needed or update service.
                  "Lost & Found",
                  isDark,
                  cardColor,
                  textColor,
                  subTextColor,
                  highlightColor,
                  userId: user.uid,
                ),
              ],
            ),
    );
  }

  Widget _buildPostsList<T>(
    Stream<List<T>> stream,
    String type,
    bool isDark,
    Color cardColor,
    Color textColor,
    Color subTextColor,
    Color highlightColor, {
    String? userId,
  }) {
    return StreamBuilder<List<T>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        var items = snapshot.data ?? [];
        
        // Filter for Lost & Found if it's the global stream
        if (userId != null && T == LostFoundModel) {
          items = (items as List<LostFoundModel>).where((item) => item.postedBy == userId).toList() as List<T>;
        }

        if (items.isEmpty) {
          return _buildEmptyState(isDark, textColor);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _buildPostCard(item, type, isDark, cardColor, textColor, subTextColor, highlightColor);
          },
        );
      },
    );
  }

  Widget _buildPostCard(dynamic item, String type, bool isDark, Color cardColor, Color textColor, Color subTextColor, Color highlightColor) {
    String title = "";
    String description = "";
    DateTime timestamp = DateTime.now();
    String status = "Active";

    if (item is ForumPostModel) {
      title = item.title;
      description = item.content;
      timestamp = item.timestamp;
    } else if (item is NoticeModel) {
      title = item.title;
      description = item.content;
      timestamp = item.timestamp;
    } else if (item is LostFoundModel) {
      title = item.title;
      description = item.description;
      timestamp = item.dateTime;
      status = item.isResolved ? "Resolved" : "Active";
    }

    final dateStr = DateFormat('MMM d, yyyy • hh:mm A').format(timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
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
                Text(
                  status,
                  style: TextStyle(
                    color: status == "Resolved" ? Colors.green : highlightColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
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
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 12, color: Colors.grey[400]),
                const SizedBox(width: 6),
                Text(dateStr, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                const Spacer(),
                _buildActionIcon(Icons.edit_outlined, Colors.blue, () {}),
                const SizedBox(width: 12),
                _buildActionIcon(Icons.delete_outline, Colors.red[300]!, () {}),
                const SizedBox(width: 12),
                _buildActionIcon(Icons.visibility_outlined, Colors.grey, () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Icon(icon, size: 20, color: color),
    );
  }

  Widget _buildEmptyState(bool isDark, Color textColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.post_add, size: 80, color: Colors.grey.withOpacity(0.3)),
            const SizedBox(height: 24),
            Text(
              "You haven’t posted anything yet.",
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
              child: const Text("Start Posting"),
            ),
          ],
        ),
      ),
    );
  }
}
