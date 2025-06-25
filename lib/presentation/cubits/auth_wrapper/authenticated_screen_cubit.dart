import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile_app/core/utils/resource.dart';
import 'package:mobile_app/domain/entities/user.dart';
import 'package:mobile_app/domain/usecases/get_current_user_usecase.dart';

part 'authenticated_screen_state.dart';

@injectable
class AuthenticatedScreenCubit extends Cubit<AuthenticatedScreenState> {
  final GetCurrentUserUseCase _checkLoggedInUser;
  AuthenticatedScreenCubit(
    this._checkLoggedInUser,

  ) : super(AuthenticatedScreenInitial());

  void init(User? user) async {
    if (user != null) {
      emit(AuthenticatedScreenSessionChecked(session: user));
      return;
    }
    final result = await _checkLoggedInUser();
    switch (result) {
      case Success():
        emit(AuthenticatedScreenSessionChecked(session: result.data));
      case Error():
        emit(const AuthenticatedScreenSessionChecked(session: null));
    }
  }
}
