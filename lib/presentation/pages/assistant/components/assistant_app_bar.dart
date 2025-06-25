import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cubits/assistant/assistant_cubit.dart';
import '../../../../core/utils/responsive_utils.dart';

/// Modern app bar component for the assistant page
/// Handles status display, health indicators, and menu options
class AssistantAppBar extends StatelessWidget {
  final bool showMenuButton;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onOptionsPressed;

  const AssistantAppBar({super.key, this.showMenuButton = true, this.onMenuPressed, this.onOptionsPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return Container(
      padding: ResponsiveUtils.getResponsiveHorizontalPadding(
        context,
      ).copyWith(top: MediaQuery.of(context).padding.top + 8, bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.surface, theme.colorScheme.surface.withOpacity(0.95)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(bottom: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2), width: 1)),
      ),
      child: Row(
        children: [
          // Menu button (conditional)
          if (showMenuButton) ...[_buildMenuButton(context), const SizedBox(width: 8)],

          // Assistant icon
          _buildAssistantIcon(theme),
          const SizedBox(width: 12),

          // Title and status
          Expanded(child: _buildTitleSection(theme)),

          // Health indicator (mobile only)
          if (!isDesktop) _buildHealthIndicator(theme),

          // Options menu (conditional)
          if (showMenuButton) _buildOptionsButton(context),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context) {
    final theme = Theme.of(context);
    return IconButton(
      onPressed: onMenuPressed,
      icon: Icon(Icons.menu_rounded, color: theme.colorScheme.onSurface),
      tooltip: 'Options',
    );
  }

  Widget _buildAssistantIcon(ThemeData theme) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary]),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: theme.colorScheme.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Icon(Icons.auto_awesome_rounded, color: theme.colorScheme.onPrimary, size: 20),
    );
  }

  Widget _buildTitleSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Assistant',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
        ),
        BlocBuilder<AssistantCubit, AssistantState>(
          builder: (context, state) {
            return Text(
              _getStatusText(state.status),
              style: theme.textTheme.bodySmall?.copyWith(color: _getStatusColor(theme, state.status)),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHealthIndicator(ThemeData theme) {
    return BlocBuilder<AssistantCubit, AssistantState>(
      builder: (context, state) {
        final isHealthy = state.healthStatus?.isHealthy == true;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Icon(
            isHealthy ? Icons.check_circle : Icons.error_rounded,
            color: isHealthy ? theme.colorScheme.primary : theme.colorScheme.error,
            size: 16,
          ),
        );
      },
    );
  }

  Widget _buildOptionsButton(BuildContext context) {
    final theme = Theme.of(context);
    return IconButton(
      onPressed: onOptionsPressed,
      icon: Icon(Icons.more_vert_rounded, color: theme.colorScheme.onSurface),
      tooltip: 'More options',
    );
  }

  /// Helper methods for status text and colors
  String _getStatusText(AssistantStatus status) {
    switch (status) {
      case AssistantStatus.initial:
        return 'Ready to help';
      case AssistantStatus.processing:
        return 'Thinking...';
      case AssistantStatus.success:
        return 'Response ready';
      case AssistantStatus.error:
        return 'Error occurred';
      case AssistantStatus.searching:
        return 'Searching...';
      case AssistantStatus.searchComplete:
        return 'Search complete';
      case AssistantStatus.typing:
        return 'Typing...';
    }
  }

  Color _getStatusColor(ThemeData theme, AssistantStatus status) {
    switch (status) {
      case AssistantStatus.initial:
      case AssistantStatus.success:
      case AssistantStatus.searchComplete:
        return theme.colorScheme.primary;
      case AssistantStatus.processing:
      case AssistantStatus.searching:
      case AssistantStatus.typing:
        return theme.colorScheme.secondary;
      case AssistantStatus.error:
        return theme.colorScheme.error;
    }
  }
}
