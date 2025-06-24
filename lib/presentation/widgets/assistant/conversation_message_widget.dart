import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../domain/models/assistant_models.dart';
import '../../bloc/assistant/assistant_cubit.dart';
import '../../../core/utils/responsive_utils.dart';

/// Modern conversation message widget that handles both user and AI messages
class ConversationMessageWidget extends StatefulWidget {
  final ConversationMessage message;
  final Function(KnowledgeSourceDomain)? onSourceTap;
  final bool showTimestamp;
  final bool isLatest;

  const ConversationMessageWidget({
    super.key,
    required this.message,
    this.onSourceTap,
    this.showTimestamp = false,
    this.isLatest = false,
  });

  @override
  State<ConversationMessageWidget> createState() => _ConversationMessageWidgetState();
}

class _ConversationMessageWidgetState extends State<ConversationMessageWidget> with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _scaleController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);

    _scaleController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOutBack));

    // Start animation
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final layout = ResponsiveUtils.getConversationLayout(context);
    final spacing = ResponsiveUtils.getResponsiveSpacing(context);

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(scale: _scaleAnimation.value, child: child),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: layout.messageHorizontalPadding, vertical: spacing),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.message.isUser) const Spacer(flex: 1),
            Flexible(flex: ResponsiveUtils.isDesktop(context) ? 3 : 4, child: _buildMessageBubble(context)),
            if (!widget.message.isUser) const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = widget.message.isUser;
    final borderRadius = ResponsiveUtils.getResponsiveBorderRadius(context);

    return Column(
      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        // Message bubble
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient:
                isUser
                    ? LinearGradient(
                      colors: [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                    : null,
            color: isUser ? null : theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(borderRadius).copyWith(
              bottomLeft: isUser ? Radius.circular(borderRadius) : Radius.circular(4),
              bottomRight: isUser ? Radius.circular(4) : Radius.circular(borderRadius),
            ),
            boxShadow: [
              BoxShadow(color: theme.shadowColor.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Message header (for AI messages)
              if (!isUser && widget.message.answer != null) _buildAIMessageHeader(context),

              // Message content
              _buildMessageContent(context),

              // Sources (for AI messages)
              if (!isUser && widget.message.answer?.sources.isNotEmpty == true) _buildSourcesSection(context),

              // Message footer with metrics
              if (!isUser && widget.message.answer != null) _buildMessageFooter(context),
            ],
          ),
        ),

        // Timestamp
        if (widget.showTimestamp) _buildTimestamp(context),
      ],
    );
  }

  Widget _buildAIMessageHeader(BuildContext context) {
    final theme = Theme.of(context);
    final padding = ResponsiveUtils.getResponsivePadding(context, mobile: 12, tablet: 16, desktop: 20);

    return Container(
      padding: EdgeInsets.only(left: padding.left, right: padding.right, top: padding.top, bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer.withOpacity(0.3),
            theme.colorScheme.secondaryContainer.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(ResponsiveUtils.getResponsiveBorderRadius(context)),
          topRight: Radius.circular(ResponsiveUtils.getResponsiveBorderRadius(context)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.auto_awesome_rounded, color: theme.colorScheme.onPrimary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'AI Assistant',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          _buildCopyButton(context),
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    final theme = Theme.of(context);
    final padding = ResponsiveUtils.getResponsivePadding(context, mobile: 12, tablet: 16, desktop: 20);
    final isUser = widget.message.isUser;

    return Padding(
      padding: EdgeInsets.all(padding.left),
      child: SelectableText(
        widget.message.content,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: isUser ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
          height: 1.5,
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 15, tablet: 16, desktop: 17),
        ),
      ),
    );
  }

  Widget _buildSourcesSection(BuildContext context) {
    final theme = Theme.of(context);
    final sources = widget.message.answer?.sources ?? [];
    final spacing = ResponsiveUtils.getResponsiveSpacing(context);

    if (sources.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.all(spacing),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: ExpansionTile(
        initiallyExpanded: _isExpanded,
        onExpansionChanged: (expanded) {
          setState(() {
            _isExpanded = expanded;
          });
        },
        leading: Icon(Icons.source_rounded, color: theme.colorScheme.primary, size: 20),
        title: Text(
          'Sources (${sources.length})',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
        ),
        childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: sources.map((source) => _buildSourceItem(context, source)).toList(),
      ),
    );
  }

  Widget _buildSourceItem(BuildContext context, KnowledgeSourceDomain source) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onSourceTap != null ? () => widget.onSourceTap!(source) : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        source.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${(source.relevanceScore * 100).toStringAsFixed(0)}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
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
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageFooter(BuildContext context) {
    final theme = Theme.of(context);
    final answer = widget.message.answer;
    final spacing = ResponsiveUtils.getResponsiveSpacing(context);

    if (answer?.quality == null && answer?.metrics == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.all(spacing),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          if (answer?.quality != null) ...[
            Icon(Icons.verified_rounded, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              'Confidence: ${(answer!.quality!.overallScore * 100).toStringAsFixed(0)}%',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
          if (answer?.quality != null && answer?.metrics != null) const SizedBox(width: 16),
          if (answer?.metrics != null) ...[
            Icon(Icons.speed_rounded, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              'Processed in ${answer!.metrics!.totalTime.toStringAsFixed(1)}s',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCopyButton(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _copyToClipboard(context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(Icons.copy_rounded, color: theme.colorScheme.onSurfaceVariant, size: 18),
        ),
      ),
    );
  }

  Widget _buildTimestamp(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = ResponsiveUtils.getResponsiveSpacing(context);

    return Padding(
      padding: EdgeInsets.only(top: spacing / 2),
      child: Text(
        _formatTimestamp(widget.message.timestamp),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
          fontSize: 12,
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return DateFormat('MMM d, HH:mm').format(timestamp);
    } else {
      return DateFormat('HH:mm').format(timestamp);
    }
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: widget.message.content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Message copied to clipboard'),
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'OK',
          textColor: Theme.of(context).colorScheme.inversePrimary,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
