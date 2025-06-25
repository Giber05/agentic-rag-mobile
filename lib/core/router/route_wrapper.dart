import 'package:auto_route/auto_route.dart';

abstract class RouteWrapper {
  String? get basePath => null;

  List<AutoRoute> get router;
}
