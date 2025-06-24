import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/models/assistant_models.dart';
import '../../../domain/usecases/ask_question_usecase.dart';
import '../../../domain/usecases/search_knowledge_usecase.dart';
import '../../../domain/usecases/get_suggestions_usecase.dart';
import '../../../domain/usecases/check_health_usecase.dart';
import '../../../core/utils/resource.dart';

part 'assistant_state.dart';

/// Cubit for managing intelligent assistant interactions using clean architecture
class AssistantCubit extends Cubit<AssistantState> {
  final AskQuestionUsecase _askQuestionUsecase;
  final SearchKnowledgeUsecase _searchKnowledgeUsecase;
  final GetSuggestionsUsecase _getSuggestionsUsecase;
  final CheckHealthUsecase _checkHealthUsecase;
  final Logger _logger;
  final Uuid _uuid = const Uuid();

  AssistantCubit()
    : _askQuestionUsecase = GetIt.instance<AskQuestionUsecase>(),
      _searchKnowledgeUsecase = GetIt.instance<SearchKnowledgeUsecase>(),
      _getSuggestionsUsecase = GetIt.instance<GetSuggestionsUsecase>(),
      _checkHealthUsecase = GetIt.instance<CheckHealthUsecase>(),
      _logger = GetIt.instance<Logger>(),
      super(const AssistantState());

  /// Ask a question to the intelligent assistant with conversation flow
  Future<void> askQuestion(String question) async {
    if (question.trim().isEmpty) {
      emit(state.copyWith(status: AssistantStatus.error, errorMessage: 'Please enter a question'));
      return;
    }

    try {
      _logger.i('Asking question: $question');

      // Create user message and add to conversation immediately
      final userMessage = ConversationMessage(
        id: _uuid.v4(),
        content: question.trim(),
        isUser: true,
        timestamp: DateTime.now(),
      );

      // Add user message to conversation
      final updatedConversation = [...state.conversation, userMessage];

      // Create a new query
      final query = AssistantQueryDomain(
        id: _uuid.v4(),
        question: question.trim(),
        timestamp: DateTime.now(),
        status: QueryStatus.processing,
      );

      // Update state to show processing with user message visible
      emit(
        state.copyWith(
          status: AssistantStatus.processing,
          currentQuery: query,
          conversation: updatedConversation,
          errorMessage: null,
          typingText: 'AI is thinking...',
        ),
      );

      // Simulate typing delay for better UX
      await Future.delayed(const Duration(milliseconds: 800));

      // Ask the question using usecase
      final params = AskQuestionParams(
        question: question.trim(),
        options: const RAGOptionsDomain(citationStyle: 'numbered', maxSources: 5, responseFormat: 'markdown'),
        conversationHistory: _convertConversationToHistory(state.conversation),
      );

      final result = await _askQuestionUsecase(params);
      // final result = Success<AssistantAnswerDomain>(
      //   data: AssistantAnswerDomain(
      //     id: _uuid.v4(),
      //     content: 'test',
      //     queryId: query.id,
      //     sources: [],
      //     timestamp: DateTime.now(),
      //   ),
      //   message: 'test',
      // );

      switch (result) {
        case Success<AssistantAnswerDomain> success:
          // Update query status
          final completedQuery = query.copyWith(status: QueryStatus.completed);

          // Create AI response message
          final aiMessage = ConversationMessage(
            id: _uuid.v4(),
            content: success.data.content,
            isUser: false,
            timestamp: DateTime.now(),
            status: QueryStatus.completed,
            answer: success.data,
          );

          // Add AI response to conversation
          final finalConversation = [...updatedConversation, aiMessage];

          // Create query-answer pair for history
          final pair = QueryAnswerPairDomain(query: completedQuery, answer: success.data);
          final updatedHistory = [pair, ...state.queryHistory];

          emit(
            state.copyWith(
              status: AssistantStatus.success,
              currentQuery: completedQuery,
              currentAnswer: success.data,
              conversation: finalConversation,
              queryHistory: updatedHistory,
              errorMessage: null,
              typingText: null,
            ),
          );

          _logger.i('Question answered successfully');
          break;

        case Error<AssistantAnswerDomain> error:
          // Update query status to failed
          final failedQuery = query.copyWith(status: QueryStatus.failed);

          // Create error message
          final errorMessage = ConversationMessage(
            id: _uuid.v4(),
            content: 'Sorry, I encountered an error: ${error.exception.message}',
            isUser: false,
            timestamp: DateTime.now(),
            status: QueryStatus.failed,
          );

          final finalConversation = [...updatedConversation, errorMessage];

          emit(
            state.copyWith(
              status: AssistantStatus.error,
              currentQuery: failedQuery,
              conversation: finalConversation,
              errorMessage: error.exception.message,
              typingText: null,
            ),
          );

          _logger.e('Error asking question: ${error.exception.message}');
          break;
      }
    } catch (e) {
      _logger.e('Unexpected error asking question: $e');

      // Update query status to failed
      final failedQuery = state.currentQuery?.copyWith(status: QueryStatus.failed);

      // Add error message to conversation
      final errorMessage = ConversationMessage(
        id: _uuid.v4(),
        content: 'An unexpected error occurred. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
        status: QueryStatus.failed,
      );

      final updatedConversation = [...state.conversation, errorMessage];

      emit(
        state.copyWith(
          status: AssistantStatus.error,
          currentQuery: failedQuery,
          conversation: updatedConversation,
          errorMessage: 'An unexpected error occurred',
          typingText: null,
        ),
      );
    }
  }

  /// Clear the current query and answer (but keep conversation)
  void clearCurrent() {
    emit(
      state.copyWith(
        status: AssistantStatus.initial,
        currentQuery: null,
        currentAnswer: null,
        errorMessage: null,
        typingText: null,
      ),
    );
  }

  /// Clear entire conversation
  void clearConversation() {
    emit(
      state.copyWith(
        status: AssistantStatus.initial,
        conversation: [],
        currentQuery: null,
        currentAnswer: null,
        errorMessage: null,
        typingText: null,
      ),
    );
  }

  /// Search for knowledge without asking a full question
  Future<void> searchKnowledge(String query) async {
    if (query.trim().isEmpty) return;

    try {
      _logger.i('Searching knowledge for: $query');

      emit(state.copyWith(status: AssistantStatus.searching, errorMessage: null));

      final params = SearchKnowledgeParams(query: query.trim(), limit: 10, threshold: 0.7);
      final result = await _searchKnowledgeUsecase(params);

      switch (result) {
        case Success<List<KnowledgeSourceDomain>> success:
          emit(
            state.copyWith(
              status: AssistantStatus.searchComplete,
              searchResults: success.data,
              searchQuery: query.trim(),
            ),
          );

          _logger.i('Knowledge search completed with ${success.data.length} results');
          break;

        case Error<List<KnowledgeSourceDomain>> error:
          emit(state.copyWith(status: AssistantStatus.error, errorMessage: error.exception.message));

          _logger.e('Error searching knowledge: ${error.exception.message}');
          break;
      }
    } catch (e) {
      _logger.e('Unexpected error searching knowledge: $e');
      emit(state.copyWith(status: AssistantStatus.error, errorMessage: 'An unexpected error occurred'));
    }
  }

  /// Get query suggestions
  Future<void> getSuggestions(String query) async {
    if (query.trim().isEmpty) {
      emit(state.copyWith(suggestions: []));
      return;
    }

    try {
      final result = await _getSuggestionsUsecase.execute(query.trim());

      switch (result) {
        case Success<List<String>> success:
          emit(state.copyWith(suggestions: success.data));
          break;

        case Error<List<String>> error:
          _logger.e('Error getting suggestions: ${error.exception.message}');
          emit(state.copyWith(suggestions: []));
          break;
      }
    } catch (e) {
      _logger.e('Unexpected error getting suggestions: $e');
      emit(state.copyWith(suggestions: []));
    }
  }

  /// Clear suggestions
  void clearSuggestions() {
    emit(state.copyWith(suggestions: []));
  }

  /// Check assistant health
  Future<void> checkHealth() async {
    _logger.i('Checking assistant health');

    final result = await _checkHealthUsecase();

    switch (result) {
      case Success<AssistantHealthDomain> success:
        emit(state.copyWith(healthStatus: success.data, lastHealthCheck: DateTime.now()));

        _logger.i('Health check completed: ${success.data.isHealthy ? 'Healthy' : 'Unhealthy'}');
        break;

      case Error<AssistantHealthDomain> error:
        // Create a simple error health status
        final errorHealth = AssistantHealthDomain(
          status: 'error',
          timestamp: DateTime.now().toIso8601String(),
          version: 'unknown',
          uptime: 0.0,
        );

        emit(state.copyWith(healthStatus: errorHealth, lastHealthCheck: DateTime.now()));

        _logger.e('Error checking health: ${error.exception.message}');
        break;
    }
  }

  /// Load metrics
  Future<void> loadMetrics() async {
    try {
      _logger.i('Loading assistant metrics');

      // TODO: Implement metrics loading with proper usecase when metrics endpoint is ready

      _logger.i('Metrics loading placeholder - not implemented yet');
    } catch (e) {
      _logger.e('Error loading metrics: $e');
    }
  }

  /// Clear query history (but keep conversation)
  void clearHistory() {
    emit(state.copyWith(queryHistory: [], searchResults: [], searchQuery: null));
  }

  /// Remove a specific query from history
  void removeFromHistory(String queryId) {
    final updatedHistory = state.queryHistory.where((pair) => pair.query.id != queryId).toList();

    emit(state.copyWith(queryHistory: updatedHistory));
  }

  /// Retry a failed query
  Future<void> retryQuery(String queryId) async {
    final pair = state.queryHistory.where((p) => p.query.id == queryId).firstOrNull;

    if (pair != null) {
      await askQuestion(pair.query.question);
    }
  }

  /// Use a suggestion as a query
  Future<void> useSuggestion(String suggestion) async {
    clearSuggestions();
    await askQuestion(suggestion);
  }

  /// Refresh everything (health, metrics, etc.)
  Future<void> refresh() async {
    await Future.wait([checkHealth(), loadMetrics()]);
  }

  /// Show typing indicator
  void showTyping(String text) {
    emit(state.copyWith(status: AssistantStatus.typing, typingText: text));
  }

  /// Hide typing indicator
  void hideTyping() {
    emit(state.copyWith(status: AssistantStatus.initial, typingText: null));
  }

  /// Convert conversation messages to the format expected by the backend
  List<Map<String, String>>? _convertConversationToHistory(List<ConversationMessage> conversation) {
    if (conversation.isEmpty) return null;

    return conversation.map((message) {
      return {'role': message.isUser ? 'user' : 'assistant', 'content': message.content};
    }).toList();
  }
}
