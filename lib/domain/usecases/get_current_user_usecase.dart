import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import '../../core/usecases/usecase.dart';
import '../../core/utils/resource.dart';
import '../../core/error/exceptions.dart';

class GetCurrentUserUseCase extends UsecaseNoParams<User> {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  @override
  Future<Resource<User>> execute() async {
    final result = await repository.getCurrentUser();

    return result.fold(
      (failure) => Resource.error(BaseException(message: failure.message)),
      (user) => Resource.success(user),
    );
  }
}
