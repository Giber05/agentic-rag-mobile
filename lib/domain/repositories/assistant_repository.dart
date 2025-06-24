import '../models/assistant_models.dart';
import '../../core/utils/resource.dart';

/// Abstract repository interface for intelligent assistant operations
abstract class AssistantRepository {
  /// Ask the intelligent assistant a question
  Future<AssistantAnswerDomain> askQuestion({
    required String question,
    RAGOptionsDomain? options,
    List<Map<String, String>>? conversationHistory,
  });

  /// Search for knowledge in the vector database
  Future<Resource<List<KnowledgeSourceDomain>>> searchKnowledge({
    required String query,
    int limit = 10,
    double threshold = 0.7,
    String strategy = 'semantic',
  });

  /// Get suggestions for query improvement
  Future<Resource<List<String>>> getSuggestions(String query);

  /// Check the health of the assistant system
  Future<AssistantHealthDomain> checkHealth();

  /// Get comprehensive system metrics
  Future<Resource<AssistantMetricsDomain>> getMetrics();
}
