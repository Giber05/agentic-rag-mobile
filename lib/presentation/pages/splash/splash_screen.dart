import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/core/di/injection.dart';
import 'package:mobile_app/core/router/router.dart';
import 'package:mobile_app/core/router/router.gr.dart';
import 'package:mobile_app/presentation/cubits/splash/splash_cubit.dart';

@RoutePage()
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SplashCubit>()..getLastSession(),
      child: Scaffold(
        body: BlocListener<SplashCubit, SplashState>(
          listener: (context, state) {
            if (state is SplashSuccess) {
              final route = state.userSession != null ? AssistantRoute() : const LoginRoute();
              context.router.replace(route as PageRouteInfo);
            }
          },
          child: Container(
            width: double.infinity,
            alignment: Alignment.center,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/icon.png', width: 220, height: 220),
                Text(
                  'Plantation',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
