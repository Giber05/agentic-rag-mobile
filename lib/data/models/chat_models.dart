import 'package:equatable/equatable.dart';

/// Represents a chat message in the conversation
class ChatMessage extends Equatable {
  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final MessageStatus status;
  final List<SourceCitation>? citations;
  final Map<String, dynamic>? metadata;
  final String? requestId;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.citations,
    this.metadata,
    this.requestId,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      role: MessageRole.fromString(json['role'] ?? 'user'),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      status: MessageStatus.fromString(json['status'] ?? 'sent'),
      citations:
          json['citations'] != null
              ? (json['citations'] as List).map((c) => SourceCitation.fromJson(c)).toList()
              : null,
      metadata: json['metadata'],
      requestId: json['request_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'role': role.value,
      'timestamp': timestamp.toIso8601String(),
      'status': status.value,
      'citations': citations?.map((c) => c.toJson()).toList(),
      'metadata': metadata,
      'request_id': requestId,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? content,
    MessageRole? role,
    DateTime? timestamp,
    MessageStatus? status,
    List<SourceCitation>? citations,
    Map<String, dynamic>? metadata,
    String? requestId,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      citations: citations ?? this.citations,
      metadata: metadata ?? this.metadata,
      requestId: requestId ?? this.requestId,
    );
  }

  @override
  List<Object?> get props => [id, content, role, timestamp, status, citations, metadata, requestId];
}

/// Represents the role of a message sender
enum MessageRole {
  user('user'),
  assistant('assistant'),
  system('system');

  const MessageRole(this.value);
  final String value;

  static MessageRole fromString(String value) {
    return MessageRole.values.firstWhere((role) => role.value == value, orElse: () => MessageRole.user);
  }
}

/// Represents the status of a message
enum MessageStatus {
  sending('sending'),
  sent('sent'),
  delivered('delivered'),
  failed('failed'),
  processing('processing');

  const MessageStatus(this.value);
  final String value;

  static MessageStatus fromString(String value) {
    return MessageStatus.values.firstWhere((status) => status.value == value, orElse: () => MessageStatus.sent);
  }
}

/// Represents a source citation in the response
class SourceCitation extends Equatable {
  final int id;
  final String title;
  final String? url;
  final String? content;
  final double? relevanceScore;
  final Map<String, dynamic>? metadata;

  const SourceCitation({
    required this.id,
    required this.title,
    this.url,
    this.content,
    this.relevanceScore,
    this.metadata,
  });

  factory SourceCitation.fromJson(Map<String, dynamic> json) {
    return SourceCitation(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      url: json['url'],
      content: json['content'],
      relevanceScore: json['relevance_score']?.toDouble(),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'content': content,
      'relevance_score': relevanceScore,
      'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [id, title, url, content, relevanceScore, metadata];
}

/// Represents a conversation
class Conversation extends Equatable {
  final String id;
  final String title;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  const Conversation({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      messages: json['messages'] != null ? (json['messages'] as List).map((m) => ChatMessage.fromJson(m)).toList() : [],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'messages': messages.map((m) => m.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  Conversation copyWith({
    String? id,
    String? title,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [id, title, messages, createdAt, updatedAt, metadata];
}

/// RAG Pipeline request model
class RAGProcessRequest extends Equatable {
  final String query;
  final List<Map<String, String>>? conversationHistory;
  final RAGProcessOptions? options;

  const RAGProcessRequest({required this.query, this.conversationHistory, this.options});

  Map<String, dynamic> toJson() {
    return {'query': query, 'conversation_history': conversationHistory, 'options': options?.toJson()};
  }

  @override
  List<Object?> get props => [query, conversationHistory, options];
}

/// RAG Pipeline options
class RAGProcessOptions extends Equatable {
  final bool enableStreaming;
  final String citationStyle;
  final int maxSources;
  final String? responseFormat;

  const RAGProcessOptions({
    this.enableStreaming = false,
    this.citationStyle = 'numbered',
    this.maxSources = 5,
    this.responseFormat,
  });

  Map<String, dynamic> toJson() {
    return {
      'enable_streaming': enableStreaming,
      'citation_style': citationStyle,
      'max_sources': maxSources,
      'response_format': responseFormat,
    };
  }

  @override
  List<Object?> get props => [enableStreaming, citationStyle, maxSources, responseFormat];
}

/// RAG Pipeline response model
class RAGProcessResponse extends Equatable {
  final bool success;
  final RAGResponseData? data;
  final String? message;
  final String? requestId;
  final DateTime? timestamp;
  final String? error;

  const RAGProcessResponse({
    required this.success,
    this.data,
    this.message,
    this.requestId,
    this.timestamp,
    this.error,
  });

  factory RAGProcessResponse.fromJson(Map<String, dynamic> json) {
    return RAGProcessResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? RAGResponseData.fromJson(json['data']) : null,
      message: json['message'],
      requestId: json['request_id'],
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : null,
      error: json['error'],
    );
  }

  @override
  List<Object?> get props => [success, data, message, requestId, timestamp, error];
}

/// RAG Response data
class RAGResponseData extends Equatable {
  final String answer;
  final List<SourceCitation> sources;
  final Map<String, PipelineStage>? pipelineStages;
  final double? totalProcessingTime;
  final QualityMetrics? qualityMetrics;

  const RAGResponseData({
    required this.answer,
    required this.sources,
    this.pipelineStages,
    this.totalProcessingTime,
    this.qualityMetrics,
  });

  factory RAGResponseData.fromJson(Map<String, dynamic> json) {
    return RAGResponseData(
      answer: json['answer'] ?? '',
      sources: json['sources'] != null ? (json['sources'] as List).map((s) => SourceCitation.fromJson(s)).toList() : [],
      pipelineStages:
          json['pipeline_stages'] != null
              ? (json['pipeline_stages'] as Map<String, dynamic>).map(
                (key, value) => MapEntry(key, PipelineStage.fromJson(value)),
              )
              : null,
      totalProcessingTime: json['total_processing_time']?.toDouble(),
      qualityMetrics: json['quality_metrics'] != null ? QualityMetrics.fromJson(json['quality_metrics']) : null,
    );
  }

  @override
  List<Object?> get props => [answer, sources, pipelineStages, totalProcessingTime, qualityMetrics];
}

/// Pipeline stage information
class PipelineStage extends Equatable {
  final String status;
  final double time;

  const PipelineStage({required this.status, required this.time});

  factory PipelineStage.fromJson(Map<String, dynamic> json) {
    return PipelineStage(status: json['status'] ?? '', time: json['time']?.toDouble() ?? 0.0);
  }

  @override
  List<Object?> get props => [status, time];
}

/// Quality metrics for responses
class QualityMetrics extends Equatable {
  final double relevance;
  final double completeness;
  final double accuracy;
  final double? clarity;
  final double? coherence;

  const QualityMetrics({
    required this.relevance,
    required this.completeness,
    required this.accuracy,
    this.clarity,
    this.coherence,
  });

  factory QualityMetrics.fromJson(Map<String, dynamic> json) {
    return QualityMetrics(
      relevance: json['relevance']?.toDouble() ?? 0.0,
      completeness: json['completeness']?.toDouble() ?? 0.0,
      accuracy: json['accuracy']?.toDouble() ?? 0.0,
      clarity: json['clarity']?.toDouble(),
      coherence: json['coherence']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'relevance': relevance,
      'completeness': completeness,
      'accuracy': accuracy,
      'clarity': clarity,
      'coherence': coherence,
    };
  }

  @override
  List<Object?> get props => [relevance, completeness, accuracy, clarity, coherence];
}

/// WebSocket message types for streaming
enum StreamMessageType {
  stageUpdate('stage_update'),
  partialResponse('partial_response'),
  finalResponse('final_response'),
  error('error');

  const StreamMessageType(this.value);
  final String value;

  static StreamMessageType fromString(String value) {
    return StreamMessageType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => StreamMessageType.stageUpdate,
    );
  }
}

/// WebSocket stream message
class StreamMessage extends Equatable {
  final StreamMessageType type;
  final String? stage;
  final String? status;
  final Map<String, dynamic>? data;
  final String? content;
  final String? error;

  const StreamMessage({required this.type, this.stage, this.status, this.data, this.content, this.error});

  factory StreamMessage.fromJson(Map<String, dynamic> json) {
    return StreamMessage(
      type: StreamMessageType.fromString(json['type'] ?? ''),
      stage: json['stage'],
      status: json['status'],
      data: json['data'],
      content: json['content'],
      error: json['error'],
    );
  }

  @override
  List<Object?> get props => [type, stage, status, data, content, error];
}
