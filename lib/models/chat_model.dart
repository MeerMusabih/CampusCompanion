import 'package:cloud_firestore/cloud_firestore.dart';
class ChatConversationModel {
  final String id;
  final List<String> participants; 
  final Map<String, String> participantNames; 
  final String lastMessage;
  final DateTime lastMessageTime;
  ChatConversationModel({
    required this.id,
    required this.participants,
    required this.participantNames,
    required this.lastMessage,
    required this.lastMessageTime,
  });
  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'participantNames': participantNames,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
    };
  }
  factory ChatConversationModel.fromMap(Map<String, dynamic> map, String id) {
    return ChatConversationModel(
      id: id,
      participants: List<String>.from(map['participants'] ?? []),
      participantNames: Map<String, String>.from(map['participantNames'] ?? {}),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: (map['lastMessageTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
class ChatMessageModel {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;
  ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
  });
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
  factory ChatMessageModel.fromMap(Map<String, dynamic> map, String id) {
    return ChatMessageModel(
      id: id,
      senderId: map['senderId'] ?? '',
      content: map['content'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
