import 'package:flutter/material.dart';

/// Widget that shows processing status when AI is working
class ProcessingIndicatorWidget extends StatefulWidget {
  final String query;

  const ProcessingIndicatorWidget({super.key, required this.query});

  @override
  State<ProcessingIndicatorWidget> createState() => _ProcessingIndicatorWidgetState();
}

class _ProcessingIndicatorWidgetState extends State<ProcessingIndicatorWidget> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 2), vsync: this)..repeat();

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20.0),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _animation.value * 2 * 3.14159,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(Icons.psychology_rounded, color: Theme.of(context).colorScheme.onPrimary, size: 24),
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analyzing your question...',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.query,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildProcessingSteps(context),
        ],
      ),
    );
  }

  Widget _buildProcessingSteps(BuildContext context) {
    final steps = [
      'Understanding your question',
      'Searching knowledge base',
      'Analyzing sources',
      'Generating response',
    ];

    return Column(
      children:
          steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      final delay = index * 0.5;
                      final animValue = (_animation.value + delay) % 1.0;
                      final isActive = animValue > 0.3;

                      return Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color:
                              isActive
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child:
                            isActive
                                ? Icon(Icons.check_rounded, color: Theme.of(context).colorScheme.onPrimary, size: 14)
                                : null,
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      step,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}
