import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/assistant/assistant_cubit.dart';
import '../bloc/auth/auth_cubit.dart';
import '../widgets/assistant/query_input_widget.dart';
import '../widgets/assistant/conversation_message_widget.dart';
import '../widgets/assistant/typing_indicator_widget.dart';
import '../widgets/assistant/suggestions_widget.dart';
import '../widgets/assistant/health_status_widget.dart';
import '../widgets/assistant/error_widget.dart';
import '../../core/utils/responsive_utils.dart';

/// Modern assistant page with responsive design and conversation flow
class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic));

    _fadeController.forward();
  }

  void _initializeApp() {
    // Check health on app start
    context.read<AssistantCubit>().checkHealth();
    context.read<AssistantCubit>().loadMetrics();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(opacity: _fadeAnimation.value, child: child);
        },
        child: ResponsiveBuilder(
          mobile: _buildMobileLayout(context),
          tablet: _buildTabletLayout(context),
          desktop: _buildDesktopLayout(context),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [_buildAppBar(context), Expanded(child: _buildConversationArea(context)), _buildInputArea(context)],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Column(
      children: [
        _buildAppBar(context),
        Expanded(child: Row(children: [Expanded(child: _buildConversationArea(context))])),
        _buildInputArea(context),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Column(
      children: [
        _buildAppBar(context, showMenuButton: true),
        Expanded(child: _buildConversationArea(context)),
        _buildInputArea(context),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, {bool showMenuButton = true}) {
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
          if (showMenuButton) ...[
            IconButton(
              onPressed: () => _showQuickOptions(context),
              icon: Icon(Icons.menu_rounded, color: theme.colorScheme.onSurface),
              tooltip: 'Options',
            ),
            const SizedBox(width: 8),
          ],
          Container(
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
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Assistant',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                BlocBuilder<AssistantCubit, AssistantState>(
                  builder: (context, state) {
                    return Text(
                      _getStatusText(state.status),
                      style: theme.textTheme.bodySmall?.copyWith(color: _getStatusColor(context, state.status)),
                    );
                  },
                ),
              ],
            ),
          ),
          if (!isDesktop)
            BlocBuilder<AssistantCubit, AssistantState>(
              builder: (context, state) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    state.healthStatus?.isHealthy == true ? Icons.check_circle : Icons.error_rounded,
                    color: state.healthStatus?.isHealthy == true ? theme.colorScheme.primary : theme.colorScheme.error,
                    size: 16,
                  ),
                );
              },
            ),
          if (showMenuButton) ...[
            IconButton(
              onPressed: () => _showOptionsMenu(context),
              icon: Icon(Icons.more_vert_rounded, color: theme.colorScheme.onSurface),
              tooltip: 'More options',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConversationArea(BuildContext context) {
    final layout = ResponsiveUtils.getConversationLayout(context);

    return BlocBuilder<AssistantCubit, AssistantState>(
      builder: (context, state) {
        return Container(
          constraints: BoxConstraints(maxWidth: layout.maxMessageWidth),
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Welcome message when conversation is empty
              if (state.conversation.isEmpty) _buildWelcomeMessage(context),

              // Conversation messages
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final message = state.conversation[index];
                  return ConversationMessageWidget(
                    key: ValueKey(message.id),
                    message: message,
                    showTimestamp: true,
                    isLatest: index == state.conversation.length - 1,
                    onSourceTap: (source) => _showSourceDetails(context, source),
                  );
                }, childCount: state.conversation.length),
              ),

              // Typing indicator
              if (state.status == AssistantStatus.processing || state.status == AssistantStatus.typing)
                SliverToBoxAdapter(child: TypingIndicatorWidget(message: state.typingText)),

              // Error message
              if (state.status == AssistantStatus.error && state.errorMessage != null)
                SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: layout.messageHorizontalPadding,
                      vertical: ResponsiveUtils.getResponsiveSpacing(context),
                    ),
                    child: AssistantErrorWidget(
                      error: state.errorMessage!,
                      onRetry:
                          state.currentQuery != null
                              ? () => context.read<AssistantCubit>().retryQuery(state.currentQuery!.id)
                              : null,
                    ),
                  ),
                ),

              // Bottom padding
              SliverToBoxAdapter(child: SizedBox(height: layout.inputBottomPadding + 80)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeMessage(BuildContext context) {
    final theme = Theme.of(context);
    final layout = ResponsiveUtils.getConversationLayout(context);

    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: layout.messageHorizontalPadding,
          vertical: ResponsiveUtils.getResponsiveSpacing(context) * 4,
        ),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary]),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(Icons.auto_awesome_rounded, color: theme.colorScheme.onPrimary, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to AI Assistant',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'I\'m here to help you with intelligent answers backed by comprehensive knowledge sources. Ask me anything!',
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Example questions
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildExampleQuestion(context, 'What is Smarco?'),
                _buildExampleQuestion(context, 'Explain the main features'),
                _buildExampleQuestion(context, 'How does it work?'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleQuestion(BuildContext context, String question) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _askExampleQuestion(question),
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

  Widget _buildInputArea(BuildContext context) {
    final layout = ResponsiveUtils.getConversationLayout(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        layout.messageHorizontalPadding,
        16,
        layout.messageHorizontalPadding,
        layout.inputBottomPadding + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).colorScheme.surface.withOpacity(0.95), Theme.of(context).colorScheme.surface],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.2), width: 1)),
      ),
      child: Column(
        children: [
          // Suggestions
          BlocBuilder<AssistantCubit, AssistantState>(
            builder: (context, state) {
              if (state.suggestions.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SuggestionsWidget(
                    suggestions: state.suggestions,
                    onSuggestionTap: (suggestion) {
                      context.read<AssistantCubit>().useSuggestion(suggestion);
                      _scrollToBottom();
                    },
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Input field
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: layout.maxMessageWidth),
            child: QueryInputWidget(
              controller: _messageController,
              onSubmitted: _handleMessageSubmit,
              onTextChanged: _handleTextChanged,
            ),
          ),
        ],
      ),
    );
  }

  void _askExampleQuestion(String question) {
    _messageController.text = question;
    _handleMessageSubmit(question);
  }

  void _handleMessageSubmit(String message) {
    if (message.trim().isNotEmpty) {
      context.read<AssistantCubit>().askQuestion(message);
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _handleTextChanged(String text) {
    // if (text.length > 2) {
    //   context.read<AssistantCubit>().getSuggestions(text);
    // } else {
    //   context.read<AssistantCubit>().clearSuggestions();
    // }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showQuickOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (sheetContext) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.clear_all_rounded),
                  title: const Text('Clear Conversation'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    context.read<AssistantCubit>().clearConversation();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.refresh_rounded),
                  title: const Text('Check Health'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    context.read<AssistantCubit>().checkHealth();
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout_rounded),
                  title: const Text('Logout'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _handleLogout(context);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (sheetContext) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.clear_all_rounded),
                  title: const Text('Clear Conversation'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    context.read<AssistantCubit>().clearConversation();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.refresh_rounded),
                  title: const Text('Check Health'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    context.read<AssistantCubit>().checkHealth();
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout_rounded),
                  title: const Text('Logout'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _handleLogout(context);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  // Use the original context, not the dialog context
                  context.read<AuthCubit>().logout();
                },
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }

  void _showSourceDetails(BuildContext context, source) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(source.title),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Relevance: ${(source.relevanceScore * 100).toStringAsFixed(1)}%'),
                  const SizedBox(height: 16),
                  Text(source.excerpt),
                ],
              ),
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Close'))],
          ),
    );
  }

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

  Color _getStatusColor(BuildContext context, AssistantStatus status) {
    final theme = Theme.of(context);
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
