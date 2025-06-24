import 'package:equatable/equatable.dart';
import '../entities/auth_token.dart';
import '../repositories/auth_repository.dart';
import '../../core/usecases/usecase.dart';
import '../../core/utils/resource.dart';
import '../../core/error/exceptions.dart';

class LoginUseCase extends Usecase<LoginParams, AuthToken> {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  @override
  Future<Resource<AuthToken>> execute(LoginParams params) async {
    final result = await repository.login(email: params.email, password: params.password);

    return result.fold(
      (failure) => Resource.error(BaseException(message: failure.message)),
      (token) => Resource.success(token),
    );
  }
}

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}
 