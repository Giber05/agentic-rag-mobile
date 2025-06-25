import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/core/di/injection.dart';
import 'package:mobile_app/core/router/router.gr.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../cubits/authentication/auth_cubit.dart';
import '../../cubits/authentication/auth_state.dart';

/// Modern responsive login page with enhanced UX and animations
/// Features:
/// - Fully responsive design for mobile, tablet, and desktop
/// - Smooth animations and transitions
/// - Real-time form validation
/// - Loading states and error handling
/// - Clean modern design following app design system
@RoutePage()
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Animation controllers
  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  // Form state
  bool _obscurePassword = true;
  bool _isFormValid = false;
  bool _hasEmailError = false;
  bool _hasPasswordError = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupListeners();
  }

  /// Initialize smooth animations for better UX
  void _setupAnimations() {
    _fadeController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);

    _slideController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  /// Setup real-time validation listeners
  void _setupListeners() {
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  /// Real-time form validation
  void _validateForm() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final isEmailValid = Validators.validateEmail(email) == null;
    final isPasswordValid = password.isNotEmpty;

    setState(() {
      _hasEmailError = email.isNotEmpty && !isEmailValid;
      _hasPasswordError = password.isNotEmpty && !isPasswordValid;
      _isFormValid = isEmailValid && isPasswordValid;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _handleLogin(BuildContext context) {
    if (_formKey.currentState!.validate() && _isFormValid) {
      context.read<AuthCubit>().login(email: _emailController.text.trim(), password: _passwordController.text);
    }
  }

  void _handleForgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Forgot password feature coming soon!'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BlocProvider(
        create: (context) => getIt<AuthCubit>()..checkAuthStatus(),
        child: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              context.router.replaceAll([const AssistantRoute()]);
            } else if (state is AuthError) {
              _showErrorSnackBar(context, state.message);
            }
          },
          child: Builder(builder: (context) => _buildResponsiveLayout(context)),
        ),
      ),
    );
  }

  /// Build responsive layout for different screen sizes
  Widget _buildResponsiveLayout(BuildContext context) {
    return ResponsiveBuilder(
      mobile: _buildMobileLayout(context),
      tablet: _buildTabletLayout(context),
      desktop: _buildDesktopLayout(context),
    );
  }

  /// Mobile layout: Full-screen with proper padding
  Widget _buildMobileLayout(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: SizedBox(
          height:
              MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              ResponsiveUtils.getResponsivePadding(context).vertical,
          child: _buildLoginContent(context, maxWidth: double.infinity),
        ),
      ),
    );
  }

  /// Tablet layout: Centered with max width
  Widget _buildTabletLayout(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: _buildLoginContent(context, maxWidth: 500),
      ),
    );
  }

  /// Desktop layout: Split screen design with background
  Widget _buildDesktopLayout(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // Left side: Welcome illustration/branding
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: _buildWelcomeSection(context),
          ),
        ),

        // Right side: Login form
        Expanded(
          flex: 2,
          child: Container(
            color: theme.colorScheme.surface,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(48),
                child: _buildLoginContent(context, maxWidth: 400),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Welcome section for desktop layout
  Widget _buildWelcomeSection(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Padding(
            padding: const EdgeInsets.all(48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.auto_awesome_rounded, color: theme.colorScheme.onPrimary, size: 40),
                ),
                const SizedBox(height: 32),
                Text(
                  'Welcome to\nAI Assistant',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your intelligent companion for enhanced productivity and seamless conversations.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Main login content
  Widget _buildLoginContent(BuildContext context, {required double maxWidth}) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!ResponsiveUtils.isDesktop(context)) _buildHeader(context),

                    if (ResponsiveUtils.isDesktop(context)) _buildDesktopHeader(context),

                    SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 32, tablet: 40, desktop: 32),
                    ),

                    _buildEmailField(context),

                    SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 16, tablet: 20, desktop: 24),
                    ),

                    _buildPasswordField(context),

                    SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 24, tablet: 32, desktop: 32),
                    ),

                    _buildLoginButton(context),

                    SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 24, tablet: 32, desktop: 24),
                    ),

                    _buildForgotPasswordButton(context),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Header for mobile and tablet
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(Icons.auto_awesome_rounded, color: theme.colorScheme.onPrimary, size: 40),
        ),
        const SizedBox(height: 24),
        Text(
          'AI Assistant',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Welcome back! Please sign in to your account.',
          style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.5),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Header for desktop layout
  Widget _buildDesktopHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to continue to your account',
          style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  /// Modern email input field with validation
  Widget _buildEmailField(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email',
          style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: Validators.validateEmail,
          decoration: InputDecoration(
            hintText: 'Enter your email address',
            prefixIcon: Icon(
              Icons.email_outlined,
              color: _hasEmailError ? theme.colorScheme.error : theme.colorScheme.onSurfaceVariant,
            ),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context)),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context)),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context)),
              borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context)),
              borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
            ),
          ),
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }

  /// Modern password input field with validation
  Widget _buildPasswordField(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password is required';
            }
            return null;
          },
          onFieldSubmitted: (_) => _handleLogin(context),
          decoration: InputDecoration(
            hintText: 'Enter your password',
            prefixIcon: Icon(
              Icons.lock_outlined,
              color: _hasPasswordError ? theme.colorScheme.error : theme.colorScheme.onSurfaceVariant,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context)),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context)),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context)),
              borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context)),
              borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
            ),
          ),
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }

  /// Modern login button with loading state
  Widget _buildLoginButton(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: ResponsiveUtils.getResponsiveSpacing(context, mobile: 56, tablet: 60, desktop: 56),
          child: ElevatedButton(
            onPressed: (!_isFormValid || isLoading) ? null : () => _handleLogin(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              disabledBackgroundColor: theme.colorScheme.surfaceContainerHighest,
              disabledForegroundColor: theme.colorScheme.onSurfaceVariant,
              elevation: _isFormValid && !isLoading ? 2 : 0,
              shadowColor: theme.colorScheme.primary.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context)),
              ),
            ),
            child:
                isLoading
                    ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                    : Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 16, tablet: 18, desktop: 16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
          ),
        );
      },
    );
  }

  /// Forgot password button
  Widget _buildForgotPasswordButton(BuildContext context) {
    final theme = Theme.of(context);

    return TextButton(
      onPressed: _handleForgotPassword,
      style: TextButton.styleFrom(
        foregroundColor: theme.colorScheme.primary,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(
        'Forgot Password?',
        style: TextStyle(fontSize: ResponsiveUtils.getResponsiveFontSize(context), fontWeight: FontWeight.w500),
      ),
    );
  }

  /// Show error snackbar with consistent styling
  void _showErrorSnackBar(BuildContext context, String message) {
    final theme = Theme.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: theme.colorScheme.onErrorContainer, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: theme.colorScheme.onErrorContainer, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: theme.colorScheme.errorContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: ResponsiveUtils.getResponsivePadding(context),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
