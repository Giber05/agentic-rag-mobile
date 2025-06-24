import 'package:uuid/uuid.dart';

import '../dto/assistant_dto.dart';
import '../../domain/models/assistant_models.dart';

/// Mapper class to convert DTOs to domain models
class AssistantMapper {
  static const _uuid = Uuid();

  /// Convert AssistantAnswerDto to AssistantAnswerDomain
  static AssistantAnswerDomain toDomain(AssistantAnswerDto dto) {
    return AssistantAnswerDomain(
      id: dto.requestId,
      queryId: dto.requestId,
      content: dto.finalResponse.response.content,
      sources: dto.finalResponse.response.citations.map((citation) => _citationToDomain(citation)).toList(),
      timestamp: DateTime.now(),
      metrics: _metricsFromStageResults(dto.stageResults, dto.totalDuration),
      quality:
          dto.finalResponse.response.quality != null ? _qualityToDomain(dto.finalResponse.response.quality!) : null,
      metadata: {
        'original_query': dto.query,
        'processed_query': dto.finalResponse.query,
        'stage_results': dto.stageResults,
      },
    );
  }

  /// Convert CitationDto to KnowledgeSourceDomain
  static KnowledgeSourceDomain _citationToDomain(CitationDto citation) {
    return KnowledgeSourceDomain(
      id: citation.sourceId.isNotEmpty ? citation.sourceId : citation.id.toString(),
      title: citation.title,
      excerpt: citation.contentSnippet,
      url: citation.url,
      relevanceScore: citation.relevanceScore,
      type: SourceType.document,
      metadata: citation.metadata,
    );
  }

  /// Convert QualityDto to QualityAssessmentDomain
  static QualityAssessmentDomain _qualityToDomain(QualityDto quality) {
    return QualityAssessmentDomain(
      relevanceScore: quality.relevanceScore,
      coherenceScore: quality.coherenceScore,
      completenessScore: quality.completenessScore,
      citationAccuracy: quality.citationAccuracy,
      factualAccuracy: quality.factualAccuracy,
      overallScore: quality.overallQuality,
    );
  }

  /// Extract metrics from stage results
  static ProcessingMetricsDomain _metricsFromStageResults(Map<String, dynamic> stageResults, double totalDuration) {
    double getStageTime(String stageKey) {
      final stage = stageResults[stageKey] as Map<String, dynamic>?;
      return (stage?['execution_time'] as num?)?.toDouble() ?? 0.0;
    }

    return ProcessingMetricsDomain(
      totalTime: totalDuration,
      queryRewritingTime: getStageTime('query_rewriting'),
      contextDecisionTime: getStageTime('context_decision'),
      sourceRetrievalTime: getStageTime('source_retrieval'),
      answerGenerationTime: getStageTime('answer_generation'),
      sourcesFound: (stageResults['source_retrieval']?['sources_found'] as num?)?.toInt() ?? 0,
      tokensUsed: (stageResults['answer_generation']?['tokens_used'] as num?)?.toInt() ?? 0,
      stageResults: stageResults,
    );
  }

  /// Convert RAGOptionsDomain to RAGOptionsDto
  static RAGOptionsDto ragOptionsToDto(RAGOptionsDomain domain) {
    return RAGOptionsDto(
      citationStyle: domain.citationStyle,
      maxSources: domain.maxSources,
      responseFormat: domain.responseFormat,
      enableStreaming: domain.enableStreaming,
    );
  }

  /// Convert knowledge search results to domain models
  static List<KnowledgeSourceDomain> searchResultsToDomain(List<Map<String, dynamic>> results) {
    return results.map((result) {
      return KnowledgeSourceDomain(
        id: result['id']?.toString() ?? _uuid.v4(),
        title: result['title'] ?? '',
        excerpt: result['content'] ?? result['snippet'] ?? '',
        url: result['url'],
        relevanceScore: (result['similarity'] as num?)?.toDouble() ?? 0.0,
        type: _parseSourceType(result['type']),
        metadata: result,
      );
    }).toList();
  }

  /// Convert health status to domain model
  static AssistantHealthDomain healthToDomain(Map<String, dynamic> healthData) {
    return AssistantHealthDomain(
      status: healthData['status'] ?? 'unknown',
      timestamp: healthData['timestamp'] ?? DateTime.now().toIso8601String(),
      version: healthData['version'] ?? '1.0.0',
      uptime: (healthData['uptime'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Convert metrics to domain model
  static AssistantMetricsDomain metricsToDomain(Map<String, dynamic> metricsData) {
    final performance = <String, double>{};
    final agentPerf = metricsData['agent_performance'] as Map<String, dynamic>? ?? {};

    agentPerf.forEach((key, value) {
      performance[key] = (value as num?)?.toDouble() ?? 0.0;
    });

    return AssistantMetricsDomain(
      totalQueries: (metricsData['total_queries'] as num?)?.toInt() ?? 0,
      averageResponseTime: (metricsData['avg_response_time'] as num?)?.toDouble() ?? 0.0,
      successRate: (metricsData['success_rate'] as num?)?.toDouble() ?? 0.0,
      agentPerformance: performance,
      timestamp: DateTime.now(),
    );
  }

  /// Parse source type from string
  static SourceType _parseSourceType(dynamic type) {
    if (type is String) {
      switch (type.toLowerCase()) {
        case 'webpage':
        case 'web':
          return SourceType.webpage;
        case 'database':
        case 'db':
          return SourceType.database;
        case 'api':
          return SourceType.api;
        default:
          return SourceType.document;
      }
    }
    return SourceType.document;
  }
}
