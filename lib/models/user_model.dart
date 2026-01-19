class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role;
  final String? profilePic;
  final String department;
  final String registrationNumber;
  final String semester;
  final String status;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.profilePic,
    required this.department,
    required this.registrationNumber,
    required this.semester,
    required this.status,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'student',
      department: map['department'] ?? '',
      profilePic: map['profilePic'],
      registrationNumber: map['registrationNumber'] ?? '',
      semester: map['semester'] ?? '',
      status: map['status'] ?? 'approved', 
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'profilePic': profilePic,
      'department': department,
      'registrationNumber': registrationNumber,
      'semester': semester,
      'status': status,
    };
  }
}
