import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile_app/core/utils/resource.dart';
import 'package:mobile_app/domain/entities/user.dart';
import 'package:mobile_app/domain/usecases/get_current_user_usecase.dart';

part 'splash_state.dart';


@injectable
class SplashCubit extends Cubit<SplashState> {
  final GetCurrentUserUseCase _getCurrentSession;
  SplashCubit(this._getCurrentSession) : super(SplashInitial());

  void getLastSession() async {
    emit(SplashInitial());
    final result = await _getCurrentSession();
    await Future.delayed(const Duration(seconds: 2));
    switch (result) {
      case Success():
        emit(SplashSuccess(result.data));
      case Error():
        emit(const SplashSuccess(null));
    }
  }
}

