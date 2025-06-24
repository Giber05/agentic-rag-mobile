import '../../dto/assistant_dto.dart';
import '../../../core/utils/api_result.dart';

/// Abstract datasource for assistant operations
abstract class AssistantDatasource {
  /// Process a RAG query through the pipeline
  Future<APIResult<AssistantAnswerDto>> askQuestion({
    required String question,
    RAGOptionsDto? options,
    List<Map<String, String>>? conversationHistory,
  });

  /// Search for knowledge using semantic search
  Future<APIResult<List<Map<String, dynamic>>>> searchKnowledge({
    required String query,
    int limit = 10,
    double threshold = 0.7,
  });

  /// Get health status of the system
  Future<APIResult<Map<String, dynamic>>> getHealthStatus();

  /// Get pipeline status
  Future<APIResult<Map<String, dynamic>>> getPipelineStatus();

  /// Get system metrics
  Future<APIResult<Map<String, dynamic>>> getMetrics();
}
