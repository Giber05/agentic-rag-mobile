import 'package:flutter/material.dart';

import '../../../../core/utils/responsive_utils.dart';

/// Modern typing indicator widget with smooth animations
class TypingIndicatorWidget extends StatefulWidget {
  final String? message;

  const TypingIndicatorWidget({super.key, this.message});

  @override
  State<TypingIndicatorWidget> createState() => _TypingIndicatorWidgetState();
}

class _TypingIndicatorWidgetState extends State<TypingIndicatorWidget> with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _bounceController;
  late final Animation<double> _fadeAnimation;
  late final List<Animation<double>> _bounceAnimations;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);

    _bounceController = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    // Create staggered bounce animations for dots
    _bounceAnimations = List.generate(3, (index) {
      final delay = index * 0.2;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _bounceController, curve: Interval(delay, 0.6 + delay, curve: Curves.elasticOut)),
      );
    });

    _fadeController.forward();
    _bounceController.repeat();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final layout = ResponsiveUtils.getConversationLayout(context);
    final spacing = ResponsiveUtils.getResponsiveSpacing(context);

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(opacity: _fadeAnimation.value, child: child);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: layout.messageHorizontalPadding, vertical: spacing),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(flex: ResponsiveUtils.isDesktop(context) ? 3 : 4, child: _buildTypingBubble(context)),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingBubble(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius = ResponsiveUtils.getResponsiveBorderRadius(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(borderRadius).copyWith(bottomLeft: Radius.circular(4)),
            boxShadow: [
              BoxShadow(color: theme.shadowColor.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AI Assistant header
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary]),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(Icons.auto_awesome_rounded, color: theme.colorScheme.onPrimary, size: 14),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AI Assistant',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Typing animation and message
              Row(
                children: [
                  _buildTypingDots(context),
                  if (widget.message != null) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.message!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypingDots(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _bounceAnimations[index],
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -4 * _bounceAnimations[index].value),
              child: Container(
                margin: EdgeInsets.only(right: index < 2 ? 4 : 0),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(
                    (0.3 + (0.7 * _bounceAnimations[index].value)).clamp(0.0, 1.0),
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
