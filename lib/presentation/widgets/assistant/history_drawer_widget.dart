import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/assistant/assistant_cubit.dart';

/// Widget for displaying query history in a drawer
class HistoryDrawerWidget extends StatelessWidget {
  final ScrollController? scrollController;
  final AssistantCubit assistantCubit;

  const HistoryDrawerWidget({super.key, this.scrollController, required this.assistantCubit});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: assistantCubit,
      child: Builder(
        builder: (context) {
          return Drawer(
            child: BlocBuilder<AssistantCubit, AssistantState>(
              builder: (context, state) {
                return Column(
                  children: [
                    DrawerHeader(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primaryContainer,
                            Theme.of(context).colorScheme.secondaryContainer,
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.history_rounded, color: Theme.of(context).colorScheme.onPrimaryContainer, size: 32),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Query History',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${state.queryHistory.length} queries',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (state.hasHistory)
                            IconButton(
                              onPressed: () => context.read<AssistantCubit>().clearHistory(),
                              icon: Icon(Icons.clear_all_rounded, color: Theme.of(context).colorScheme.onPrimaryContainer),
                              tooltip: 'Clear History',
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child:
                          state.hasHistory
                              ? ListView.builder(
                                controller: scrollController,
                                itemCount: state.queryHistory.length,
                                itemBuilder: (context, index) {
                                  final pair = state.queryHistory[index];
                                  return ListTile(
                                    leading: Icon(
                                      pair.isComplete
                                          ? Icons.check_circle_rounded
                                          : pair.hasFailed
                                          ? Icons.error_rounded
                                          : Icons.hourglass_empty_rounded,
                                      color:
                                          pair.isComplete
                                              ? Theme.of(context).colorScheme.primary
                                              : pair.hasFailed
                                              ? Theme.of(context).colorScheme.error
                                              : Theme.of(context).colorScheme.outline,
                                    ),
                                    title: Text(pair.query.question, maxLines: 2, overflow: TextOverflow.ellipsis),
                                    subtitle: Text(
                                      _formatDateTime(pair.query.timestamp),
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      if (pair.isComplete && pair.answer != null) {
                                        // TODO: Show the answer
                                      } else if (pair.hasFailed) {
                                        context.read<AssistantCubit>().retryQuery(pair.query.id);
                                      }
                                    },
                                    trailing: IconButton(
                                      onPressed: () => context.read<AssistantCubit>().removeFromHistory(pair.query.id),
                                      icon: const Icon(Icons.delete_rounded),
                                      iconSize: 20,
                                    ),
                                  );
                                },
                              )
                              : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.history_rounded, size: 64, color: Theme.of(context).colorScheme.outline),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No queries yet',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Start by asking a question',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                    ),
                  ],
                );
              },
            ),
          );
        }
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
