import 'package:flutter/material.dart';

/// Widget for displaying agent status and current processing stage
class AgentStatusIndicator extends StatelessWidget {
  final bool isStreaming;
  final String? currentStage;
  final VoidCallback? onCancel;

  const AgentStatusIndicator({super.key, this.isStreaming = false, this.currentStage, this.onCancel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        border: Border(bottom: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2))),
      ),
      child: Row(
        children: [
          // Status indicator
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
          ),

          const SizedBox(width: 12),

          // Status text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isStreaming ? 'Streaming Response' : 'Processing Request',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (currentStage != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    currentStage!,
                    style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                  ),
                ],
              ],
            ),
          ),

          // Cancel button
          if (onCancel != null)
            IconButton(
              onPressed: onCancel,
              icon: Icon(Icons.close, size: 20, color: theme.colorScheme.onSurface.withOpacity(0.6)),
              tooltip: 'Cancel request',
            ),
        ],
      ),
    );
  }
}
