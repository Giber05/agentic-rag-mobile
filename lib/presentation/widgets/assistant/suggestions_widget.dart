import 'package:flutter/material.dart';

/// Widget for displaying query suggestions
class SuggestionsWidget extends StatelessWidget {
  final List<String> suggestions;
  final Function(String)? onSuggestionTap;

  const SuggestionsWidget({super.key, required this.suggestions, this.onSuggestionTap});

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Suggestions',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                suggestions
                    .map(
                      (suggestion) => Material(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          onTap: onSuggestionTap != null ? () => onSuggestionTap!(suggestion) : null,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              suggestion,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }
}
