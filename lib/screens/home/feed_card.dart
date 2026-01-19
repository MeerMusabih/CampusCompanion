import 'package:flutter/material.dart';
import '../../models/notice_model.dart';
import '../../providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/notice_provider.dart';
import '../../providers/auth_provider.dart';
import '../../screens/notices/notice_details_screen.dart';
class FeedCard extends StatelessWidget {
  final NoticeModel notice;
  const FeedCard({super.key, required this.notice});
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inHours < 24) {
      return "${diff.inHours} hours ago";
    } else if (diff.inDays < 7) {
      return "${diff.inDays} days ago";
    } else {
      return DateFormat.yMMMd().format(date);
    }
  }
  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;
    final noticeProv = context.watch<NoticeProvider>();
    final authProv = context.watch<AuthProvider>();
    final userId = authProv.user?.uid;

    // Get the latest version of this notice from the provider
    final currentNotice = noticeProv.notices.firstWhere(
      (n) => n.id == notice.id, 
      orElse: () => notice
    );

    final isLiked = userId != null && currentNotice.likes.contains(userId);
    final isBookmarked = userId != null && currentNotice.bookmarks.contains(userId);

    final cardColor = isDarkMode ? const Color(0xFF152336) : Colors.white;
    final titleColor = isDarkMode ? Colors.white : const Color(0xFF0F2643);
    final contentColor = isDarkMode ? Colors.grey[300] : Colors.grey[600];
    final metaColor = isDarkMode ? Colors.grey[400] : Colors.grey[500];

    Color categoryBg;
    Color categoryText;
    switch (currentNotice.category) {
      case 'Exam':
        categoryBg = Colors.red[100]!;
        categoryText = Colors.red[800]!;
        break;
      case 'Holiday':
        categoryBg = Colors.green[100]!;
        categoryText = Colors.green[800]!;
        break;
      case 'Placement':
        categoryBg = Colors.purple[100]!;
        categoryText = Colors.purple[800]!;
        break;
      case 'Event':
      case 'Technical':
        categoryBg = Colors.orange[100]!;
        categoryText = Colors.orange[800]!;
        break;
      default:
        categoryBg = Colors.blue[100]!;
        categoryText = Colors.blue[800]!;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NoticeDetailsScreen(notice: currentNotice),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: currentNotice.isUrgent 
                ? Colors.red.withOpacity(0.5) 
                : (isDarkMode ? Colors.transparent : Colors.grey[200]!),
            width: currentNotice.isUrgent ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: currentNotice.isUrgent 
                  ? Colors.red.withOpacity(0.05) 
                  : Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                if (currentNotice.attachmentUrl != null && currentNotice.attachmentUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      currentNotice.attachmentUrl!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 180,
                        color: Colors.grey[200],
                        child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                      ),
                    ),
                  )
                else
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      gradient: LinearGradient(
                        colors: [Color(0xFF0F2643), Color(0xFF1E4C85)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.school, color: Colors.white24, size: 60),
                    ),
                  ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: categoryBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      currentNotice.category,
                      style: TextStyle(
                        color: categoryText,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (currentNotice.isUrgent)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.priority_high, color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text(
                            "URGENT",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    currentNotice.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentNotice.content,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: contentColor, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        _formatDate(currentNotice.timestamp),
                        style: TextStyle(color: metaColor, fontSize: 12),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          if (userId != null) {
                            noticeProv.toggleLike(currentNotice.id, userId);
                          }
                        },
                        child: Row(
                          children: [
                            Icon(isLiked ? Icons.favorite : Icons.favorite_border, 
                                 size: 20, color: isLiked ? Colors.red : metaColor),
                            const SizedBox(width: 4),
                            Text("${currentNotice.likes.length}", style: TextStyle(color: metaColor, fontSize: 12)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () {
                           if (userId != null) {
                            noticeProv.toggleBookmark(currentNotice.id, userId);
                          }
                        },
                        child: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border, 
                             size: 20, color: isBookmarked ? Colors.orange : metaColor),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.chat_bubble_outline, size: 20, color: metaColor),
                      const SizedBox(width: 4),
                      Text("${currentNotice.commentCount}", style: TextStyle(color: metaColor, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
