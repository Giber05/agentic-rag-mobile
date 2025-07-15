import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cubits/assistant/assistant_cubit.dart';

/// Widget for toggling between different tool modes
class ToolsToggleWidget extends StatelessWidget {
  const ToolsToggleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AssistantCubit, AssistantState>(
      buildWhen: (previous, current) => previous.selectedMode != current.selectedMode,
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tools Icon
              Icon(
                Icons.build_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              
              // Tools Dropdown
              PopupMenuButton<String?>(
                initialValue: state.selectedMode,
                onSelected: (String? mode) {
                  context.read<AssistantCubit>().setMode(mode);
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String?>(
                    value: null,
                    child: Row(
                      children: [
                        Icon(Icons.psychology_rounded, size: 16),
                        SizedBox(width: 8),
                        Text('Default Mode'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String?>(
                    value: 'jira',
                    child: Row(
                      children: [
                        Icon(Icons.search_rounded, size: 16),
                        SizedBox(width: 8),
                        Text('Search by Jira'),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: state.selectedMode != null 
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: state.selectedMode != null
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.selectedMode == 'jira' ? 'Search by Jira' : 'Tools',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: state.selectedMode != null
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: state.selectedMode != null ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: state.selectedMode != null
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}