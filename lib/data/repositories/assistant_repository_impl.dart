import 'package:injectable/injectable.dart';

import '../../domain/models/assistant_models.dart';
import '../../domain/repositories/assistant_repository.dart';
import '../../core/utils/resource.dart';
import '../../core/error/exceptions.dart';
import '../datasources/abstract/assistant_datasource.dart';
import '../dto/assistant_dto.dart';
import '../mapper/assistant_mapper.dart';

/// Implementation of AssistantRepository using datasources and mappers
@Injectable(as: AssistantRepository)
class AssistantRepositoryImpl implements AssistantRepository {
  final AssistantDatasource _datasource;

  AssistantRepositoryImpl(this._datasource);

  @override
  Future<AssistantAnswerDomain> askQuestion({
    required String question,
    RAGOptionsDomain? options,
    List<Map<String, String>>? conversationHistory,
  }) async {
    final optionsDto = options != null ? RAGOptionsDto(
          maxSources: options.maxSources,
          citationStyle: options.citationStyle,
          responseFormat: options.responseFormat,
          enableStreaming: options.enableStreaming,
        )
      : null;
    final result = await _datasource.askQuestion(
      question: question,
      options: optionsDto,
      conversationHistory: conversationHistory,
    );

    return AssistantMapper.toDomain(result.data);
  }

  @override
  Future<Resource<List<KnowledgeSourceDomain>>> searchKnowledge({
    required String query,
    int limit = 10,
    double threshold = 0.7,
    String strategy = 'semantic',
  }) async {
    try {
      final result = await _datasource.searchKnowledge(query: query, limit: limit, threshold: threshold);

      if (result.isSuccess) {
        final domainSources = AssistantMapper.searchResultsToDomain(result.data);
        return Resource.success(domainSources, message: result.message);
      } else {
        return Resource.error(BaseException(message: result.message));
      }
    } catch (e) {
      return Resource.error(BaseException(message: e.toString()));
    }
  }

  @override
  Future<Resource<List<String>>> getSuggestions(String query) async {
    try {
      // For now, return some default suggestions
      // This can be enhanced with an actual API endpoint
      final suggestions = [
        'What is $query?',
        'How does $query work?',
        'Tell me more about $query',
        'What are the benefits of $query?',
        'Can you explain $query in detail?',
      ];

      return Resource.success(suggestions, message: 'Suggestions generated');
    } catch (e) {
      return Resource.error(BaseException(message: e.toString()));
    }
  }

  @override
  Future<AssistantHealthDomain> checkHealth() async {
    final result = await _datasource.getHealthStatus();

    return AssistantMapper.healthToDomain(result.data);
  }

  @override
  Future<Resource<AssistantMetricsDomain>> getMetrics() async {
    try {
      final result = await _datasource.getMetrics();

      if (result.isSuccess) {
        final domainMetrics = AssistantMapper.metricsToDomain(result.data);
        return Resource.success(domainMetrics, message: result.message);
      } else {
        return Resource.error(BaseException(message: result.message));
      }
    } catch (e) {
      return Resource.error(BaseException(message: e.toString()));
    }
  }
}
