import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/core/di/injection.dart';
import 'package:mobile_app/core/router/router.gr.dart';

import '../../cubits/assistant/assistant_cubit.dart';
import '../../cubits/authentication/auth_cubit.dart';
import 'components/assistant_layout_manager.dart';
import 'components/assistant_app_bar.dart';
import 'components/assistant_conversation_area.dart';
import 'components/assistant_input_area.dart';
import 'components/assistant_options_menu.dart';

/// Modern assistant page with clean architecture and optimized performance
///
/// Features:
/// - Responsive design for mobile, tablet, and desktop
/// - Optimized state management with selective rebuilds
/// - Modular component architecture for maintainability
/// - Performance optimizations for smooth scrolling and rendering
/// - Clean separation of concerns
@RoutePage()
class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> with TickerProviderStateMixin {
  // Controllers for managing scrolling and text input
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  // Animation controller for smooth page transitions
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  /// Initialize fade-in animation for better UX
  void _setupAnimations() {
    _fadeController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic));

    _fadeController.forward();
  }

  @override
  void dispose() {
    // Clean up resources to prevent memory leaks
    _scrollController.dispose();
    _messageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Initialize assistant cubit and check health
        BlocProvider(create: (context) => getIt<AssistantCubit>()..checkHealth()),
        // Initialize auth cubit for logout functionality
        BlocProvider(create: (context) => getIt<AuthCubit>()),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            context.router.replaceAll([const LoginRoute()]);
          }
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(opacity: _fadeAnimation.value, child: child);
            },
            child: Builder(
              builder: (context) {
                return AssistantLayoutManager(
                  appBar: AssistantAppBar(
                    showMenuButton: true,
                    onMenuPressed: () => AssistantOptionsMenu.showQuickOptions(context),
                    onOptionsPressed: () => AssistantOptionsMenu.showOptionsMenu(context),
                  ),
                  conversationArea: AssistantConversationArea(
                    scrollController: _scrollController,
                    onExampleQuestionTap: (question) => _handleExampleQuestion(question, context),
                  ),
                  inputArea: AssistantInputArea(
                    messageController: _messageController,
                    onMessageSubmit: (message) => _handleMessageSubmit(context, message),
                    onTextChanged: _handleTextChanged,
                    onScrollToBottom: _scrollToBottom,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Handle example question taps from welcome screen
  void _handleExampleQuestion(String question, BuildContext context) {
    _messageController.text = question;
    _handleMessageSubmit(context, question);
    // Scroll to bottom for example questions to show the input
    _scrollToBottom();
  }

  /// Handle message submission with validation and auto-scroll
  void _handleMessageSubmit(BuildContext context, String message) {
    if (message.trim().isNotEmpty) {
      context.read<AssistantCubit>().askQuestion(message);
      _messageController.clear();
      // Remove duplicate scroll logic - let conversation area handle it
    }
  }

  /// Handle text changes (currently disabled for cost optimization)
  void _handleTextChanged(String text) {
    // Real-time suggestions disabled for cost optimization
    // Future implementation could include debounced suggestions
    // if (text.length > 2) {
    //   context.read<AssistantCubit>().getSuggestions(text);
    // } else {
    //   context.read<AssistantCubit>().clearSuggestions();
    // }
  }

  /// Smooth auto-scroll to bottom of conversation (used only for example questions)
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
}
