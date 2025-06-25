import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../entities/auth_token.dart';
import '../repositories/auth_repository.dart';
import '../../core/usecases/usecase.dart';
import '../../core/utils/resource.dart';
import '../../core/error/exceptions.dart';

@injectable

class RegisterUseCase extends Usecase<RegisterParams, AuthToken> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Resource<AuthToken>> execute(RegisterParams params) async {
    final result = await repository.register(email: params.email, password: params.password, fullName: params.fullName);

    return result.fold(
      (failure) => Resource.error(BaseException(message: failure.message)),
      (token) => Resource.success(token),
    );
  }
}

class RegisterParams extends Equatable {
  final String email;
  final String password;
  final String? fullName;

  const RegisterParams({required this.email, required this.password, this.fullName});

  @override
  List<Object?> get props => [email, password, fullName];
}
