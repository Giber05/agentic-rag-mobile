import 'package:equatable/equatable.dart';

// Base API Response
class ApiResponse<T> extends Equatable {
  final bool success;
  final String? message;
  final T? data;
  final String? error;

  const ApiResponse({required this.success, this.message, this.data, this.error});

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic)? fromJsonT) {
    return ApiResponse<T>(
      success: json['success'] ?? true,
      message: json['message'],
      data: fromJsonT != null && json['data'] != null ? fromJsonT(json['data']) : json['data'],
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson(Object? Function(T)? toJsonT) {
    return {
      'success': success,
      if (message != null) 'message': message,
      if (data != null) 'data': toJsonT != null ? toJsonT(data as T) : data,
      if (error != null) 'error': error,
    };
  }

  @override
  List<Object?> get props => [success, message, data, error];
}

// Health Check Response
class HealthResponse extends Equatable {
  final String status;
  final String version;
  final DateTime timestamp;
  final Map<String, dynamic>? details;

  const HealthResponse({required this.status, required this.version, required this.timestamp, this.details});

  factory HealthResponse.fromJson(Map<String, dynamic> json) {
    return HealthResponse(
      status: json['status'] ?? 'unknown',
      version: json['version'] ?? '1.0.0',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      details: json['details'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'version': version,
      'timestamp': timestamp.toIso8601String(),
      if (details != null) 'details': details,
    };
  }

  @override
  List<Object?> get props => [status, version, timestamp, details];
}

// RAG Pipeline Request
class RagRequest extends Equatable {
  final String query;
  final String? conversationId;
  final Map<String, dynamic>? context;
  final RagSettings? settings;

  const RagRequest({required this.query, this.conversationId, this.context, this.settings});

  factory RagRequest.fromJson(Map<String, dynamic> json) {
    return RagRequest(
      query: json['query'] ?? '',
      conversationId: json['conversation_id'],
      context: json['context'],
      settings: json['settings'] != null ? RagSettings.fromJson(json['settings']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      if (conversationId != null) 'conversation_id': conversationId,
      if (context != null) 'context': context,
      if (settings != null) 'settings': settings!.toJson(),
    };
  }

  @override
  List<Object?> get props => [query, conversationId, context, settings];
}

// RAG Pipeline Response
class RagResponse extends Equatable {
  final String answer;
  final List<SourceCitation> sources;
  final AgentExecution agentExecution;
  final String? conversationId;
  final Map<String, dynamic>? metadata;

  const RagResponse({
    required this.answer,
    required this.sources,
    required this.agentExecution,
    this.conversationId,
    this.metadata,
  });

  factory RagResponse.fromJson(Map<String, dynamic> json) {
    return RagResponse(
      answer: json['answer'] ?? '',
      sources: (json['sources'] as List<dynamic>?)?.map((e) => SourceCitation.fromJson(e)).toList() ?? [],
      agentExecution: AgentExecution.fromJson(json['agent_execution'] ?? {}),
      conversationId: json['conversation_id'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'answer': answer,
      'sources': sources.map((e) => e.toJson()).toList(),
      'agent_execution': agentExecution.toJson(),
      if (conversationId != null) 'conversation_id': conversationId,
      if (metadata != null) 'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [answer, sources, agentExecution, conversationId, metadata];
}

// Source Citation
class SourceCitation extends Equatable {
  final String id;
  final String title;
  final String content;
  final String? url;
  final double relevanceScore;
  final Map<String, dynamic>? metadata;

  const SourceCitation({
    required this.id,
    required this.title,
    required this.content,
    this.url,
    required this.relevanceScore,
    this.metadata,
  });

  factory SourceCitation.fromJson(Map<String, dynamic> json) {
    return SourceCitation(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      url: json['url'],
      relevanceScore: (json['relevance_score'] ?? 0.0).toDouble(),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      if (url != null) 'url': url,
      'relevance_score': relevanceScore,
      if (metadata != null) 'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [id, title, content, url, relevanceScore, metadata];
}

// Agent Execution Details
class AgentExecution extends Equatable {
  final List<AgentStep> steps;
  final Duration totalDuration;
  final Map<String, dynamic>? metrics;

  const AgentExecution({required this.steps, required this.totalDuration, this.metrics});

  factory AgentExecution.fromJson(Map<String, dynamic> json) {
    return AgentExecution(
      steps: (json['steps'] as List<dynamic>?)?.map((e) => AgentStep.fromJson(e)).toList() ?? [],
      totalDuration: Duration(milliseconds: (json['total_duration_ms'] ?? 0).toInt()),
      metrics: json['metrics'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'steps': steps.map((e) => e.toJson()).toList(),
      'total_duration_ms': totalDuration.inMilliseconds,
      if (metrics != null) 'metrics': metrics,
    };
  }

  @override
  List<Object?> get props => [steps, totalDuration, metrics];
}

// Individual Agent Step
class AgentStep extends Equatable {
  final String agentName;
  final String status;
  final Duration duration;
  final String? input;
  final String? output;
  final String? error;

  const AgentStep({
    required this.agentName,
    required this.status,
    required this.duration,
    this.input,
    this.output,
    this.error,
  });

  factory AgentStep.fromJson(Map<String, dynamic> json) {
    return AgentStep(
      agentName: json['agent_name'] ?? '',
      status: json['status'] ?? 'unknown',
      duration: Duration(milliseconds: (json['duration_ms'] ?? 0).toInt()),
      input: json['input'],
      output: json['output'],
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agent_name': agentName,
      'status': status,
      'duration_ms': duration.inMilliseconds,
      if (input != null) 'input': input,
      if (output != null) 'output': output,
      if (error != null) 'error': error,
    };
  }

  @override
  List<Object?> get props => [agentName, status, duration, input, output, error];
}

// RAG Settings
class RagSettings extends Equatable {
  final int maxSources;
  final double relevanceThreshold;
  final bool enableValidation;
  final Map<String, dynamic>? agentConfig;

  const RagSettings({
    this.maxSources = 5,
    this.relevanceThreshold = 0.7,
    this.enableValidation = true,
    this.agentConfig,
  });

  factory RagSettings.fromJson(Map<String, dynamic> json) {
    return RagSettings(
      maxSources: json['max_sources'] ?? 5,
      relevanceThreshold: (json['relevance_threshold'] ?? 0.7).toDouble(),
      enableValidation: json['enable_validation'] ?? true,
      agentConfig: json['agent_config'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'max_sources': maxSources,
      'relevance_threshold': relevanceThreshold,
      'enable_validation': enableValidation,
      if (agentConfig != null) 'agent_config': agentConfig,
    };
  }

  @override
  List<Object?> get props => [maxSources, relevanceThreshold, enableValidation, agentConfig];
}

// Conversation API Models
class ConversationRequest extends Equatable {
  final String? title;
  final Map<String, dynamic>? metadata;

  const ConversationRequest({this.title, this.metadata});

  factory ConversationRequest.fromJson(Map<String, dynamic> json) {
    return ConversationRequest(title: json['title'], metadata: json['metadata']);
  }

  Map<String, dynamic> toJson() {
    return {if (title != null) 'title': title, if (metadata != null) 'metadata': metadata};
  }

  @override
  List<Object?> get props => [title, metadata];
}

// Document Upload Request
class DocumentUploadRequest extends Equatable {
  final String filename;
  final String content;
  final String contentType;
  final Map<String, dynamic>? metadata;

  const DocumentUploadRequest({
    required this.filename,
    required this.content,
    required this.contentType,
    this.metadata,
  });

  factory DocumentUploadRequest.fromJson(Map<String, dynamic> json) {
    return DocumentUploadRequest(
      filename: json['filename'] ?? '',
      content: json['content'] ?? '',
      contentType: json['content_type'] ?? 'text/plain',
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filename': filename,
      'content': content,
      'content_type': contentType,
      if (metadata != null) 'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [filename, content, contentType, metadata];
}
