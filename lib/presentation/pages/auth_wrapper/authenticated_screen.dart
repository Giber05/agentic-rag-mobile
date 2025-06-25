import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/core/di/injection.dart';
import 'package:mobile_app/core/router/router.gr.dart';
import 'package:mobile_app/core/widgets/loading/loading_overlay.dart';
import 'package:mobile_app/domain/entities/user.dart';
import 'package:mobile_app/presentation/cubits/auth_wrapper/authenticated_screen_cubit.dart';

@RoutePage(name: 'AuthenticatedWrapperRoute')
class AuthenticatedScreen extends AutoRouter implements AutoRouteWrapper {
  final User? session;
  const AuthenticatedScreen({super.key, this.session});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthenticatedScreenCubit>()..init(session),
      child: BlocConsumer<AuthenticatedScreenCubit, AuthenticatedScreenState>(
        listener: (context, state) {
          if (state is AuthenticatedScreenSessionChecked && state.session == null) {
            context.router.replaceAll([const LoginRoute()]);
          }
        },
        builder: (context, state) {
          if (state is! AuthenticatedScreenSessionChecked || state.session == null) {
            return const FUILoadingOverlay();
          }
          return _UserAuthenticatedWidget(session: state.session!, widget: this);
        },
      ),
    );
  }
}

class _UserAuthenticatedWidget extends StatelessWidget {
  final User session;
  final Widget widget;
  const _UserAuthenticatedWidget({required this.session, required this.widget});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (context) => AuthenticatedScreenCubit(getIt()))],
      child: BlocListener<AuthenticatedScreenCubit, AuthenticatedScreenState>(
        listener: (context, state) {
          if (state is AuthenticatedScreenSessionChecked && state.session == null) {
            context.router.root.replaceAll([const LoginRoute()]);
          }
        },
        child: BlocBuilder<AuthenticatedScreenCubit, AuthenticatedScreenState>(
          builder: (context, state) {
            return Stack(children: [widget]);
          },
        ),
      ),
    );
  }
}
