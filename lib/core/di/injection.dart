import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:injectable/injectable.dart';

import '../network/api_client.dart';
import '../network/network_info.dart';
import '../../data/datasources/abstract/assistant_datasource.dart';
import '../../data/datasources/impl/assistant_datasource_impl.dart';
import '../../data/repositories/assistant_repository_impl.dart';
import '../../domain/repositories/assistant_repository.dart';
import '../../domain/usecases/ask_question_usecase.dart';
import '../../domain/usecases/search_knowledge_usecase.dart';
import '../../domain/usecases/get_suggestions_usecase.dart';
import '../../domain/usecases/check_health_usecase.dart';
import '../../presentation/bloc/assistant/assistant_cubit.dart';

// Auth imports
import '../../data/datasources/abstract/auth_datasource.dart';
import '../../data/datasources/impl/auth_datasource_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../presentation/bloc/auth/auth_cubit.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  // Core
  getIt.registerLazySingleton<Connectivity>(() => Connectivity());
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(getIt()));
  getIt.registerLazySingleton<Logger>(() => Logger());
  getIt.registerLazySingleton<APIClient>(() => DioApiClient());

  // Data Sources
  getIt.registerLazySingleton<AssistantDatasource>(() => AssistantDatasourceImpl(getIt<APIClient>()));
  getIt.registerLazySingleton<AuthDatasource>(() => AuthDatasourceImpl(getIt<APIClient>()));

  // Repositories
  getIt.registerLazySingleton<AssistantRepository>(() => AssistantRepositoryImpl(getIt<AssistantDatasource>()));
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(getIt<AuthDatasource>()));

  // Use Cases
  getIt.registerFactory(() => AskQuestionUsecase(getIt<AssistantRepository>()));
  getIt.registerFactory(() => SearchKnowledgeUsecase(getIt<AssistantRepository>()));
  getIt.registerFactory(() => GetSuggestionsUsecase(getIt<AssistantRepository>()));
  getIt.registerFactory(() => CheckHealthUsecase(getIt<AssistantRepository>()));

  // Auth Use Cases
  getIt.registerFactory(() => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerFactory(() => RegisterUseCase(getIt<AuthRepository>()));
  getIt.registerFactory(() => LogoutUseCase(getIt<AuthRepository>()));
  getIt.registerFactory(() => GetCurrentUserUseCase(getIt<AuthRepository>()));

  // BLoC - Provide dependencies explicitly
  getIt.registerFactory(
    () => AssistantCubit(
      askQuestionUsecase: getIt<AskQuestionUsecase>(),
      searchKnowledgeUsecase: getIt<SearchKnowledgeUsecase>(),
      getSuggestionsUsecase: getIt<GetSuggestionsUsecase>(),
      checkHealthUsecase: getIt<CheckHealthUsecase>(),
      logger: getIt<Logger>(),
    ),
  );
  getIt.registerFactory(
    () => AuthCubit(
      loginUseCase: getIt<LoginUseCase>(),
      registerUseCase: getIt<RegisterUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
      getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );
}
