import 'package:flutter/material.dart';

import '../../../../core/utils/responsive_utils.dart';

/// Welcome screen component displayed when conversation is empty
/// Provides example questions and onboarding information
class AssistantWelcomeScreen extends StatelessWidget {
  final Function(String)? onExampleQuestionTap;

  const AssistantWelcomeScreen({super.key, this.onExampleQuestionTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final layout = ResponsiveUtils.getConversationLayout(context);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: layout.messageHorizontalPadding,
        vertical: ResponsiveUtils.getResponsiveSpacing(context) * 4,
      ),
      child: Column(
        children: [
          _buildWelcomeIcon(theme),
          const SizedBox(height: 24),
          _buildWelcomeTitle(theme),
          const SizedBox(height: 12),
          _buildWelcomeDescription(theme),
          const SizedBox(height: 32),
          _buildExampleQuestions(context, theme),
        ],
      ),
    );
  }

  Widget _buildWelcomeIcon(ThemeData theme) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: theme.colorScheme.primary.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: Icon(Icons.auto_awesome_rounded, color: theme.colorScheme.onPrimary, size: 40),
    );
  }

  Widget _buildWelcomeTitle(ThemeData theme) {
    return Text(
      'Welcome to AI Assistant',
      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
    );
  }

  Widget _buildWelcomeDescription(ThemeData theme) {
    return Text(
      'I\'m here to help you with intelligent answers backed by comprehensive knowledge sources. Ask me anything!',
      style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.5),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildExampleQuestions(BuildContext context, ThemeData theme) {
    final exampleQuestions = ['What is Smarco?', 'Explain the main features', 'How does it work?'];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: exampleQuestions.map((question) => _buildExampleQuestionChip(context, theme, question)).toList(),
    );
  }

  Widget _buildExampleQuestionChip(BuildContext context, ThemeData theme, String question) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onExampleQuestionTap?.call(question),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
          ),
          child: Text(
            question,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
