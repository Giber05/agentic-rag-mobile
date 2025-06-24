import 'package:equatable/equatable.dart';

class AuthToken extends Equatable {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final DateTime expiresAt;

  const AuthToken({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresAt,
  });

  @override
  List<Object> get props => [accessToken, refreshToken, tokenType, expiresAt];

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  AuthToken copyWith({String? accessToken, String? refreshToken, String? tokenType, DateTime? expiresAt}) {
    return AuthToken(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenType: tokenType ?? this.tokenType,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
