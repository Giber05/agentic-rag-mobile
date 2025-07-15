import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cubits/assistant/assistant_cubit.dart';
import '../widgets/query_input_widget.dart';
import '../widgets/suggestions_widget.dart';
import '../widgets/tools_toggle_widget.dart';
import '../../../../core/utils/responsive_utils.dart';

/// Enhanced input area with suggestions and optimized rebuilds
/// Handles message input, suggestions display, and responsive layout
class AssistantInputArea extends StatelessWidget {
  final TextEditingController messageController;
  final Function(String)? onMessageSubmit;
  final Function(String)? onTextChanged;
  final VoidCallback? onScrollToBottom;

  const AssistantInputArea({
    super.key,
    required this.messageController,
    this.onMessageSubmit,
    this.onTextChanged,
    this.onScrollToBottom,
  });

  @override
  Widget build(BuildContext context) {
    final layout = ResponsiveUtils.getConversationLayout(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        layout.messageHorizontalPadding,
        16,
        layout.messageHorizontalPadding,
        layout.inputBottomPadding + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).colorScheme.surface.withOpacity(0.95), Theme.of(context).colorScheme.surface],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.2), width: 1)),
      ),
      child: Column(
        children: [
          // Tools Toggle (optimized rebuild)
          BlocBuilder<AssistantCubit, AssistantState>(
            buildWhen: (previous, current) => previous.selectedMode != current.selectedMode,
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const ToolsToggleWidget(),
                  ],
                ),
              );
            },
          ),

          // Suggestions (optimized rebuild)
          BlocBuilder<AssistantCubit, AssistantState>(
            buildWhen: (previous, current) => previous.suggestions != current.suggestions,
            builder: (context, state) {
              if (state.suggestions.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SuggestionsWidget(
                    suggestions: state.suggestions,
                    onSuggestionTap: (suggestion) {
                      context.read<AssistantCubit>().useSuggestion(suggestion);
                      onScrollToBottom?.call();
                    },
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Input field with responsive constraints
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: layout.maxMessageWidth),
            child: QueryInputWidget(
              controller: messageController,
              onSubmitted: onMessageSubmit,
              onTextChanged: onTextChanged,
            ),
          ),
        ],
      ),
    );
  }
}
