class UserModel {
  final String uid;
  final String email;
  final String name;
  final String? phoneNumber;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.phoneNumber,
    required this.createdAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? phoneNumber,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

