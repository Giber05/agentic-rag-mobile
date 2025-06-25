part of 'authenticated_screen_cubit.dart';

sealed class AuthenticatedScreenState extends Equatable {
  const AuthenticatedScreenState();

  @override
  List<Object?> get props => [];
}

final class AuthenticatedScreenInitial extends AuthenticatedScreenState {}

final class AuthenticatedScreenSessionChecked extends AuthenticatedScreenState {
  final User? session;

  const AuthenticatedScreenSessionChecked({required this.session});

  @override
  List<Object?> get props => [session];
}
