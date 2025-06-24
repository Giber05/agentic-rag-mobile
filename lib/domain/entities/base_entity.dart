import 'package:equatable/equatable.dart';

abstract class BaseEntity extends Equatable {
  const BaseEntity({required this.id, required this.createdAt, this.updatedAt});

  final String id;
  final DateTime createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [id, createdAt, updatedAt];
}
