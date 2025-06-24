import 'package:injectable/injectable.dart';

import '../abstract/assistant_datasource.dart';
import '../../dto/assistant_dto.dart';
import '../../../core/utils/api_result.dart';
import '../../../core/network/api_client.dart';

/// Concrete implementation of AssistantDatasource using API client
@LazySingleton(as: AssistantDatasource)
class AssistantDatasourceImpl implements AssistantDatasource {
  final APIClient _apiClient;

  AssistantDatasourceImpl(this._apiClient);

  @override
  Future<APIResult<AssistantAnswerDto>> askQuestion({
    required String question,
    RAGOptionsDto? options,
    List<Map<String, String>>? conversationHistory,
  }) async {
    // Prepare request data
    final requestData = {
      'query': question,
      if (conversationHistory != null && conversationHistory.isNotEmpty) 'conversation_history': conversationHistory,
      if (options != null)
        'pipeline_config': {
          'max_sources': options.maxSources,
          'citation_style': options.citationStyle,
          'response_format': options.responseFormat,
          'enable_streaming': options.enableStreaming,
        },
    };

    // Call the optimized RAG pipeline endpoint (80-90% cost savings)
    final result = await _apiClient.post<AssistantAnswerDto>(
      path: '/api/v1/rag/process/full', // Uses optimized pipeline by default
      body: requestData,
      mapper: (json, headers) => AssistantAnswerDto.fromJson(json),
    );

    return result;
  }

  @override
  Future<APIResult<AssistantAnswerDto>> processRagQuery(RAGRequestDto request) async {
    // Keep this method for backward compatibility, but redirect to askQuestion
    return await askQuestion(
      question: request.query,
      conversationHistory: request.conversationHistory,
      // Note: We'll need to convert RAGRequestDto to proper format
    );
  }

  @override
  Future<APIResult<List<Map<String, dynamic>>>> searchKnowledge({
    required String query,
    int limit = 10,
    double threshold = 0.7,
  }) async {
    return await _apiClient.post<List<Map<String, dynamic>>>(
      path: '/api/v1/search/semantic',
      body: {'query': query, 'limit': limit, 'threshold': threshold},
      mapper: (json, headers) {
        final data = json['data'] as Map<String, dynamic>? ?? {};
        final results = data['results'] as List? ?? [];
        return results.cast<Map<String, dynamic>>();
      },
    );
  }

  @override
  Future<APIResult<Map<String, dynamic>>> getHealthStatus() async {
    return await _apiClient.get<Map<String, dynamic>>(
      path: '/health',
      mapper: (json, headers) => json as Map<String, dynamic>,
    );
  }

  @override
  Future<APIResult<Map<String, dynamic>>> getPipelineStatus() async {
    return await _apiClient.get<Map<String, dynamic>>(
      path: '/api/v1/rag/pipeline/status',
      mapper: (json, headers) => json as Map<String, dynamic>,
    );
  }

  @override
  Future<APIResult<Map<String, dynamic>>> getMetrics() async {
    return await _apiClient.get<Map<String, dynamic>>(
      path: '/api/v1/rag/pipeline/metrics',
      mapper: (json, headers) => json as Map<String, dynamic>,
    );
  }
}
