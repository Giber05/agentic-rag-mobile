import 'package:flutter/material.dart';

import '../../../data/models/chat_models.dart';

/// Widget for displaying source citations
class SourceCitationsWidget extends StatefulWidget {
  final List<SourceCitation> citations;

  const SourceCitationsWidget({super.key, required this.citations});

  @override
  State<SourceCitationsWidget> createState() => _SourceCitationsWidgetState();
}

class _SourceCitationsWidgetState extends State<SourceCitationsWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.source, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.citations.length} Source${widget.citations.length > 1 ? 's' : ''}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ],
              ),
            ),
          ),

          // Citations list
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children:
                    widget.citations.asMap().entries.map((entry) {
                      final index = entry.key;
                      final citation = entry.value;
                      return _buildCitationItem(context, citation, index + 1);
                    }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCitationItem(BuildContext context, SourceCitation citation, int number) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Citation header
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    number.toString(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  citation.title,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (citation.relevanceScore != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getRelevanceColor(citation.relevanceScore!).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${(citation.relevanceScore! * 100).toStringAsFixed(0)}%',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _getRelevanceColor(citation.relevanceScore!),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),

          // Citation content
          if (citation.content != null) ...[
            const SizedBox(height: 8),
            Text(
              citation.content!,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.8)),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          // Citation URL
          if (citation.url != null) ...[
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _openUrl(citation.url!),
              child: Text(
                citation.url!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getRelevanceColor(double relevance) {
    if (relevance >= 0.8) return Colors.green;
    if (relevance >= 0.6) return Colors.orange;
    return Colors.red;
  }

  void _openUrl(String url) {
    // TODO: Implement URL opening with url_launcher
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Opening: $url'), duration: const Duration(seconds: 2)));
  }
}
