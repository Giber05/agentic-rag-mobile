import 'base_entity.dart';

enum MessageRole {
  user,
  assistant,
  system;

  String get value {
    switch (this) {
      case MessageRole.user:
        return 'user';
      case MessageRole.assistant:
        return 'assistant';
      case MessageRole.system:
        return 'system';
    }
  }

  static MessageRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'user':
        return MessageRole.user;
      case 'assistant':
        return MessageRole.assistant;
      case 'system':
        return MessageRole.system;
      default:
        throw ArgumentError('Invalid message role: $value');
    }
  }
}

class Message extends BaseEntity {
  const Message({
    required super.id,
    required super.createdAt,
    super.updatedAt,
    required this.conversationId,
    required this.role,
    required this.content,
    this.metadata,
    this.agentData,
  });

  final String conversationId;
  final MessageRole role;
  final String content;
  final Map<String, dynamic>? metadata;
  final Map<String, dynamic>? agentData;

  @override
  List<Object?> get props => [...super.props, conversationId, role, content, metadata, agentData];

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      conversationId: json['conversation_id'] ?? '',
      role: MessageRole.fromString(json['role'] ?? 'user'),
      content: json['content'] ?? '',
      metadata: json['metadata'],
      agentData: json['agent_data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      'conversation_id': conversationId,
      'role': role.value,
      'content': content,
      if (metadata != null) 'metadata': metadata,
      if (agentData != null) 'agent_data': agentData,
    };
  }

  Message copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? conversationId,
    MessageRole? role,
    String? content,
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? agentData,
  }) {
    return Message(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      metadata: metadata ?? this.metadata,
      agentData: agentData ?? this.agentData,
    );
  }
}
