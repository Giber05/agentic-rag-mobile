import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile_app/core/di/injection.config.dart';
import 'package:mobile_app/core/router/router.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // default
  preferRelativeImports: true, // default
  asExtension: true, // default
)
Future<void> configureDependencies() async {
  getIt.allowReassignment = true;
  if (!getIt.isRegistered<AppRouter>()) {
    getIt.registerLazySingleton(() => AppRouter());
  }
  getIt.init();
}
