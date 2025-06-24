import 'package:equatable/equatable.dart';

/// DTO for API response from RAG process endpoint
class AssistantAnswerDto extends Equatable {
  final String requestId;
  final String query;
  final String status;
  final FinalResponseDto finalResponse;
  final Map<String, dynamic> stageResults;
  final double totalDuration;

  const AssistantAnswerDto({
    required this.requestId,
    required this.query,
    required this.status,
    required this.finalResponse,
    required this.stageResults,
    required this.totalDuration,
  });

  factory AssistantAnswerDto.fromJson(Map<String, dynamic> json) {
    return AssistantAnswerDto(
      requestId: json['request_id'] ?? '',
      query: json['query'] ?? '',
      status: json['status'] ?? '',
      finalResponse: FinalResponseDto.fromJson(json['final_response'] ?? {}),
      stageResults: json['stage_results'] ?? {},
      totalDuration: (json['total_duration'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [requestId, query, status, finalResponse, stageResults, totalDuration];
}

/// DTO for final response structure
class FinalResponseDto extends Equatable {
  final String query;
  final ResponseDto response;

  const FinalResponseDto({required this.query, required this.response});

  factory FinalResponseDto.fromJson(Map<String, dynamic> json) {
    return FinalResponseDto(query: json['query'] ?? '', response: ResponseDto.fromJson(json['response'] ?? {}));
  }

  @override
  List<Object?> get props => [query, response];
}

/// DTO for response structure
class ResponseDto extends Equatable {
  final String content;
  final List<CitationDto> citations;
  final QualityDto? quality;
  final Map<String, dynamic> metadata;

  const ResponseDto({required this.content, required this.citations, this.quality, required this.metadata});

  factory ResponseDto.fromJson(Map<String, dynamic> json) {
    final citationsData = json['citations'] as List? ?? [];
    final qualityData = json['quality'] as Map<String, dynamic>?;

    return ResponseDto(
      content: json['content'] ?? '',
      citations: citationsData.map((c) => CitationDto.fromJson(c)).toList(),
      quality: qualityData != null ? QualityDto.fromJson(qualityData) : null,
      metadata: json['metadata'] ?? {},
    );
  }

  @override
  List<Object?> get props => [content, citations, quality, metadata];
}

/// DTO for citation structure
class CitationDto extends Equatable {
  final int id;
  final String sourceId;
  final String title;
  final String? url;
  final String contentSnippet;
  final double relevanceScore;
  final Map<String, dynamic> metadata;

  const CitationDto({
    required this.id,
    required this.sourceId,
    required this.title,
    this.url,
    required this.contentSnippet,
    required this.relevanceScore,
    required this.metadata,
  });

  factory CitationDto.fromJson(Map<String, dynamic> json) {
    return CitationDto(
      id: json['id'] ?? 0,
      sourceId: json['source_id'] ?? '',
      title: json['title'] ?? '',
      url: json['url'],
      contentSnippet: json['content_snippet'] ?? '',
      relevanceScore: (json['relevance_score'] as num?)?.toDouble() ?? 0.0,
      metadata: json['metadata'] ?? {},
    );
  }

  @override
  List<Object?> get props => [id, sourceId, title, url, contentSnippet, relevanceScore, metadata];
}

/// DTO for quality assessment
class QualityDto extends Equatable {
  final double relevanceScore;
  final double coherenceScore;
  final double completenessScore;
  final double citationAccuracy;
  final double factualAccuracy;
  final double overallQuality;

  const QualityDto({
    required this.relevanceScore,
    required this.coherenceScore,
    required this.completenessScore,
    required this.citationAccuracy,
    required this.factualAccuracy,
    required this.overallQuality,
  });

  factory QualityDto.fromJson(Map<String, dynamic> json) {
    return QualityDto(
      relevanceScore: (json['relevance_score'] as num?)?.toDouble() ?? 0.0,
      coherenceScore: (json['coherence_score'] as num?)?.toDouble() ?? 0.0,
      completenessScore: (json['completeness_score'] as num?)?.toDouble() ?? 0.0,
      citationAccuracy: (json['citation_accuracy'] as num?)?.toDouble() ?? 0.0,
      factualAccuracy: (json['factual_accuracy'] as num?)?.toDouble() ?? 0.0,
      overallQuality: (json['overall_quality'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [
    relevanceScore,
    coherenceScore,
    completenessScore,
    citationAccuracy,
    factualAccuracy,
    overallQuality,
  ];
}

/// DTO for RAG request
class RAGRequestDto extends Equatable {
  final String query;
  final RAGOptionsDto options;
  final List<Map<String, String>>? conversationHistory;

  const RAGRequestDto({required this.query, required this.options, this.conversationHistory});

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

/// DTO for RAG options
class RAGOptionsDto extends Equatable {
  final String citationStyle;
  final int maxSources;
  final String responseFormat;
  final bool enableStreaming;

  const RAGOptionsDto({
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
