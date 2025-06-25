import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_app/core/bloc/messenger/messanger_handler.dart';
import 'package:mobile_app/core/bloc/messenger/messenger_cubit.dart';
import 'package:mobile_app/core/router/router.dart';

import 'core/di/injection.dart';
import 'core/bloc/bloc_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set up BLoC observer for debugging
  Bloc.observer = AppBlocObserver();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Configure dependencies
  await configureDependencies();
  final appRouter = getIt<AppRouter>();
  runApp(App(appRouter: appRouter));
}

class App extends StatelessWidget {
  final AppRouter appRouter;
  const App({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter.config(),
      theme: ThemeData(useMaterial3: false),
      builder: (context, child) => _AppLevelProvider(appRouter: appRouter, child: child!),
    );
  }
}

class _AppLevelProvider extends StatelessWidget {
  final Widget child;
  final AppRouter appRouter;
  const _AppLevelProvider({required this.child, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<MessengerCubit>()),
      ],
      child: BlocListener<MessengerCubit, MessengerState>(
        listener: (context, state) {
          final context = appRouter.navigatorKey.currentContext;
          if (context != null) {
            FUIMessengerHandler.handle(context, state);
          }
          context?.read<MessengerCubit>().idle();
        },
        child: child,
      ),
    );
  }
}
