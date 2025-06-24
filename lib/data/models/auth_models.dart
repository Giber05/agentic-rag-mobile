import '../../domain/entities/user.dart';
import '../../domain/entities/auth_token.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    super.fullName,
    required super.role,
    required super.status,
    required super.createdAt,
    super.lastLoginAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      role: json['role'] as String,
      status: json['status'] as String? ?? 'active', // Default to active if not provided
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.now(), // Default to now if not provided
      lastLoginAt: json['last_login_at'] != null ? DateTime.parse(json['last_login_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
    };
  }
}

class AuthTokenModel extends AuthToken {
  const AuthTokenModel({
    required super.accessToken,
    required super.refreshToken,
    required super.tokenType,
    required super.expiresAt,
  });

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) {
    final expiresIn = json['expires_in'] as int? ?? 3600;
    final expiresAt = DateTime.now().add(Duration(seconds: expiresIn));

    return AuthTokenModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String? ?? 'bearer',
      expiresAt: expiresAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'expires_at': expiresAt.toIso8601String(),
    };
  }
}

class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}

class RegisterRequest {
  final String email;
  final String password;
  final String? fullName;

  const RegisterRequest({required this.email, required this.password, this.fullName});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password, if (fullName != null) 'full_name': fullName};
  }
}
