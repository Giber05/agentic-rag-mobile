part of 'chat_cubit.dart';

/// Chat status enumeration
enum ChatStatus { initial, processing, success, error }

/// Simplified chat state using domain models
class ChatState extends Equatable {
  final ChatStatus status;
  final List<AssistantQueryDomain> messages;
  final bool isLoading;
  final String? errorMessage;

  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  /// Create a copy of the state with updated values
  ChatState copyWith({
    ChatStatus? status,
    List<AssistantQueryDomain>? messages,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, messages, isLoading, errorMessage];
}
