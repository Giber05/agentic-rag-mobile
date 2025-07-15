part of 'assistant_cubit.dart';

/// Status of the intelligent assistant
enum AssistantStatus {
  initial,
  processing,
  success,
  error,
  searching,
  searchComplete,
  typing, // Added for typing indicator animation
}

/// Individual conversation message
class ConversationMessage extends Equatable {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final QueryStatus? status;
  final AssistantAnswerDomain? answer; // For AI responses with sources
  final bool isTyping;

  const ConversationMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.status,
    this.answer,
    this.isTyping = false,
  });

  ConversationMessage copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    QueryStatus? status,
    AssistantAnswerDomain? answer,
    bool? isTyping,
  }) {
    return ConversationMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      answer: answer ?? this.answer,
      isTyping: isTyping ?? this.isTyping,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp,
    };
  }

  @override
  List<Object?> get props => [id, content, isUser, timestamp, status, answer, isTyping];
}

/// State for the intelligent assistant
class AssistantState extends Equatable {
  final AssistantStatus status;
  final AssistantQueryDomain? currentQuery;
  final AssistantAnswerDomain? currentAnswer;
  final List<QueryAnswerPairDomain> queryHistory;
  final List<ConversationMessage> conversation; // New conversation flow
  final List<KnowledgeSourceDomain> searchResults;
  final String? searchQuery;
  final List<String> suggestions;
  final String? errorMessage;
  final AssistantHealthDomain? healthStatus;
  final AssistantMetricsDomain? metrics;
  final DateTime? lastHealthCheck;
  final String? typingText; // For typing animation
  final String? selectedMode; // Current selected tool mode

  const AssistantState({
    this.status = AssistantStatus.initial,
    this.currentQuery,
    this.currentAnswer,
    this.queryHistory = const [],
    this.conversation = const [],
    this.searchResults = const [],
    this.searchQuery,
    this.suggestions = const [],
    this.errorMessage,
    this.healthStatus,
    this.metrics,
    this.lastHealthCheck,
    this.typingText,
    this.selectedMode,
  });

  /// Copy with method for creating new states
  AssistantState copyWith({
    AssistantStatus? status,
    AssistantQueryDomain? currentQuery,
    AssistantAnswerDomain? currentAnswer,
    List<QueryAnswerPairDomain>? queryHistory,
    List<ConversationMessage>? conversation,
    List<KnowledgeSourceDomain>? searchResults,
    String? searchQuery,
    List<String>? suggestions,
    String? errorMessage,
    AssistantHealthDomain? healthStatus,
    AssistantMetricsDomain? metrics,
    DateTime? lastHealthCheck,
    String? typingText,
    String? selectedMode,
  }) {
    return AssistantState(
      status: status ?? this.status,
      currentQuery: currentQuery ?? this.currentQuery,
      currentAnswer: currentAnswer ?? this.currentAnswer,
      queryHistory: queryHistory ?? this.queryHistory,
      conversation: conversation ?? this.conversation,
      searchResults: searchResults ?? this.searchResults,
      searchQuery: searchQuery ?? this.searchQuery,
      suggestions: suggestions ?? this.suggestions,
      errorMessage: errorMessage ?? this.errorMessage,
      healthStatus: healthStatus ?? this.healthStatus,
      metrics: metrics ?? this.metrics,
      lastHealthCheck: lastHealthCheck ?? this.lastHealthCheck,
      typingText: typingText ?? this.typingText,
      selectedMode: selectedMode ?? this.selectedMode,
    );
  }

  /// Getters for convenience
  bool get isProcessing => status == AssistantStatus.processing;
  bool get isSearching => status == AssistantStatus.searching;
  bool get isTyping => status == AssistantStatus.typing;
  bool get hasError => status == AssistantStatus.error;
  bool get hasCurrentAnswer => currentAnswer != null;
  bool get hasHistory => queryHistory.isNotEmpty;
  bool get hasConversation => conversation.isNotEmpty;
  bool get hasSearchResults => searchResults.isNotEmpty;
  bool get hasSuggestions => suggestions.isNotEmpty;
  bool get isHealthy => healthStatus?.isHealthy ?? false;

  @override
  List<Object?> get props => [
    status,
    currentQuery,
    currentAnswer,
    queryHistory,
    conversation,
    searchResults,
    searchQuery,
    suggestions,
    errorMessage,
    healthStatus,
    metrics,
    lastHealthCheck,
    typingText,
    selectedMode,
  ];
}
