import 'package:flutter/material.dart';

/// Widget for displaying errors with retry functionality
class AppErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;
  final bool showDetails;

  const AppErrorWidget({super.key, required this.error, this.onRetry, this.showDetails = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.error.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Error header
          Row(
            children: [
              Icon(Icons.error_outline, size: 20, color: theme.colorScheme.error),
              const SizedBox(width: 8),
              Text(
                'Error',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Error message
          Text(
            _getDisplayMessage(error),
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.8)),
          ),

          // Error details (if enabled)
          if (showDetails && _shouldShowDetails(error)) ...[
            const SizedBox(height: 8),
            ExpansionTile(
              title: Text(
                'Technical Details',
                style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
              ),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    error,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Action buttons
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Retry'),
                  style: TextButton.styleFrom(foregroundColor: theme.colorScheme.primary),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _getDisplayMessage(String error) {
    // Convert technical errors to user-friendly messages
    if (error.toLowerCase().contains('network')) {
      return 'Network connection error. Please check your internet connection and try again.';
    }

    if (error.toLowerCase().contains('timeout')) {
      return 'Request timed out. The server is taking too long to respond.';
    }

    if (error.toLowerCase().contains('unauthorized') || error.contains('401')) {
      return 'Authentication error. Please check your credentials.';
    }

    if (error.toLowerCase().contains('forbidden') || error.contains('403')) {
      return 'Access denied. You don\'t have permission to perform this action.';
    }

    if (error.toLowerCase().contains('not found') || error.contains('404')) {
      return 'The requested resource was not found.';
    }

    if (error.toLowerCase().contains('server') || error.contains('500')) {
      return 'Server error. Please try again later.';
    }

    if (error.toLowerCase().contains('rate limit')) {
      return 'Too many requests. Please wait a moment before trying again.';
    }

    // Return original error if no pattern matches
    return error;
  }

  bool _shouldShowDetails(String error) {
    // Show details for technical errors that might be useful for debugging
    return error.length > 100 ||
        error.contains('Exception') ||
        error.contains('Error:') ||
        error.contains('stack trace');
  }
}
