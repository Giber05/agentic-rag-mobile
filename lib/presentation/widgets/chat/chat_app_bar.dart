import 'package:flutter/material.dart';

/// Custom app bar for the chat page
class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onClearMessages;
  final VoidCallback? onShowMetrics;

  const ChatAppBar({super.key, this.onClearMessages, this.onShowMetrics});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
            child: Icon(Icons.smart_toy, size: 20, color: theme.colorScheme.onPrimary),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Agentic RAG AI', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              Text(
                'Intelligent Assistant',
                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Metrics button
        if (onShowMetrics != null)
          IconButton(onPressed: onShowMetrics, icon: const Icon(Icons.analytics_outlined), tooltip: 'Show metrics'),

        // Clear messages button
        if (onClearMessages != null)
          IconButton(onPressed: onClearMessages, icon: const Icon(Icons.clear_all), tooltip: 'Clear messages'),

        // More options menu
        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(context, value),
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'settings',
                  child: ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Settings'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'about',
                  child: ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('About'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
        ),
      ],
      elevation: 0,
      backgroundColor: theme.colorScheme.surface,
      foregroundColor: theme.colorScheme.onSurface,
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'settings':
        _showSettingsDialog(context);
        break;
      case 'about':
        _showAboutDialog(context);
        break;
    }
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Settings'),
            content: const Text('Settings panel will be implemented in the next phase.'),
            actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
          ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Agentic RAG AI',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
        child: Icon(Icons.smart_toy, size: 24, color: Theme.of(context).colorScheme.onPrimary),
      ),
      children: [
        const Text(
          'An advanced Agentic Retrieval-Augmented Generation (RAG) AI agent featuring 5 specialized agents working in coordination to provide contextual, accurate responses with source attribution.',
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
