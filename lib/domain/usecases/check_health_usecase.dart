import 'package:injectable/injectable.dart';

import '../models/assistant_models.dart';
import '../repositories/assistant_repository.dart';
import '../../core/usecases/usecase.dart';
import '../../core/utils/resource.dart';

/// Usecase for checking assistant health
@injectable
class CheckHealthUsecase extends UsecaseNoParams<AssistantHealthDomain> {
  final AssistantRepository _repository;

  CheckHealthUsecase(this._repository);

  @override
  Future<Resource<AssistantHealthDomain>> execute() async {
    return await _repository.checkHealth().asResource;
  }
}
