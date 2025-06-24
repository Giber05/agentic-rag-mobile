import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/models/chat_models.dart';
import 'source_citations_widget.dart';
import 'message_status_indicator.dart';

/// Widget for displaying individual chat message bubbles
class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isLastMessage;
  final bool isStreaming;

  const ChatMessageBubble({super.key, required this.message, this.isLastMessage = false, this.isStreaming = false});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final theme = Theme.of(context);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        margin: EdgeInsets.only(left: isUser ? 48 : 0, right: isUser ? 0 : 48, bottom: 4),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Message bubble
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomRight: isUser ? const Radius.circular(4) : null,
                  bottomLeft: !isUser ? const Radius.circular(4) : null,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message content
                  SelectableText(
                    message.content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isUser ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                    ),
                  ),

                  // Processing indicator for streaming
                  if (isStreaming && message.role == MessageRole.assistant)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Generating...',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Source citations (only for assistant messages)
            if (!isUser && message.citations?.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SourceCitationsWidget(citations: message.citations!),
              ),

            // Message metadata and actions
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Timestamp
                  Text(
                    _formatTime(message.timestamp),
                    style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                  ),

                  // Message status
                  const SizedBox(width: 4),
                  MessageStatusIndicator(status: message.status),

                  // Copy button
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _copyMessage(context),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.copy, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                    ),
                  ),

                  // Processing time (for assistant messages)
                  if (!isUser && message.metadata?['processing_time'] != null) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.timer, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                    const SizedBox(width: 2),
                    Text(
                      '${(message.metadata!['processing_time'] as double).toStringAsFixed(1)}s',
                      style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                    ),
                  ],
                ],
              ),
            ),

            // Quality metrics (for assistant messages)
            if (!isUser && message.metadata?['quality_metrics'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: _buildQualityMetrics(context, message.metadata!['quality_metrics']),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityMetrics(BuildContext context, Map<String, dynamic> metrics) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.analytics_outlined, size: 12, color: theme.colorScheme.onSurface.withOpacity(0.6)),
          const SizedBox(width: 4),
          Text(
            'Quality: ${((metrics['relevance'] ?? 0.0) * 100).toStringAsFixed(0)}%',
            style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _copyMessage(BuildContext context) {
    Clipboard.setData(ClipboardData(text: message.content));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Message copied to clipboard'), duration: Duration(seconds: 2)));
  }
}
