import '../models/assistant_models.dart';
import '../repositories/assistant_repository.dart';
import '../../core/usecases/usecase.dart';
import '../../core/utils/resource.dart';

/// Usecase for searching knowledge in the vector database
class SearchKnowledgeUsecase extends Usecase<SearchKnowledgeParams, List<KnowledgeSourceDomain>> {
  final AssistantRepository _repository;

  SearchKnowledgeUsecase(this._repository);

  @override
  Future<Resource<List<KnowledgeSourceDomain>>> execute(SearchKnowledgeParams params) async {
    return await _repository.searchKnowledge(
      query: params.query,
      limit: params.limit,
      threshold: params.threshold,
      strategy: params.strategy,
    );
  }
}

/// Parameters for searching knowledge
class SearchKnowledgeParams {
  final String query;
  final int limit;
  final double threshold;
  final String strategy;

  const SearchKnowledgeParams({required this.query, this.limit = 10, this.threshold = 0.7, this.strategy = 'semantic'});
}
