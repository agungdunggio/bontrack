class UserModel {
  final String uid;
  final String phoneNumber; // Core master - nomor telepon
  final String name;
  final String? email; // Optional
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.phoneNumber,
    required this.name,
    this.email,
    required this.createdAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'name': name,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      name: map['name'] ?? '',
      email: map['email'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  UserModel copyWith({
    String? uid,
    String? phoneNumber,
    String? name,
    String? email,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

