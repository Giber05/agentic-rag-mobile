import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import 'package:equatable/equatable.dart';

import '../../../core/utils/resource.dart';
import '../../../domain/models/assistant_models.dart';
import '../../../domain/usecases/ask_question_usecase.dart';

part 'chat_state.dart';

/// Chat Cubit for handling chat interactions (simplified version using assistant backend)
@injectable
class ChatCubit extends Cubit<ChatState> {
  final AskQuestionUsecase _askQuestionUsecase;
  final Logger _logger;
  final Uuid _uuid = const Uuid();

  ChatCubit(this._askQuestionUsecase, this._logger) : super(const ChatState());

  /// Send a message to the assistant
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    try {
      _logger.i('Sending message: $message');

      // Add user message to state
      final userMessage = AssistantQueryDomain(
        id: _uuid.v4(),
        question: message.trim(),
        timestamp: DateTime.now(),
        status: QueryStatus.completed,
      );

      emit(state.copyWith(status: ChatStatus.processing, messages: [...state.messages, userMessage], isLoading: true));

      // Ask the assistant
      final params = AskQuestionParams(
        question: message.trim(),
        options: const RAGOptionsDomain(citationStyle: 'numbered', maxSources: 5, responseFormat: 'markdown'),
      );

      final result = await _askQuestionUsecase.execute(params);

      switch (result) {
        case Success<AssistantAnswerDomain> success:
          // Create assistant message from answer
          final assistantMessage = AssistantQueryDomain(
            id: success.data.id,
            question: success.data.content,
            timestamp: success.data.timestamp,
            status: QueryStatus.completed,
          );

          emit(
            state.copyWith(
              status: ChatStatus.success,
              messages: [...state.messages, assistantMessage],
              isLoading: false,
            ),
          );
          break;

        case Error<AssistantAnswerDomain> error:
          emit(state.copyWith(status: ChatStatus.error, errorMessage: error.exception.message, isLoading: false));
          break;
      }
    } catch (e) {
      _logger.e('Error sending message: $e');
      emit(state.copyWith(status: ChatStatus.error, errorMessage: 'An unexpected error occurred', isLoading: false));
    }
  }

  /// Clear all messages
  void clearMessages() {
    emit(state.copyWith(status: ChatStatus.initial, messages: [], errorMessage: null));
  }
}
