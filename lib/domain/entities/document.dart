import 'base_entity.dart';

class Document extends BaseEntity {
  const Document({
    required super.id,
    required super.createdAt,
    super.updatedAt,
    required this.title,
    required this.content,
    this.fileType,
    this.fileSize,
    this.metadata,
  });

  final String title;
  final String content;
  final String? fileType;
  final int? fileSize;
  final Map<String, dynamic>? metadata;

  @override
  List<Object?> get props => [...super.props, title, content, fileType, fileSize, metadata];

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      fileType: json['file_type'],
      fileSize: json['file_size'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      'title': title,
      'content': content,
      if (fileType != null) 'file_type': fileType,
      if (fileSize != null) 'file_size': fileSize,
      if (metadata != null) 'metadata': metadata,
    };
  }

  Document copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? title,
    String? content,
    String? fileType,
    int? fileSize,
    Map<String, dynamic>? metadata,
  }) {
    return Document(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      title: title ?? this.title,
      content: content ?? this.content,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      metadata: metadata ?? this.metadata,
    );
  }
}
