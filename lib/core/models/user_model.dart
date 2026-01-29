class UserModel {
  final String uid;
  final String phoneHash;
  final String phoneLast3; 
  final String name;
  final String? email;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.phoneHash,
    required this.phoneLast3,
    required this.name,
    this.email,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phoneHash': phoneHash,
      'phoneLast3': phoneLast3,
      'name': name,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      phoneHash: map['phoneHash'] ?? '',
      phoneLast3: map['phoneLast3'] ?? '',
      name: map['name'] ?? '',
      email: map['email'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  UserModel copyWith({
    String? uid,
    String? phoneHash,
    String? phoneLast3,
    String? name,
    String? email,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      phoneHash: phoneHash ?? this.phoneHash,
      phoneLast3: phoneLast3 ?? this.phoneLast3,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

