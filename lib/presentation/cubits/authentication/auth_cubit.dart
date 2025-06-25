import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile_app/domain/entities/user.dart';
import '../../../domain/usecases/login_usecase.dart';
import '../../../domain/usecases/register_usecase.dart';
import '../../../domain/usecases/logout_usecase.dart';
import '../../../domain/usecases/get_current_user_usecase.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/entities/auth_token.dart';
import '../../../core/utils/resource.dart';
part 'auth_state.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final AuthRepository authRepository;

  AuthCubit({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.authRepository,
  }) : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(AuthChecking());

    final isLoggedIn = await authRepository.isLoggedIn();
    if (isLoggedIn) {
      final result = await getCurrentUserUseCase();
      switch (result) {
        case Success<dynamic> success:
          emit(AuthAuthenticated(user: success.data));
        case Error<dynamic>():
          emit(AuthUnauthenticated());
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());

    final params = LoginParams(email: email, password: password);
    final result = await loginUseCase(params);

    switch (result) {
      case Success<dynamic>():
        // Get user details after successful login
        await _getCurrentUser();
      case Error<dynamic> error:
        emit(AuthError(message: error.exception.message));
    }
  }

  Future<void> register({required String email, required String password, String? fullName}) async {
    emit(AuthLoading());

    final params = RegisterParams(email: email, password: password, fullName: fullName);
    final result = await registerUseCase(params);

    switch (result) {
      case Success<dynamic> success:
        // Check if we got valid tokens (immediate login)
        final token = success.data as AuthToken;
        if (token.accessToken.isNotEmpty) {
          // Got tokens, try to get user details
          await _getCurrentUser();
        } else {
          // Registration successful but no tokens (email verification required)
          emit(AuthUnauthenticated());
          // Show success message instead of error
          emit(AuthError(message: "Registration successful! Please check your email for verification link."));
        }
      case Error<dynamic> error:
        emit(AuthError(message: error.exception.message));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());

    final result = await logoutUseCase();

    switch (result) {
      case Success<dynamic>():
        emit(AuthUnauthenticated());
      case Error<dynamic>():
        // Even if logout fails on server, clear local state
        emit(AuthUnauthenticated());
    }
  }

  Future<void> _getCurrentUser() async {
    final result = await getCurrentUserUseCase();

    switch (result) {
      case Success<dynamic> success:
        emit(AuthAuthenticated(user: success.data));
      case Error<dynamic> error:
        emit(AuthError(message: error.exception.message));
    }
  }
}
