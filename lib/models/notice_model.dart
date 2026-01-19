import 'package:cloud_firestore/cloud_firestore.dart';
class NoticeModel {
  final String id;
  final String title;
  final String content;
  final String category; 
  final DateTime timestamp;
  final String? attachmentUrl;
  final bool isUrgent;
  final int commentCount;
  final List<String> likes;
  final List<String> bookmarks;
  final String? _authorName;

  NoticeModel({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.timestamp,
    this.attachmentUrl,
    this.isUrgent = false,
    this.commentCount = 0,
    this.likes = const [],
    this.bookmarks = const [],
    String? authorName,
  }) : _authorName = authorName;

  factory NoticeModel.fromMap(Map<String, dynamic> map, String documentId) {
    DateTime parsedDate;
    if (map['timestamp'] is Timestamp) {
      parsedDate = (map['timestamp'] as Timestamp).toDate();
    } else if (map['timestamp'] is String) {
      parsedDate = DateTime.parse(map['timestamp']);
    } else {
      parsedDate = DateTime.now();
    }

    return NoticeModel(
      id: documentId,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      category: map['category'] ?? 'General',
      timestamp: parsedDate,
      attachmentUrl: map['attachmentUrl'],
      isUrgent: map['isUrgent'] ?? false,
      commentCount: map['commentCount'] ?? 0,
      likes: List<String>.from(map['likes'] ?? []),
      bookmarks: List<String>.from(map['bookmarks'] ?? []),
      authorName: map['authorName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'category': category,
      'timestamp': Timestamp.fromDate(timestamp),
      'attachmentUrl': attachmentUrl,
      'isUrgent': isUrgent,
      'commentCount': commentCount,
      'likes': likes,
      'bookmarks': bookmarks,
      'authorName': _authorName,
    };
  }
  String? get authorName => _authorName;
}
