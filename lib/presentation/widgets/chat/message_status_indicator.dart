import 'package:flutter/material.dart';

import '../../../data/models/chat_models.dart';

/// Widget for displaying message status indicators
class MessageStatusIndicator extends StatelessWidget {
  final MessageStatus status;

  const MessageStatusIndicator({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    switch (status) {
      case MessageStatus.sending:
        return SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.onSurface.withOpacity(0.5)),
          ),
        );

      case MessageStatus.sent:
        return Icon(Icons.check, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.5));

      case MessageStatus.delivered:
        return Icon(Icons.done_all, size: 14, color: theme.colorScheme.primary.withOpacity(0.7));

      case MessageStatus.failed:
        return Icon(Icons.error_outline, size: 14, color: theme.colorScheme.error);

      case MessageStatus.processing:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'Processing',
              style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
