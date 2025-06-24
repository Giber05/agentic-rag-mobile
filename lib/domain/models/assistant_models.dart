import 'package:equatable/equatable.dart';

/// Domain model for assistant query
class AssistantQueryDomain extends Equatable {
  final String id;
  final String question;
  final DateTime timestamp;
  final QueryStatus status;
  final Map<String, dynamic>? metadata;

  const AssistantQueryDomain({
    required this.id,
    required this.question,
    required this.timestamp,
    this.status = QueryStatus.pending,
    this.metadata,
  });

  AssistantQueryDomain copyWith({
    String? id,
    String? question,
    DateTime? timestamp,
    QueryStatus? status,
    Map<String, dynamic>? metadata,
  }) {
    return AssistantQueryDomain(
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

/// Domain model for assistant answer
class AssistantAnswerDomain extends Equatable {
  final String id;
  final String queryId;
  final String content;
  final List<KnowledgeSourceDomain> sources;
  final DateTime timestamp;
  final ProcessingMetricsDomain? metrics;
  final QualityAssessmentDomain? quality;
  final Map<String, dynamic>? metadata;

  const AssistantAnswerDomain({
    required this.id,
    required this.queryId,
    required this.content,
    required this.sources,
    required this.timestamp,
    this.metrics,
    this.quality,
    this.metadata,
  });

  @override
  List<Object?> get props => [id, queryId, content, sources, timestamp, metrics, quality, metadata];
}

/// Domain model for knowledge source
class KnowledgeSourceDomain extends Equatable {
  final String id;
  final String title;
  final String excerpt;
  final String? url;
  final double relevanceScore;
  final SourceType type;
  final Map<String, dynamic>? metadata;

  const KnowledgeSourceDomain({
    required this.id,
    required this.title,
    required this.excerpt,
    this.url,
    required this.relevanceScore,
    this.type = SourceType.document,
    this.metadata,
  });

  @override
  List<Object?> get props => [id, title, excerpt, url, relevanceScore, type, metadata];
}

/// Domain model for processing metrics
class ProcessingMetricsDomain extends Equatable {
  final double totalTime;
  final double queryRewritingTime;
  final double contextDecisionTime;
  final double sourceRetrievalTime;
  final double answerGenerationTime;
  final int sourcesFound;
  final int tokensUsed;
  final Map<String, dynamic> stageResults;

  const ProcessingMetricsDomain({
    required this.totalTime,
    required this.queryRewritingTime,
    required this.contextDecisionTime,
    required this.sourceRetrievalTime,
    required this.answerGenerationTime,
    required this.sourcesFound,
    required this.tokensUsed,
    required this.stageResults,
  });

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

/// Domain model for quality assessment
class QualityAssessmentDomain extends Equatable {
  final double relevanceScore;
  final double coherenceScore;
  final double completenessScore;
  final double citationAccuracy;
  final double factualAccuracy;
  final double overallScore;

  const QualityAssessmentDomain({
    required this.relevanceScore,
    required this.coherenceScore,
    required this.completenessScore,
    required this.citationAccuracy,
    required this.factualAccuracy,
    required this.overallScore,
  });

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

/// Query status enum
enum QueryStatus { pending, processing, completed, failed }

/// Source type enum
enum SourceType { document, webpage, database, api }

/// Domain model for query-answer pair
class QueryAnswerPairDomain extends Equatable {
  final AssistantQueryDomain query;
  final AssistantAnswerDomain? answer;

  const QueryAnswerPairDomain({required this.query, this.answer});

  bool get isComplete => answer != null;
  bool get isPending => query.status == QueryStatus.pending || query.status == QueryStatus.processing;
  bool get hasFailed => query.status == QueryStatus.failed;

  @override
  List<Object?> get props => [query, answer];
}

/// Domain model for RAG options
class RAGOptionsDomain extends Equatable {
  final String citationStyle;
  final int maxSources;
  final String responseFormat;
  final bool enableStreaming;

  const RAGOptionsDomain({
    this.citationStyle = 'numbered',
    this.maxSources = 5,
    this.responseFormat = 'markdown',
    this.enableStreaming = false,
  });

  @override
  List<Object?> get props => [citationStyle, maxSources, responseFormat, enableStreaming];
}

/// Domain model for assistant health status
class AssistantHealthDomain extends Equatable {
  final String status;
  final String timestamp;
  final String version;
  final double uptime;

  const AssistantHealthDomain({
    required this.status,
    required this.timestamp,
    required this.version,
    required this.uptime,
  });

  /// Helper getter to check if the system is healthy
  bool get isHealthy => status == 'healthy';

  /// Parse timestamp string to DateTime
  DateTime get timestampAsDateTime => DateTime.parse(timestamp);

  @override
  List<Object?> get props => [status, timestamp, version, uptime];
}

/// Domain model for assistant metrics
class AssistantMetricsDomain extends Equatable {
  final int totalQueries;
  final double averageResponseTime;
  final double successRate;
  final Map<String, double> agentPerformance;
  final DateTime timestamp;

  const AssistantMetricsDomain({
    required this.totalQueries,
    required this.averageResponseTime,
    required this.successRate,
    required this.agentPerformance,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [totalQueries, averageResponseTime, successRate, agentPerformance, timestamp];
}
