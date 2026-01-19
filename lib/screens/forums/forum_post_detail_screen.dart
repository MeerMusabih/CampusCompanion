import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/forum_post_model.dart';
import '../../models/comment_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/comment_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/forum_provider.dart';
import '../../services/firestore_service.dart';

class ForumPostDetailScreen extends StatefulWidget {
  final ForumPostModel post;

  const ForumPostDetailScreen({super.key, required this.post});

  @override
  State<ForumPostDetailScreen> createState() => _ForumPostDetailScreenState();
}

class _ForumPostDetailScreenState extends State<ForumPostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommentProvider>().listenToForumComments(widget.post.id);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      final authProv = context.read<AuthProvider>();
      final comment = CommentModel(
        id: '',
        authorName: authProv.user?.displayName ?? 'Anonymous',
        authorId: authProv.user?.uid ?? 'Unknown',
        content: _commentController.text.trim(),
        timestamp: DateTime.now(),
      );

      await context.read<CommentProvider>().addForumComment(widget.post.id, comment);
      _commentController.clear();
      FocusScope.of(context).unfocus();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final backgroundColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF7F9FC);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final navyColor = const Color(0xFF0E3A5D);
    final highlightColor = const Color(0xFFE3A42B);
    final textColor = isDark ? Colors.white : const Color(0xFF0F2643);
    final bodyColor = isDark ? Colors.grey[300]! : Colors.grey[600]!;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: navyColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Forum Post",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined, color: Colors.white),
            onPressed: () => context.read<ThemeProvider>().toggleTheme(),
          ),
        ],
      ),
      body: Consumer<ForumProvider>(
        builder: (context, forumProv, _) {
          // Find the latest version of this post from the provider
          final currentPost = forumProv.posts.firstWhere(
            (p) => p.id == widget.post.id,
            orElse: () => widget.post,
          );

          return Column(
            children: [
              Expanded(
                child: Consumer<CommentProvider>(
                  builder: (context, commentProv, _) {
                    final comments = commentProv.getCommentsForForumPost(widget.post.id);
                    
                    return ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        _buildPostCard(currentPost, isDark, cardColor, textColor, bodyColor, highlightColor, comments.length),
                        const SizedBox(height: 24),
                        Text(
                          "Comments (${comments.length})",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                        ),
                        const SizedBox(height: 16),
                        if (comments.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Column(
                                children: [
                                  Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey.withOpacity(0.3)),
                                  const SizedBox(height: 12),
                                  Text("No comments yet. Be the first to reply!", 
                                    style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                                ],
                              ),
                            ),
                          )
                        else
                          ...comments.map((comment) => _buildCommentCard(comment, isDark, cardColor, textColor, bodyColor)),
                        const SizedBox(height: 20),
                      ],
                    );
                  },
                ),
              ),
              _buildCommentInputField(isDark, cardColor, highlightColor),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPostCard(ForumPostModel post, bool isDark, Color cardColor, Color textColor, Color bodyColor, Color highlightColor, int actualCommentCount) {
    final timeStr = DateFormat('MMM d, hh:mm A').format(post.timestamp);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blueAccent.withOpacity(0.1),
                child: Text(post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : "?", 
                  style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.authorName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
                  Text(timeStr, style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: highlightColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  post.category,
                  style: TextStyle(color: highlightColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(post.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: textColor, height: 1.3)),
          const SizedBox(height: 12),
          Text(post.content, style: TextStyle(color: bodyColor, fontSize: 15, height: 1.6)),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildActionButton(Icons.thumb_up_alt_outlined, "${post.likes}", highlightColor, () {
                final authProv = context.read<AuthProvider>();
                context.read<ForumProvider>().toggleLike(post.id, authProv.user?.uid ?? '');
              }),
              const SizedBox(width: 24),
              _buildActionButton(Icons.chat_bubble_outline, "$actualCommentCount", Colors.grey, () {}),
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String count, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 6),
          Text(count, style: TextStyle(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildCommentCard(CommentModel comment, bool isDark, Color cardColor, Color textColor, Color bodyColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.orange.withOpacity(0.1),
            child: Text(comment.authorName[0].toUpperCase(), 
              style: const TextStyle(color: Colors.orange, fontSize: 14, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(comment.authorName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor)),
                    Text(DateFormat('hh:mm A').format(comment.timestamp), 
                      style: TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.content, style: TextStyle(color: bodyColor, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInputField(bool isDark, Color cardColor, Color highlightColor) {
    return Container(
      padding: EdgeInsets.only(
        left: 20, 
        right: 20, 
        top: 12, 
        bottom: MediaQuery.of(context).padding.bottom + 12
      ),
      decoration: BoxDecoration(
        color: cardColor,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _commentController,
                style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black87),
                decoration: const InputDecoration(
                  hintText: "Write a comment...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                maxLines: null,
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _isSubmitting ? null : _submitComment,
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: highlightColor,
                shape: BoxShape.circle,
              ),
              child: _isSubmitting 
                ? const Padding(
                    padding: EdgeInsets.all(10),
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
