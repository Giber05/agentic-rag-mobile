import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String? fullName;
  final String role;
  final String status;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const User({
    required this.id,
    required this.email,
    this.fullName,
    required this.role,
    required this.status,
    required this.createdAt,
    this.lastLoginAt,
  });

  @override
  List<Object?> get props => [id, email, fullName, role, status, createdAt, lastLoginAt];

  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? role,
    String? status,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
