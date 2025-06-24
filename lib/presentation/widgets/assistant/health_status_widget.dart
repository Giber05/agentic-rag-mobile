import 'package:flutter/material.dart';
import 'package:mobile_app/domain/models/assistant_models.dart';


/// Widget for displaying assistant health status
class HealthStatusWidget extends StatelessWidget {
  final AssistantHealthDomain? healthStatus;
  final DateTime? lastCheck;
  final VoidCallback? onRefresh;

  const HealthStatusWidget({super.key, this.healthStatus, this.lastCheck, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (healthStatus == null) return const SizedBox.shrink();

    final isHealthy = healthStatus!.isHealthy;

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color:
            isHealthy ? Theme.of(context).colorScheme.surfaceContainer : Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              isHealthy
                  ? Theme.of(context).colorScheme.outline.withOpacity(0.3)
                  : Theme.of(context).colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isHealthy ? Icons.check_circle_rounded : Icons.error_rounded,
            color: isHealthy ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isHealthy ? 'Assistant is ready' : 'Assistant is offline',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color:
                    isHealthy
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.onErrorContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onRefresh != null)
            IconButton(
              onPressed: onRefresh,
              icon: Icon(Icons.refresh_rounded, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
        ],
      ),
    );
  }
}
