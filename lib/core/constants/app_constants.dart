class AppConstants {
  // API Configuration
  static const String apiVersion = 'v1';
  static const String apiPrefix = '/api/$apiVersion';

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 30000; // 30 seconds

  // Cache
  static const String cacheBoxName = 'app_cache';
  static const int defaultCacheDuration = 30; // minutes

  // Database
  static const String databaseName = 'agentic_rag.db';
  static const int databaseVersion = 1;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Agent Types
  static const String queryRewriterAgent = 'query_rewriter';
  static const String contextDecisionAgent = 'context_decision';
  static const String sourceRetrievalAgent = 'source_retrieval';
  static const String answerGenerationAgent = 'answer_generation';
  static const String validationRefinementAgent = 'validation_refinement';

  // Message Roles
  static const String userRole = 'user';
  static const String assistantRole = 'assistant';
  static const String systemRole = 'system';

  // WebSocket Events
  static const String wsEventMessage = 'message';
  static const String wsEventAgentStatus = 'agent_status';
  static const String wsEventError = 'error';
  static const String wsEventTyping = 'typing';
}
