import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../models/auth_models.dart';

abstract class AuthDatasource {
  Future<Either<Failure, AuthTokenModel>> login({required String email, required String password});

  Future<Either<Failure, AuthTokenModel>> register({required String email, required String password, String? fullName});

  Future<Either<Failure, Unit>> logout();

  Future<Either<Failure, AuthTokenModel>> refreshToken(String refreshToken);

  Future<Either<Failure, UserModel>> getCurrentUser();

  Future<Either<Failure, Unit>> forgotPassword(String email);

  Future<Either<Failure, Unit>> resetPassword({required String token, required String newPassword});

  Future<Either<Failure, Unit>> changePassword({required String currentPassword, required String newPassword});

  Future<Either<Failure, UserModel>> updateProfile({String? fullName, String? email});
}
