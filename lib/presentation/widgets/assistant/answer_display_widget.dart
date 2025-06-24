import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../domain/models/assistant_models.dart';

/// Widget for displaying answers from the intelligent assistant
class AnswerDisplayWidget extends StatefulWidget {
  final AssistantAnswerDomain answer;
  final Function(KnowledgeSourceDomain)? onSourceTap;
  final VoidCallback? onClear;

  const AnswerDisplayWidget({super.key, required this.answer, this.onSourceTap, this.onClear});

  @override
  State<AnswerDisplayWidget> createState() => _AnswerDisplayWidgetState();
}

class _AnswerDisplayWidgetState extends State<AnswerDisplayWidget> with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(opacity: _fadeAnimation.value, child: child);
      },
      child: Container(
        margin: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context),

            // Answer Content
            _buildAnswerContent(context),

            // Sources
            if (widget.answer.sources.isNotEmpty) _buildSourcesSection(context),

            // Metadata
            if (widget.answer.quality != null || widget.answer.metrics != null) _buildMetadataSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).colorScheme.primaryContainer, Theme.of(context).colorScheme.secondaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.auto_awesome_rounded, color: Theme.of(context).colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Assistant Response',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _copyToClipboard(context),
                icon: Icon(Icons.copy_rounded, color: Theme.of(context).colorScheme.onPrimaryContainer, size: 20),
                tooltip: 'Copy Answer',
              ),
              if (widget.onClear != null)
                IconButton(
                  onPressed: widget.onClear,
                  icon: Icon(Icons.close_rounded, color: Theme.of(context).colorScheme.onPrimaryContainer, size: 20),
                  tooltip: 'Clear Answer',
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            widget.answer.content,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(height: 1.6, color: Theme.of(context).colorScheme.onSurface),
          ),
        ],
      ),
    );
  }

  Widget _buildSourcesSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
      ),
      child: ExpansionTile(
        initiallyExpanded: _isExpanded,
        onExpansionChanged: (expanded) {
          setState(() {
            _isExpanded = expanded;
          });
        },
        leading: Icon(Icons.source_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
        title: Text(
          'Sources (${widget.answer.sources.length})',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: widget.answer.sources.map((source) => _buildSourceItem(context, source)).toList(),
      ),
    );
  }

  Widget _buildSourceItem(BuildContext context, KnowledgeSourceDomain source) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: widget.onSourceTap != null ? () => widget.onSourceTap!(source) : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      source.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${(source.relevanceScore * 100).toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (source.excerpt.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  source.excerpt,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          if (widget.answer.quality != null) ...[
            Icon(Icons.verified_rounded, size: 16, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              'Confidence: ${(widget.answer.quality!.overallScore * 100).toStringAsFixed(0)}%',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
          if (widget.answer.quality != null && widget.answer.metrics != null) const SizedBox(width: 16),
          if (widget.answer.metrics != null) ...[
            Icon(Icons.speed_rounded, size: 16, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              'Processed in ${widget.answer.metrics!.totalTime.toStringAsFixed(1)}s',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: widget.answer.content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Answer copied to clipboard'),
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
