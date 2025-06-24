import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';

/// Base state class that all BLoC states should extend
abstract class BaseState extends Equatable {
  const BaseState();
}

/// Base event class that all BLoC events should extend
abstract class BaseEvent extends Equatable {
  const BaseEvent();
}

/// Common loading state mixin
mixin LoadingStateMixin on BaseState {
  bool get isLoading;
}

/// Common error state mixin
mixin ErrorStateMixin on BaseState {
  String? get errorMessage;
  bool get hasError => errorMessage != null;
}

/// Base BLoC class with common functionality
abstract class BaseBloc<Event extends BaseEvent, State extends BaseState> extends Bloc<Event, State> {
  BaseBloc(super.initialState) {
    _setupBlocObserver();
  }

  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  /// Logger instance for this BLoC
  Logger get logger => _logger;

  void _setupBlocObserver() {
    // Log state changes for debugging
    stream.listen((state) {
      _logger.d('${runtimeType} -> ${state.runtimeType}');
    });
  }

  /// Handle errors consistently across all BLoCs
  void handleError(Object error, StackTrace stackTrace) {
    _logger.e('Error in ${runtimeType}: $error\n$stackTrace');
  }

  /// Log events for debugging
  void logEvent(Event event) {
    _logger.i('${runtimeType} received event: ${event.runtimeType}');
  }
}

/// Base Cubit class with common functionality
abstract class BaseCubit<State extends BaseState> extends Cubit<State> {
  BaseCubit(super.initialState) {
    _setupCubitObserver();
  }

  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  /// Logger instance for this Cubit
  Logger get logger => _logger;

  void _setupCubitObserver() {
    // Log state changes for debugging
    stream.listen((state) {
      _logger.d('${runtimeType} -> ${state.runtimeType}');
    });
  }

  /// Handle errors consistently across all Cubits
  void handleError(Object error, StackTrace stackTrace) {
    _logger.e('Error in ${runtimeType}: $error\n$stackTrace');
  }

  /// Safe emit that handles potential errors
  void safeEmit(State state) {
    try {
      if (!isClosed) {
        emit(state);
      }
    } catch (error, stackTrace) {
      handleError(error, stackTrace);
    }
  }
}
