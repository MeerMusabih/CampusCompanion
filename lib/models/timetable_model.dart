class TimetableModel {
  final String id;
  final String title;
  final String room;
  final String prof;
  final String day; 
  final String startTime; 
  final String endTime;   
  final String department;
  final String semester;  
  final String section;   
  final String type;      
  
  TimetableModel({
    required this.id,
    required this.title,
    required this.room,
    required this.prof,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.department,
    required this.semester,
    required this.section,
    required this.type,
  });
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'room': room,
      'prof': prof,
      'day': day,
      'startTime': startTime,
      'endTime': endTime,
      'department': department,
      'semester': semester,
      'section': section,
      'type': type,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    };
  }
  factory TimetableModel.fromMap(Map<String, dynamic> map, String id) {
    return TimetableModel(
      id: id,
      title: map['title'] ?? '',
      room: map['room'] ?? '',
      prof: map['prof'] ?? '',
      day: map['day'] ?? 'Monday',
      startTime: map['startTime'] ?? map['time'] ?? '08:30',
      endTime: map['endTime'] ?? '10:00',
      department: map['department'] ?? 'CS',
      semester: map['semester']?.toString() ?? '1',
      section: map['section'] ?? 'A',
      type: map['type'] ?? 'Lecture',
    );
  }
}
