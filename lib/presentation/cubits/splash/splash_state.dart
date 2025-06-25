part of 'splash_cubit.dart';

sealed class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object> get props => [];
}

class SplashInitial extends SplashState {}

class SplashSuccess extends SplashState {
  final User? userSession;

  const SplashSuccess(this.userSession);
}

