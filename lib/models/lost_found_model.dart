class LostFoundModel {
  final String id;
  final String title;
  final String description;
  final String location;
  final String type;
  final String postedBy;
  final String contactInfo;
  final String? imageUrl;
  final DateTime dateTime;
  final bool isResolved;
  final String? keptAt;
  final List<String> bookmarks;
  LostFoundModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.type,
    required this.postedBy,
    required this.contactInfo,
    this.imageUrl,
    required this.dateTime,
    this.isResolved = false,
    this.keptAt,
    this.bookmarks = const [],
  });
  factory LostFoundModel.fromMap(Map<String, dynamic> map) {
    return LostFoundModel(
      id: map['id']?.toString() ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      location: map['location'] ?? '',
      type: map['type'] ?? 'Lost',
      postedBy: map['user_id'] ?? '',
      contactInfo: map['contact_info'] ?? '',
      imageUrl: map['image_url'],
      dateTime: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      isResolved: map['is_resolved'] ?? false,
      keptAt: map['kept_at'],
      bookmarks: List<String>.from(map['bookmarks'] ?? []),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'type': type,
      'user_id': postedBy,
      'contact_info': contactInfo,
      'image_url': imageUrl,
      'created_at': dateTime.toIso8601String(),
      'is_resolved': isResolved,
      'kept_at': keptAt,
      'bookmarks': bookmarks,
    };
  }
  LostFoundModel copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    String? imageUrl,
    DateTime? dateTime,
    String? contactInfo,
    bool? isResolved,
    String? location,
    String? postedBy,
    String? keptAt,
    List<String>? bookmarks,
  }) {
    return LostFoundModel(
      id: id ?? this.id,
      postedBy: postedBy ?? this.postedBy,
      location: location ?? this.location,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      dateTime: dateTime ?? this.dateTime,
      contactInfo: contactInfo ?? this.contactInfo,
      isResolved: isResolved ?? this.isResolved,
      keptAt: keptAt ?? this.keptAt,
      bookmarks: bookmarks ?? this.bookmarks,
    );
  }
}
