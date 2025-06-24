import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../entities/auth_token.dart';
import '../../core/errors/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthToken>> login({required String email, required String password});

  Future<Either<Failure, AuthToken>> register({required String email, required String password, String? fullName});

  Future<Either<Failure, Unit>> logout();

  Future<Either<Failure, AuthToken>> refreshToken(String refreshToken);

  Future<Either<Failure, User>> getCurrentUser();

  Future<Either<Failure, Unit>> forgotPassword(String email);

  Future<Either<Failure, Unit>> resetPassword({required String token, required String newPassword});

  Future<Either<Failure, Unit>> changePassword({required String currentPassword, required String newPassword});

  Future<Either<Failure, User>> updateProfile({String? fullName, String? email});

  Future<bool> isLoggedIn();

  Future<AuthToken?> getStoredToken();

  Future<void> clearStoredToken();
}
