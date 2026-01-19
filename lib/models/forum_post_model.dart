import 'package:cloud_firestore/cloud_firestore.dart';
class ForumPostModel {
  final String id;
  final String authorName;
  final String authorId;
  final String title;
  final String content;
  final DateTime timestamp;
  final int likes;
  final int comments;
  final String category;
  final List<String> bookmarks;
  ForumPostModel({
    required this.id,
    required this.authorName,
    required this.authorId,
    required this.title,
    required this.content,
    required this.timestamp,
    required this.category,
    this.likes = 0,
    this.comments = 0,
    this.bookmarks = const [],
  });
  Map<String, dynamic> toMap() {
    return {
      'authorName': authorName,
      'authorId': authorId,
      'title': title,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'category': category,
      'likes': likes,
      'comments': comments,
      'bookmarks': bookmarks,
    };
  }
  factory ForumPostModel.fromMap(Map<String, dynamic> map, String id) {
    return ForumPostModel(
      id: id,
      authorName: map['authorName'] ?? 'Anonymous',
      authorId: map['authorId'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      category: map['category'] ?? 'General',
      likes: map['likes'] ?? 0,
      comments: map['comments'] ?? 0,
      bookmarks: List<String>.from(map['bookmarks'] ?? []),
    );
  }
}
