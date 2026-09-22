enum UserRole {
  user('user'),
  idolMaker('idol_maker'),
  admin('admin');

  const UserRole(this.value);
  final String value;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.user,
    );
  }

  // Add validation method
  static bool isValidRole(String value) {
    return UserRole.values.any((role) => role.value == value);
  }
}

class UserModel {
  final String uid;
  final String phoneNumber;
  final String? email;
  final String? name;
  final UserRole role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime lastLogin;

  UserModel({
    required this.uid,
    required this.phoneNumber,
    this.email,
    this.name,
    this.role = UserRole.user,
    this.isActive = true,
    required this.createdAt,
    required this.lastLogin,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      try {
        return (value as dynamic).toDate();
      } catch (_) {
        return DateTime.now();
      }
    }

    return UserModel(
      uid: map['uid'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'],
      name: map['name'],
      role: UserRole.fromString(map['role'] ?? 'user'),
      isActive: map['isActive'] ?? true,
      createdAt: parseDate(map['createdAt']),
      lastLogin: parseDate(map['lastLogin']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
      'email': email,
      'name': name,
      'role': role.value,
      'isActive': isActive,
      'createdAt': createdAt,
      'lastLogin': lastLogin,
    };
  }

  UserModel copyWith({
    String? uid,
    String? phoneNumber,
    String? email,
    String? name,
    UserRole? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
