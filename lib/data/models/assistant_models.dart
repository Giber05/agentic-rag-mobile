import 'package:equatable/equatable.dart';

/// Represents a query to the intelligent assistant
class AssistantQuery extends Equatable {
  final String id;
  final String question;
  final DateTime timestamp;
  final QueryStatus status;
  final Map<String, dynamic>? metadata;

  const AssistantQuery({
    required this.id,
    required this.question,
    required this.timestamp,
    this.status = QueryStatus.pending,
    this.metadata,
  });

  factory AssistantQuery.fromJson(Map<String, dynamic> json) {
    return AssistantQuery(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      status: QueryStatus.fromString(json['status'] ?? 'pending'),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'timestamp': timestamp.toIso8601String(),
      'status': status.value,
      'metadata': metadata,
    };
  }

  AssistantQuery copyWith({
    String? id,
    String? question,
    DateTime? timestamp,
    QueryStatus? status,
    Map<String, dynamic>? metadata,
  }) {
    return AssistantQuery(
      id: id ?? this.id,
      question: question ?? this.question,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [id, question, timestamp, status, metadata];
}

/// Represents the status of a query
enum QueryStatus {
  pending('pending'),
  processing('processing'),
  completed('completed'),
  failed('failed');

  const QueryStatus(this.value);
  final String value;

  static QueryStatus fromString(String value) {
    return QueryStatus.values.firstWhere((status) => status.value == value, orElse: () => QueryStatus.pending);
  }
}

/// Represents an answer from the intelligent assistant
class AssistantAnswer extends Equatable {
  final String id;
  final String queryId;
  final String content;
  final List<KnowledgeSource> sources;
  final DateTime timestamp;
  final ProcessingMetrics? metrics;
  final QualityAssessment? quality;
  final Map<String, dynamic>? metadata;

  const AssistantAnswer({
    required this.id,
    required this.queryId,
    required this.content,
    required this.sources,
    required this.timestamp,
    this.metrics,
    this.quality,
    this.metadata,
  });

  factory AssistantAnswer.fromJson(Map<String, dynamic> json) {
    // Handle the actual API response structure
    final finalResponse = json['final_response'] as Map<String, dynamic>? ?? {};
    final response = finalResponse['response'] as Map<String, dynamic>? ?? {};
    final citations = response['citations'] as List? ?? [];
    final quality = response['quality'] as Map<String, dynamic>?;
    final metadata = response['metadata'] as Map<String, dynamic>? ?? {};

    // Extract stage results for metrics
    final stageResults = json['stage_results'] as Map<String, dynamic>? ?? {};
    final totalDuration = (json['total_duration'] as num?)?.toDouble() ?? 0.0;

    return AssistantAnswer(
      id: json['request_id'] ?? '',
      queryId: json['request_id'] ?? '',
      content: response['content'] ?? '',
      sources: citations.map((citation) => KnowledgeSource.fromApiResponse(citation)).toList(),
      timestamp: DateTime.tryParse(response['generated_at'] ?? '') ?? DateTime.now(),
      metrics: ProcessingMetrics.fromStageResults(
        stageResults,
        totalDuration,
        (json['sources_used'] as num?)?.toInt() ?? 0,
      ),
      quality: quality != null ? QualityAssessment.fromJson(quality) : null,
      metadata: metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'query_id': queryId,
      'content': content,
      'sources': sources.map((s) => s.toJson()).toList(),
      'timestamp': timestamp.toIso8601String(),
      'metrics': metrics?.toJson(),
      'quality': quality?.toJson(),
      'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [id, queryId, content, sources, timestamp, metrics, quality, metadata];
}

/// Represents a knowledge source used in the answer
class KnowledgeSource extends Equatable {
  final String id;
  final String title;
  final String excerpt;
  final String? url;
  final double relevanceScore;
  final SourceType type;
  final Map<String, dynamic>? metadata;

  const KnowledgeSource({
    required this.id,
    required this.title,
    required this.excerpt,
    this.url,
    required this.relevanceScore,
    this.type = SourceType.document,
    this.metadata,
  });

  factory KnowledgeSource.fromJson(Map<String, dynamic> json) {
    return KnowledgeSource(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      url: json['url'],
      excerpt: json['excerpt'] ?? '',
      relevanceScore: (json['relevance_score'] as num?)?.toDouble() ?? 0.0,
      metadata: json['metadata'] ?? {},
    );
  }

  /// Factory constructor for API response format (citations)
  factory KnowledgeSource.fromApiResponse(Map<String, dynamic> json) {
    return KnowledgeSource(
      id: json['source_id'] ?? json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      url: json['url'],
      excerpt: json['content_snippet'] ?? '',
      relevanceScore: (json['relevance_score'] as num?)?.toDouble() ?? 0.0,
      metadata: json['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'excerpt': excerpt,
      'url': url,
      'relevance_score': relevanceScore,
      'type': type.value,
      'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [id, title, excerpt, url, relevanceScore, type, metadata];
}

/// Types of knowledge sources
enum SourceType {
  document('document'),
  webpage('webpage'),
  database('database'),
  api('api');

  const SourceType(this.value);
  final String value;

  static SourceType fromString(String value) {
    return SourceType.values.firstWhere((type) => type.value == value, orElse: () => SourceType.document);
  }
}

/// Processing metrics for performance tracking
class ProcessingMetrics extends Equatable {
  final double totalTime;
  final double queryRewritingTime;
  final double contextDecisionTime;
  final double sourceRetrievalTime;
  final double answerGenerationTime;
  final int sourcesFound;
  final int tokensUsed;
  final Map<String, dynamic> stageResults;

  const ProcessingMetrics({
    required this.totalTime,
    required this.queryRewritingTime,
    required this.contextDecisionTime,
    required this.sourceRetrievalTime,
    required this.answerGenerationTime,
    required this.sourcesFound,
    required this.tokensUsed,
    required this.stageResults,
  });

  factory ProcessingMetrics.fromJson(Map<String, dynamic> json) {
    return ProcessingMetrics(
      totalTime: (json['total_time'] ?? 0.0).toDouble(),
      queryRewritingTime: (json['query_rewriting_time'] ?? 0.0).toDouble(),
      contextDecisionTime: (json['context_decision_time'] ?? 0.0).toDouble(),
      sourceRetrievalTime: (json['source_retrieval_time'] ?? 0.0).toDouble(),
      answerGenerationTime: (json['answer_generation_time'] ?? 0.0).toDouble(),
      sourcesFound: json['sources_found'] ?? 0,
      tokensUsed: json['tokens_used'] ?? 0,
      stageResults: json['stage_results'] ?? {},
    );
  }

  /// Factory constructor from API stage results
  factory ProcessingMetrics.fromStageResults(Map<String, dynamic> stageResults, double totalTime, int sourcesFound) {
    return ProcessingMetrics(
      totalTime: totalTime,
      queryRewritingTime: _extractDuration(stageResults['query_rewriting']),
      contextDecisionTime: _extractDuration(stageResults['context_decision']),
      sourceRetrievalTime: _extractDuration(stageResults['source_retrieval']),
      answerGenerationTime: _extractDuration(stageResults['answer_generation']),
      sourcesFound: sourcesFound,
      tokensUsed: 0, // Not provided in current API
      stageResults: stageResults,
    );
  }

  static double _extractDuration(dynamic stageData) {
    if (stageData is Map<String, dynamic>) {
      return (stageData['duration'] as num?)?.toDouble() ?? 0.0;
    }
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'total_time': totalTime,
      'query_rewriting_time': queryRewritingTime,
      'context_decision_time': contextDecisionTime,
      'source_retrieval_time': sourceRetrievalTime,
      'answer_generation_time': answerGenerationTime,
      'sources_found': sourcesFound,
      'tokens_used': tokensUsed,
      'stage_results': stageResults,
    };
  }

  @override
  List<Object?> get props => [
    totalTime,
    queryRewritingTime,
    contextDecisionTime,
    sourceRetrievalTime,
    answerGenerationTime,
    sourcesFound,
    tokensUsed,
    stageResults,
  ];
}

/// Quality assessment of the answer
class QualityAssessment extends Equatable {
  final double relevanceScore;
  final double coherenceScore;
  final double completenessScore;
  final double citationAccuracy;
  final double factualAccuracy;
  final double overallScore;

  const QualityAssessment({
    required this.relevanceScore,
    required this.coherenceScore,
    required this.completenessScore,
    required this.citationAccuracy,
    required this.factualAccuracy,
    required this.overallScore,
  });

  factory QualityAssessment.fromJson(Map<String, dynamic> json) {
    return QualityAssessment(
      relevanceScore: (json['relevance_score'] as num?)?.toDouble() ?? 0.0,
      coherenceScore: (json['coherence_score'] as num?)?.toDouble() ?? 0.0,
      completenessScore: (json['completeness_score'] as num?)?.toDouble() ?? 0.0,
      citationAccuracy: (json['citation_accuracy'] as num?)?.toDouble() ?? 0.0,
      factualAccuracy: (json['factual_accuracy'] as num?)?.toDouble() ?? 0.0,
      overallScore: (json['overall_quality'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'relevance_score': relevanceScore,
      'coherence_score': coherenceScore,
      'completeness_score': completenessScore,
      'citation_accuracy': citationAccuracy,
      'factual_accuracy': factualAccuracy,
      'overall_quality': overallScore,
    };
  }

  @override
  List<Object?> get props => [
    relevanceScore,
    coherenceScore,
    completenessScore,
    citationAccuracy,
    factualAccuracy,
    overallScore,
  ];
}

/// Represents a query-answer pair for history
class QueryAnswerPair extends Equatable {
  final AssistantQuery query;
  final AssistantAnswer? answer;

  const QueryAnswerPair({required this.query, this.answer});

  bool get isComplete => answer != null;
  bool get isPending => query.status == QueryStatus.pending || query.status == QueryStatus.processing;
  bool get hasFailed => query.status == QueryStatus.failed;

  @override
  List<Object?> get props => [query, answer];
}

/// Request model for RAG processing
class AssistantRAGRequest extends Equatable {
  final String query;
  final RAGOptions options;
  final List<Map<String, String>>? conversationHistory;

  const AssistantRAGRequest({required this.query, required this.options, this.conversationHistory});

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'options': options.toJson(),
      if (conversationHistory != null) 'conversation_history': conversationHistory,
    };
  }

  @override
  List<Object?> get props => [query, options, conversationHistory];
}

/// RAG options for the assistant
class RAGOptions extends Equatable {
  final String citationStyle;
  final int maxSources;
  final String responseFormat;
  final bool enableStreaming;

  const RAGOptions({
    this.citationStyle = 'numbered',
    this.maxSources = 5,
    this.responseFormat = 'markdown',
    this.enableStreaming = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'citation_style': citationStyle,
      'max_sources': maxSources,
      'response_format': responseFormat,
      'enable_streaming': enableStreaming,
    };
  }

  @override
  List<Object?> get props => [citationStyle, maxSources, responseFormat, enableStreaming];
}
