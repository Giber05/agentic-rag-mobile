import '../repositories/assistant_repository.dart';
import '../../core/usecases/usecase.dart';
import '../../core/utils/resource.dart';

/// Usecase for getting query suggestions
class GetSuggestionsUsecase extends Usecase<String, List<String>> {
  final AssistantRepository _repository;

  GetSuggestionsUsecase(this._repository);

  @override
  Future<Resource<List<String>>> execute(String query) async {
    return await _repository.getSuggestions(query);
  }
}
