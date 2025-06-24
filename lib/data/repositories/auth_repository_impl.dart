import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/user.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/errors/failures.dart';
import '../datasources/abstract/auth_datasource.dart';
import '../models/auth_models.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource datasource;

  AuthRepositoryImpl(this.datasource);

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'current_user';

  @override
  Future<Either<Failure, AuthToken>> login({required String email, required String password}) async {
    final result = await datasource.login(email: email, password: password);

    return result.fold((failure) => Left(failure), (token) async {
      await _storeToken(token);
      return Right(token);
    });
  }

  @override
  Future<Either<Failure, AuthToken>> register({
    required String email,
    required String password,
    String? fullName,
  }) async {
    final result = await datasource.register(email: email, password: password, fullName: fullName);

    return result.fold((failure) => Left(failure), (token) async {
      await _storeToken(token);
      return Right(token);
    });
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    final result = await datasource.logout();
    // Clear token after successful logout call
    await clearStoredToken();
    return result;
  }

  @override
  Future<Either<Failure, AuthToken>> refreshToken(String refreshToken) async {
    final result = await datasource.refreshToken(refreshToken);

    return result.fold((failure) => Left(failure), (token) async {
      await _storeToken(token);
      return Right(token);
    });
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    final result = await datasource.getCurrentUser();

    return result.fold((failure) => Left(failure), (user) async {
      await _storeUser(user);
      return Right(user);
    });
  }

  @override
  Future<Either<Failure, Unit>> forgotPassword(String email) async {
    return datasource.forgotPassword(email);
  }

  @override
  Future<Either<Failure, Unit>> resetPassword({required String token, required String newPassword}) async {
    return datasource.resetPassword(token: token, newPassword: newPassword);
  }

  @override
  Future<Either<Failure, Unit>> changePassword({required String currentPassword, required String newPassword}) async {
    return datasource.changePassword(currentPassword: currentPassword, newPassword: newPassword);
  }

  @override
  Future<Either<Failure, User>> updateProfile({String? fullName, String? email}) async {
    final result = await datasource.updateProfile(fullName: fullName, email: email);

    return result.fold((failure) => Left(failure), (user) async {
      await _storeUser(user);
      return Right(user);
    });
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await getStoredToken();
    return token != null && !token.isExpired;
  }

  @override
  Future<AuthToken?> getStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tokenJson = prefs.getString(_tokenKey);

      if (tokenJson != null) {
        final tokenMap = jsonDecode(tokenJson) as Map<String, dynamic>;
        return AuthTokenModel.fromJson(tokenMap);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<void> _storeToken(AuthTokenModel token) async {
    final prefs = await SharedPreferences.getInstance();
    final tokenJson = jsonEncode(token.toJson());
    await prefs.setString(_tokenKey, tokenJson);
  }

  Future<void> _storeUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(user.toJson());
    await prefs.setString(_userKey, userJson);
  }

  Future<User?> getStoredUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      if (userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        return UserModel.fromJson(userMap);
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}
