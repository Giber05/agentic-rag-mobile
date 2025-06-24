import 'package:equatable/equatable.dart';

/// Domain model for user session
class UserSessionModel extends Equatable {
  final String id;
  final String userId;
  final String accessToken;
  final String? refreshToken;
  final DateTime expiresAt;
  final Map<String, dynamic>? metadata;

  const UserSessionModel({
    required this.id,
    required this.userId,
    required this.accessToken,
    this.refreshToken,
    required this.expiresAt,
    this.metadata,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isValid => !isExpired && accessToken.isNotEmpty;

  UserSessionModel copyWith({
    String? id,
    String? userId,
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
    Map<String, dynamic>? metadata,
  }) {
    return UserSessionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [id, userId, accessToken, refreshToken, expiresAt, metadata];
}
