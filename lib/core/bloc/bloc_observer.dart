import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

/// Custom BLoC observer for debugging and monitoring
class AppBlocObserver extends BlocObserver {
  AppBlocObserver()
    : _logger = Logger(
        printer: PrettyPrinter(
          methodCount: 0,
          errorMethodCount: 8,
          lineLength: 120,
          colors: true,
          printEmojis: true,
          printTime: true,
        ),
      );

  final Logger _logger;

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    _logger.d('🏗️ BLoC Created: ${bloc.runtimeType}');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    _logger.d(
      '🔄 BLoC Change: ${bloc.runtimeType}\n'
      '   Current: ${change.currentState.runtimeType}\n'
      '   Next: ${change.nextState.runtimeType}',
    );
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    _logger.d(
      '🚀 BLoC Transition: ${bloc.runtimeType}\n'
      '   Event: ${transition.event.runtimeType}\n'
      '   Current: ${transition.currentState.runtimeType}\n'
      '   Next: ${transition.nextState.runtimeType}',
    );
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    _logger.d('📨 BLoC Event: ${bloc.runtimeType} received ${event.runtimeType}');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    _logger.e('❌ BLoC Error in ${bloc.runtimeType}: $error\n$stackTrace');
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    _logger.d('🗑️ BLoC Closed: ${bloc.runtimeType}');
  }
}
