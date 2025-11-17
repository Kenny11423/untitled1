import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  user,
  admin,
}

class AppUser {
  final String id;
  final String email;
  final String? displayName;
  final UserRole role;
  final DateTime? createdAt;
  final bool isActive;

  AppUser({
    required this.id,
    required this.email,
    this.displayName,
    this.role = UserRole.user,
    this.createdAt,
    this.isActive = true,
  });

  factory AppUser.fromMap(Map<String, dynamic> data, String docId) {
    return AppUser(
      id: docId,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      role: data['role'] == 'admin' ? UserRole.admin : UserRole.user,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      if (displayName != null) 'displayName': displayName,
      'role': role == UserRole.admin ? 'admin' : 'user',
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'isActive': isActive,
    };
  }

  bool get isAdmin => role == UserRole.admin;

  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    UserRole? role,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

