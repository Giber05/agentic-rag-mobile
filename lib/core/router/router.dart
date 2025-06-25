import 'package:auto_route/auto_route.dart';
import 'package:mobile_app/core/router/route_wrapper.dart';
import 'package:mobile_app/core/router/router.gr.dart';


@AutoRouterConfig(replaceInRouteName: "Page,Route")
class AppRouter extends _BaseRoute {
  @override
  List<AutoRoute> get authenticatedNativeRoute => [
        AutoRoute(page: AssistantRoute.page, path: 'assistant', initial: true),

      ];

  @override
  List<RouteWrapper> get authenticatedRoutes => [];

  @override
  List<RouteWrapper> get guestRoutes => [];

  @override
  List<AutoRoute> get guestNativeRoute => [
        AutoRoute(page: LoginRoute.page, path: '/login'),
        AutoRoute(page: RegisterRoute.page, path: '/register'),
        // AutoRoute(page: ForgotPasswordRoute.page, path: '/forgot-password'),
        AutoRoute(page: SplashRoute.page, path: '/splash', initial: true),
      ];
}

abstract class _BaseRoute extends RootStackRouter {
  List<RouteWrapper> get guestRoutes;
  List<RouteWrapper> get authenticatedRoutes;
  List<AutoRoute> get guestNativeRoute;
  List<AutoRoute> get authenticatedNativeRoute => [];

  @override
  List<AutoRoute> get routes {
    final routes = [
      AutoRoute(
          page: AuthenticatedWrapperRoute.page,
          path: '/main',
          children: [for (final nativeRoute in authenticatedNativeRoute) nativeRoute]),
      ...guestNativeRoute,
      for (final wrapper in guestRoutes)
        ...wrapper.router.map((value) => value.copyWith(
            path: wrapper.basePath == null || wrapper.basePath?.isEmpty == true
                ? value.path
                : "${wrapper.basePath}/${value.path}")),
    ];
    return routes;
  }
}
