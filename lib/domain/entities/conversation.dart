import 'base_entity.dart';
import 'message.dart';

class Conversation extends BaseEntity {
  const Conversation({
    required super.id,
    required super.createdAt,
    super.updatedAt,
    required this.title,
    this.userId,
    this.metadata,
    this.messages,
  });

  final String title;
  final String? userId;
  final Map<String, dynamic>? metadata;
  final List<Message>? messages;

  @override
  List<Object?> get props => [...super.props, title, userId, metadata, messages];

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      title: json['title'] ?? '',
      userId: json['user_id'],
      metadata: json['metadata'],
      messages:
          json['messages'] != null
              ? (json['messages'] as List<dynamic>).map((e) => Message.fromJson(e)).toList()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      'title': title,
      if (userId != null) 'user_id': userId,
      if (metadata != null) 'metadata': metadata,
      if (messages != null) 'messages': messages!.map((e) => e.toJson()).toList(),
    };
  }

  Conversation copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? title,
    String? userId,
    Map<String, dynamic>? metadata,
    List<Message>? messages,
  }) {
    return Conversation(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      title: title ?? this.title,
      userId: userId ?? this.userId,
      metadata: metadata ?? this.metadata,
      messages: messages ?? this.messages,
    );
  }
}
