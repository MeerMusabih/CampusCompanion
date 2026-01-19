import 'package:flutter/material.dart';
import '../../models/notice_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/notice_provider.dart';
import '../../providers/comment_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/comment_model.dart';
class NoticeDetailsScreen extends StatefulWidget {
  final NoticeModel notice;
  const NoticeDetailsScreen({super.key, required this.notice});
  @override
  State<NoticeDetailsScreen> createState() => _NoticeDetailsScreenState();
}
class _NoticeDetailsScreenState extends State<NoticeDetailsScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _isCommenting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommentProvider>().listenToComments(widget.notice.id);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _handleComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final authProv = context.read<AuthProvider>();
    final user = authProv.user;
    if (user == null) return;

    final userProv = context.read<UserProvider>();
    final commentProv = context.read<CommentProvider>();
    
    setState(() => _isCommenting = true);
    
    try {
      final newComment = CommentModel(
        id: '', 
        authorName: userProv.currentUser?.name ?? "Student",
        authorId: user.uid,
        content: _commentController.text.trim(),
        timestamp: DateTime.now(),
      );
      
      await commentProv.addComment(widget.notice.id, newComment);
      _commentController.clear();
      FocusScope.of(context).unfocus();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error posting comment: $e")),
      );
    } finally {
      if (mounted) setState(() => _isCommenting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    
    final noticeProv = context.watch<NoticeProvider>();
    final authProv = context.watch<AuthProvider>();
    final userId = authProv.user?.uid;
    
    // Get the latest version of this notice from the provider to react to streams
    final currentNotice = noticeProv.notices.firstWhere(
      (n) => n.id == widget.notice.id, 
      orElse: () => widget.notice
    );

    final isLiked = userId != null && currentNotice.likes.contains(userId);
    final isBookmarked = userId != null && currentNotice.bookmarks.contains(userId);
    
    final bgColor = isDark ? const Color(0xFF0B1623) : Colors.grey[50];
    final cardColor = isDark ? const Color(0xFF152336) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F2643);
    final bodyColor = isDark ? Colors.grey[300] : Colors.grey[800];
    final metaColor = isDark ? Colors.grey[400] : Colors.grey[500];
    final commentInputBg = isDark ? const Color(0xFF152336) : Colors.white;
    final commentFieldBg = isDark ? const Color(0xFF0F172A) : Colors.grey[100];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF0F2643),
        title: const Text(
          "Notice Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round, color: Colors.white),
            onPressed: () => themeProvider.toggleTheme(),
          ),
          IconButton(
            icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border, 
                 color: isBookmarked ? Colors.orange : Colors.white),
            onPressed: () {
              if (userId != null) {
                noticeProv.toggleBookmark(currentNotice.id, userId);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.transparent : Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         if (currentNotice.attachmentUrl != null && currentNotice.attachmentUrl!.isNotEmpty)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Image.network(
                              currentNotice.attachmentUrl!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) => Container(
                                height: 200,
                                width: double.infinity,
                                color: Colors.grey[300],
                                child: const Icon(Icons.school, size: 50, color: Colors.white),
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
                                ),
                              ),
                            child: const Center(child: Icon(Icons.school, size: 60, color: Colors.white24)),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentNotice.title,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: titleColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Posted ${_formatDate(currentNotice.timestamp)}",
                                style: TextStyle(color: metaColor, fontSize: 13),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                currentNotice.content,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: bodyColor,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Divider(height: 1, color: isDark ? Colors.grey[800] : Colors.grey[200]),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, 
                                         size: 24, color: isLiked ? Colors.red : Colors.grey[400]),
                                    onPressed: () {
                                      if (userId != null) {
                                        noticeProv.toggleLike(currentNotice.id, userId);
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 4),
                                  Text("${currentNotice.likes.length}", style: TextStyle(color: Colors.grey[600])),
                                  const SizedBox(width: 16),
                                  Icon(Icons.chat_bubble_outline, size: 20, color: Colors.grey[400]),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${currentNotice.commentCount}", 
                                    style: TextStyle(color: Colors.grey[600])
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Comments",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Consumer<CommentProvider>(
                    builder: (context, commentProv, _) {
                      final comments = commentProv.getCommentsForNotice(currentNotice.id);
                      if (comments.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              "No comments yet. Be the first to comment!",
                              style: TextStyle(color: metaColor, fontSize: 13),
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          final List<Color> avatarColors = [
                            Colors.orange, Colors.blue, Colors.green, 
                            Colors.purple, Colors.red, Colors.teal
                          ];
                          final avatarColor = avatarColors[comment.authorName.length % avatarColors.length];
                          
                          return _buildCommentItem(
                            comment.authorName.substring(0, comment.authorName.length > 1 ? 2 : 1).toUpperCase(),
                            comment.authorName,
                            _formatDate(comment.timestamp),
                            comment.content,
                            avatarColor,
                            isDark,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: commentInputBg,
              border: Border(top: BorderSide(color: isDark ? Colors.grey[900]! : Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                        color: commentFieldBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: isDark ? Colors.transparent : Colors.grey[300]!),
                    ),
                    child: TextField(
                      controller: _commentController,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        hintText: "Write a comment...",
                        hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onSubmitted: (_) => _handleComment(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _isCommenting ? null : _handleComment,
                  child: Container(
                      height: 48,
                      width: 48,
                      decoration: const BoxDecoration(
                          color: Color(0xFF0F2643),
                          shape: BoxShape.circle,
                      ),  
                      child: _isCommenting 
                        ? const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
                        : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(String initials, String name, String time, String content, Color color, bool isDark) {
    final commentCardBg = isDark ? const Color(0xFF152336) : Colors.white;
    final nameColor = isDark ? Colors.white : const Color(0xFF0F2643);
    final textColor = isDark ? Colors.grey[300] : Colors.grey[700];
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: commentCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.transparent : Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color,
            child: Text(
              initials,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name, 
                      style: TextStyle(fontWeight: FontWeight.bold, color: nameColor),
                    ),
                    Text(
                      time, 
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: TextStyle(fontSize: 13, color: textColor, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  String _formatDate(DateTime date) {
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inHours < 24) return "${diff.inHours} hours ago";
      return DateFormat.yMMMd().format(date);
  }
}
