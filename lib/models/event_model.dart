import 'package:cloud_firestore/cloud_firestore.dart';
class EventModel {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime dateTime;
  final String organizer;
  final String category; 
  final String? imageUrl;
  final List<String> registeredUsers;
  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.dateTime,
    required this.organizer,
    required this.category,
    this.imageUrl,
    required this.registeredUsers,
  });
  factory EventModel.fromMap(Map<String, dynamic> map, String documentId) {
    DateTime parsedDate;
    if (map['dateTime'] is Timestamp) {
      parsedDate = (map['dateTime'] as Timestamp).toDate();
    } else if (map['dateTime'] is String) {
      parsedDate = DateTime.parse(map['dateTime']);
    } else {
      parsedDate = DateTime.now();
    }

    return EventModel(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      dateTime: parsedDate,
      organizer: map['organizer'] ?? '',
      category: map['category'] ?? 'General',
      imageUrl: map['imageUrl'],
      registeredUsers: List<String>.from(map['registeredUsers'] ?? []),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'dateTime': Timestamp.fromDate(dateTime),
      'organizer': organizer,
      'category': category,
      'imageUrl': imageUrl,
      'registeredUsers': registeredUsers,
    };
  }
}
