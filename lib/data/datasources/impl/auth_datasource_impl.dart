import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/api_result.dart';
import '../../models/auth_models.dart';
import '../abstract/auth_datasource.dart';

class AuthDatasourceImpl implements AuthDatasource {
  final APIClient apiClient;

  AuthDatasourceImpl(this.apiClient);

  @override
  Future<Either<Failure, AuthTokenModel>> login({required String email, required String password}) async {
    try {
      final request = LoginRequest(email: email, password: password);
      final result = await apiClient.post<AuthTokenModel>(
        path: '/api/v1/supabase-auth/login',
        mapper: (json, headers) {
          final responseData = json as Map<String, dynamic>;
          final data = responseData['data'] as Map<String, dynamic>;
          return AuthTokenModel.fromJson(data);
        },
        body: request.toJson(),
      );

      if (result.isSuccess) {
        return Right(result.data);
      } else {
        return Left(_handleApiError(result.message));
      }
    } catch (e) {
      return Left(NetworkFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthTokenModel>> register({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final request = RegisterRequest(email: email, password: password, fullName: fullName);
      final result = await apiClient.post<AuthTokenModel>(
        path: '/api/v1/supabase-auth/register',
        mapper: (json, headers) {
          final responseData = json as Map<String, dynamic>;
          // For registration, we might not get auth tokens immediately
          // if email verification is required
          if (responseData['data'] != null && responseData['data'] is Map) {
            final data = responseData['data'] as Map<String, dynamic>;
            if (data.containsKey('access_token')) {
              return AuthTokenModel.fromJson(data);
            } else {
              // Registration successful but no tokens (email verification required)
              return AuthTokenModel(accessToken: '', refreshToken: '', tokenType: 'bearer', expiresAt: DateTime.now());
            }
          }
          return AuthTokenModel.fromJson(responseData['data'] as Map<String, dynamic>);
        },
        body: request.toJson(),
      );

      if (result.isSuccess) {
        return Right(result.data);
      } else {
        return Left(_handleApiError(result.message));
      }
    } catch (e) {
      return Left(NetworkFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      final result = await apiClient.post<Map<String, dynamic>>(
        path: '/api/v1/supabase-auth/logout',
        mapper: (json, headers) => json as Map<String, dynamic>,
      );

      if (result.isSuccess) {
        return const Right(unit);
      } else {
        return Left(_handleApiError(result.message));
      }
    } catch (e) {
      return Left(NetworkFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthTokenModel>> refreshToken(String refreshToken) async {
    try {
      final result = await apiClient.post<AuthTokenModel>(
        path: '/api/v1/supabase-auth/refresh',
        mapper: (json, headers) {
          final responseData = json as Map<String, dynamic>;
          final data = responseData['data'] as Map<String, dynamic>;
          return AuthTokenModel.fromJson(data);
        },
        body: {'refresh_token': refreshToken},
      );

      if (result.isSuccess) {
        return Right(result.data);
      } else {
        return Left(_handleApiError(result.message));
      }
    } catch (e) {
      return Left(NetworkFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> getCurrentUser() async {
    try {
      final result = await apiClient.get<UserModel>(
        path: '/api/v1/supabase-auth/me',
        mapper: (json, headers) {
          final responseData = json as Map<String, dynamic>;
          final data = responseData['data'] as Map<String, dynamic>;
          return UserModel.fromJson(data);
        },
      );

      if (result.isSuccess) {
        return Right(result.data);
      } else {
        return Left(_handleApiError(result.message));
      }
    } catch (e) {
      return Left(NetworkFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> forgotPassword(String email) async {
    try {
      final result = await apiClient.post<Map<String, dynamic>>(
        path: '/api/v1/supabase-auth/forgot-password',
        mapper: (json, headers) => json as Map<String, dynamic>,
        body: {'email': email},
      );

      if (result.isSuccess) {
        return const Right(unit);
      } else {
        return Left(_handleApiError(result.message));
      }
    } catch (e) {
      return Left(NetworkFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> resetPassword({required String token, required String newPassword}) async {
    try {
      final result = await apiClient.post<Map<String, dynamic>>(
        path: '/api/v1/supabase-auth/reset-password',
        mapper: (json, headers) => json as Map<String, dynamic>,
        body: {'token': token, 'new_password': newPassword},
      );

      if (result.isSuccess) {
        return const Right(unit);
      } else {
        return Left(_handleApiError(result.message));
      }
    } catch (e) {
      return Left(NetworkFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> changePassword({required String currentPassword, required String newPassword}) async {
    try {
      final result = await apiClient.post<Map<String, dynamic>>(
        path: '/api/v1/supabase-auth/change-password',
        mapper: (json, headers) => json as Map<String, dynamic>,
        body: {'current_password': currentPassword, 'new_password': newPassword},
      );

      if (result.isSuccess) {
        return const Right(unit);
      } else {
        return Left(_handleApiError(result.message));
      }
    } catch (e) {
      return Left(NetworkFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> updateProfile({String? fullName, String? email}) async {
    try {
      final body = <String, dynamic>{};
      if (fullName != null) body['full_name'] = fullName;
      if (email != null) body['email'] = email;

      final result = await apiClient.put<UserModel>(
        path: '/api/v1/supabase-auth/profile',
        mapper: (json, headers) {
          final responseData = json as Map<String, dynamic>;
          final data = responseData['data'] as Map<String, dynamic>;
          return UserModel.fromJson(data);
        },
        body: body,
      );

      if (result.isSuccess) {
        return Right(result.data);
      } else {
        return Left(_handleApiError(result.message));
      }
    } catch (e) {
      return Left(NetworkFailure(message: e.toString()));
    }
  }

  Failure _handleApiError(String message) {
    // Basic error handling - could be enhanced based on status codes
    if (message.toLowerCase().contains('unauthorized') || message.toLowerCase().contains('invalid credentials')) {
      return ValidationFailure(message: message, statusCode: 401);
    } else if (message.toLowerCase().contains('validation') || message.toLowerCase().contains('invalid')) {
      return ValidationFailure(message: message, statusCode: 422);
    } else if (message.toLowerCase().contains('server') || message.toLowerCase().contains('internal')) {
      return ServerFailure(message: message, statusCode: 500);
    } else {
      return NetworkFailure(message: message);
    }
  }
}
 