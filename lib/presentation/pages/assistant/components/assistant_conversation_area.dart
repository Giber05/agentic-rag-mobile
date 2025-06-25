import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cubits/assistant/assistant_cubit.dart';
import '../widgets/conversation_message_widget.dart';
import '../widgets/typing_indicator_widget.dart';
import '../widgets/error_widget.dart';
import 'assistant_welcome_screen.dart';
import 'assistant_options_menu.dart';
import '../../../../core/utils/responsive_utils.dart';

/// Optimized conversation area with fixed scroll behavior
/// Handles message display, scrolling, and state-specific UI
class AssistantConversationArea extends StatefulWidget {
  final ScrollController scrollController;
  final Function(String)? onExampleQuestionTap;

  const AssistantConversationArea({super.key, required this.scrollController, this.onExampleQuestionTap});

  @override
  State<AssistantConversationArea> createState() => _AssistantConversationAreaState();
}

class _AssistantConversationAreaState extends State<AssistantConversationArea> {
  double? _previousScrollPosition;
  int _previousMessageCount = 0;
  bool _isUserScrolling = false;
  bool _shouldAutoScroll = true;

  @override
  void initState() {
    super.initState();
    _setupScrollListener();
  }

  void _setupScrollListener() {
    widget.scrollController.addListener(() {
      if (widget.scrollController.hasClients) {
        final currentPosition = widget.scrollController.position.pixels;
        final maxPosition = widget.scrollController.position.maxScrollExtent;

        // Detect if user is manually scrolling
        if ((currentPosition - (maxPosition - 100)).abs() > 100) {
          _isUserScrolling = true;
          _shouldAutoScroll = false;
        } else {
          _isUserScrolling = false;
          _shouldAutoScroll = true;
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final layout = ResponsiveUtils.getConversationLayout(context);

    return BlocBuilder<AssistantCubit, AssistantState>(
      // Optimize rebuilds: only rebuild when necessary
      buildWhen: (previous, current) {
        // Always rebuild if conversation length changed (new message)
        if (previous.conversation.length != current.conversation.length) {
          return true;
        }

        // Rebuild for status changes that affect UI
        if (previous.status != current.status) {
          return true;
        }

        // Rebuild for error message changes
        if (previous.errorMessage != current.errorMessage) {
          return true;
        }

        // Rebuild for typing text changes
        if (previous.typingText != current.typingText) {
          return true;
        }

        return false;
      },
      builder: (context, state) {
        // Handle scroll position preservation and auto-scroll
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleScrollBehavior(state);
        });

        return Container(
          constraints: BoxConstraints(maxWidth: layout.maxMessageWidth),
          child: CustomScrollView(
            controller: widget.scrollController,
            physics: const BouncingScrollPhysics(),
            // Remove the problematic ValueKey that was causing rebuilds
            slivers: [
              // Welcome message when conversation is empty
              if (state.conversation.isEmpty)
                SliverToBoxAdapter(child: AssistantWelcomeScreen(onExampleQuestionTap: widget.onExampleQuestionTap)),

              // Conversation messages with optimized list building
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final message = state.conversation[index];
                    return ConversationMessageWidget(
                      key: ValueKey(message.id), // Use message ID as key, not conversation length
                      message: message,
                      showTimestamp: true,
                      isLatest: index == state.conversation.length - 1,
                      onSourceTap: (source) => AssistantOptionsMenu.showSourceDetails(context, source),
                    );
                  },
                  childCount: state.conversation.length,
                  // Performance optimization: only build visible items
                  findChildIndexCallback: (Key key) {
                    if (key is ValueKey<String>) {
                      final messageId = key.value;
                      return state.conversation.indexWhere((msg) => msg.id == messageId);
                    }
                    return null;
                  },
                ),
              ),

              // Typing indicator
              if (state.status == AssistantStatus.processing || state.status == AssistantStatus.typing)
                SliverToBoxAdapter(child: TypingIndicatorWidget(message: state.typingText)),

              // Error message
              if (state.status == AssistantStatus.error && state.errorMessage != null)
                SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: layout.messageHorizontalPadding,
                      vertical: ResponsiveUtils.getResponsiveSpacing(context),
                    ),
                    child: AssistantErrorWidget(
                      error: state.errorMessage!,
                      onRetry:
                          state.currentQuery != null
                              ? () {
                                context.read<AssistantCubit>().retryQuery(state.currentQuery!.id);
                              }
                              : null,
                    ),
                  ),
                ),

              // Bottom padding for better UX
              SliverToBoxAdapter(child: SizedBox(height: layout.inputBottomPadding + 80)),
            ],
          ),
        );
      },
    );
  }

  void _handleScrollBehavior(AssistantState state) {
    if (!widget.scrollController.hasClients) return;

    final currentMessageCount = state.conversation.length;
    final hasNewMessage = currentMessageCount > _previousMessageCount;

    if (hasNewMessage) {
      // New message added
      if (_shouldAutoScroll || !_isUserScrolling) {
        // Auto-scroll to bottom for new messages
        _scrollToBottom();
      } else {
        // User is scrolling up, preserve their position
        _preserveScrollPosition();
      }
      _previousMessageCount = currentMessageCount;
    } else {
      // No new messages, preserve scroll position during rebuilds
      _preserveScrollPosition();
    }
  }

  void _scrollToBottom() {
    if (widget.scrollController.hasClients) {
      widget.scrollController.animateTo(
        widget.scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _preserveScrollPosition() {
    if (widget.scrollController.hasClients && _previousScrollPosition != null) {
      // Preserve the previous scroll position if it's valid
      final maxScroll = widget.scrollController.position.maxScrollExtent;
      final targetPosition = _previousScrollPosition!.clamp(0.0, maxScroll);

      if ((widget.scrollController.position.pixels - targetPosition).abs() > 10) {
        widget.scrollController.jumpTo(targetPosition);
      }
    }

    // Update previous position for next rebuild
    if (widget.scrollController.hasClients) {
      _previousScrollPosition = widget.scrollController.position.pixels;
    }
  }
}
