import 'package:cloud_firestore/cloud_firestore.dart';
class CommentModel {
  final String id;
  final String authorName;
  final String authorId;
  final String content;
  final DateTime timestamp;
  CommentModel({
    required this.id,
    required this.authorName,
    required this.authorId,
    required this.content,
    required this.timestamp,
  });
  Map<String, dynamic> toMap() {
    return {
      'authorName': authorName,
      'authorId': authorId,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
  factory CommentModel.fromMap(Map<String, dynamic> map, String id) {
    return CommentModel(
      id: id,
      authorName: map['authorName'] ?? map['userName'] ?? 'Anonymous',
      authorId: map['authorId'] ?? map['userId'] ?? '',
      content: map['content'] ?? '',
      timestamp: (map['timestamp'] is Timestamp) 
          ? (map['timestamp'] as Timestamp).toDate() 
          : (map['timestamp'] is String)
              ? DateTime.parse(map['timestamp'] as String)
              : DateTime.now(),
    );
  }
}
