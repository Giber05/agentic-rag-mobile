import 'package:dartz/dartz.dart';
import '../repositories/auth_repository.dart';
import '../../core/usecases/usecase.dart';
import '../../core/utils/resource.dart';
import '../../core/error/exceptions.dart';

class LogoutUseCase extends UsecaseNoParams<Unit> {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  @override
  Future<Resource<Unit>> execute() async {
    final result = await repository.logout();

    return result.fold(
      (failure) => Resource.error(BaseException(message: failure.message)),
      (unit) => Resource.success(unit),
    );
  }
}
