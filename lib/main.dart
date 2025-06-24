import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';

import 'core/di/injection.dart';
import 'core/bloc/bloc_observer.dart';
import 'presentation/bloc/assistant/assistant_cubit.dart';
import 'presentation/bloc/auth/auth_cubit.dart';
import 'presentation/bloc/auth/auth_state.dart';
import 'presentation/pages/assistant_page.dart';
import 'presentation/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set up BLoC observer for debugging
  Bloc.observer = AppBlocObserver();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Configure dependencies
  await configureDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Intelligent AI Assistant',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.light),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => GetIt.instance<AuthCubit>()..checkAuthStatus()),
          BlocProvider(create: (context) => GetIt.instance<AssistantCubit>()),
        ],
        child: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (state is AuthAuthenticated) {
          return const AssistantPage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
