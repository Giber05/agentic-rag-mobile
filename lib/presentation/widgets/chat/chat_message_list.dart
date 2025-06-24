import 'package:flutter/material.dart';

import '../../../data/models/chat_models.dart';
import 'chat_message_bubble.dart';
import 'typing_indicator.dart';

/// Widget for displaying a list of chat messages
class ChatMessageList extends StatelessWidget {
  final List<ChatMessage> messages;
  final ScrollController scrollController;
  final bool isLoading;
  final bool isStreaming;

  const ChatMessageList({
    super.key,
    required this.messages,
    required this.scrollController,
    this.isLoading = false,
    this.isStreaming = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length + (isStreaming ? 1 : 0),
      itemBuilder: (context, index) {
        // Show typing indicator if streaming and at the end
        if (index == messages.length && isStreaming) {
          return const Padding(padding: EdgeInsets.only(top: 8), child: TypingIndicator());
        }

        final message = messages[index];
        final isLastMessage = index == messages.length - 1;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ChatMessageBubble(
            message: message,
            isLastMessage: isLastMessage,
            isStreaming: isStreaming && isLastMessage && message.role == MessageRole.assistant,
          ),
        );
      },
    );
  }
}
