// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:get_it/get_it.dart' as _i174;
import 'package:http/http.dart' as _i519;
import 'package:injectable/injectable.dart' as _i526;
import 'package:logger/logger.dart' as _i974;

import '../../data/datasources/abstract/assistant_datasource.dart' as _i825;
import '../../data/datasources/abstract/auth_datasource.dart' as _i507;
import '../../data/datasources/impl/assistant_datasource_impl.dart' as _i763;
import '../../data/datasources/impl/auth_datasource_impl.dart' as _i295;
import '../../data/repositories/assistant_repository_impl.dart' as _i415;
import '../../data/repositories/auth_repository_impl.dart' as _i895;
import '../../domain/repositories/assistant_repository.dart' as _i282;
import '../../domain/repositories/auth_repository.dart' as _i1073;
import '../../domain/usecases/ask_question_usecase.dart' as _i602;
import '../../domain/usecases/check_health_usecase.dart' as _i721;
import '../../domain/usecases/get_conversations.dart' as _i94;
import '../../domain/usecases/get_current_user_usecase.dart' as _i771;
import '../../domain/usecases/get_suggestions_usecase.dart' as _i788;
import '../../domain/usecases/login_usecase.dart' as _i253;
import '../../domain/usecases/logout_usecase.dart' as _i981;
import '../../domain/usecases/register_usecase.dart' as _i35;
import '../../domain/usecases/search_knowledge_usecase.dart' as _i348;
import '../../presentation/cubits/assistant/assistant_cubit.dart' as _i35;
import '../../presentation/cubits/auth_wrapper/authenticated_screen_cubit.dart'
    as _i942;
import '../../presentation/cubits/authentication/auth_cubit.dart' as _i726;
import '../../presentation/cubits/splash/splash_cubit.dart' as _i1008;
import '../bloc/messenger/messenger_cubit.dart' as _i115;
import '../network/api_client.dart' as _i557;
import '../network/network_info.dart' as _i932;
import 'modules/network_module.dart' as _i851;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final httpClientModule = _$HttpClientModule();
    final networkModule = _$NetworkModule();
    gh.factory<_i519.Client>(() => httpClientModule.httpClient());
    gh.factory<_i94.GetConversationsUsecase>(
      () => _i94.GetConversationsUsecase(),
    );
    gh.singleton<_i115.MessengerCubit>(() => _i115.MessengerCubit());
    gh.lazySingleton<_i895.Connectivity>(() => networkModule.connectivity);
    gh.lazySingleton<_i974.Logger>(() => networkModule.logger);
    gh.lazySingleton<_i557.DioApiClient>(() => networkModule.getDioApiClient());
    gh.singleton<_i932.NetworkInfo>(
      () => _i932.NetworkInfoImpl(gh<_i895.Connectivity>()),
    );
    gh.lazySingleton<_i557.APIClient>(() => _i557.DioApiClient());
    gh.factory<_i507.AuthDatasource>(
      () => _i295.AuthDatasourceImpl(gh<_i557.APIClient>()),
    );
    gh.factory<_i825.AssistantDatasource>(
      () => _i763.AssistantDatasourceImpl(gh<_i557.APIClient>()),
    );
    gh.factory<_i282.AssistantRepository>(
      () => _i415.AssistantRepositoryImpl(gh<_i825.AssistantDatasource>()),
    );
    gh.factory<_i1073.AuthRepository>(
      () => _i895.AuthRepositoryImpl(gh<_i507.AuthDatasource>()),
    );
    gh.factory<_i721.CheckHealthUsecase>(
      () => _i721.CheckHealthUsecase(gh<_i282.AssistantRepository>()),
    );
    gh.factory<_i602.AskQuestionUsecase>(
      () => _i602.AskQuestionUsecase(gh<_i282.AssistantRepository>()),
    );
    gh.factory<_i788.GetSuggestionsUsecase>(
      () => _i788.GetSuggestionsUsecase(gh<_i282.AssistantRepository>()),
    );
    gh.factory<_i348.SearchKnowledgeUsecase>(
      () => _i348.SearchKnowledgeUsecase(gh<_i282.AssistantRepository>()),
    );
    gh.factory<_i35.AssistantCubit>(
      () => _i35.AssistantCubit(
        askQuestionUsecase: gh<_i602.AskQuestionUsecase>(),
        searchKnowledgeUsecase: gh<_i348.SearchKnowledgeUsecase>(),
        getSuggestionsUsecase: gh<_i788.GetSuggestionsUsecase>(),
        checkHealthUsecase: gh<_i721.CheckHealthUsecase>(),
        logger: gh<_i974.Logger>(),
      ),
    );
    gh.factory<_i35.RegisterUseCase>(
      () => _i35.RegisterUseCase(gh<_i1073.AuthRepository>()),
    );
    gh.factory<_i253.LoginUseCase>(
      () => _i253.LoginUseCase(gh<_i1073.AuthRepository>()),
    );
    gh.factory<_i981.LogoutUseCase>(
      () => _i981.LogoutUseCase(gh<_i1073.AuthRepository>()),
    );
    gh.factory<_i771.GetCurrentUserUseCase>(
      () => _i771.GetCurrentUserUseCase(gh<_i1073.AuthRepository>()),
    );
    gh.factory<_i726.AuthCubit>(
      () => _i726.AuthCubit(
        loginUseCase: gh<_i253.LoginUseCase>(),
        registerUseCase: gh<_i35.RegisterUseCase>(),
        logoutUseCase: gh<_i981.LogoutUseCase>(),
        getCurrentUserUseCase: gh<_i771.GetCurrentUserUseCase>(),
        authRepository: gh<_i1073.AuthRepository>(),
      ),
    );
    gh.factory<_i1008.SplashCubit>(
      () => _i1008.SplashCubit(gh<_i771.GetCurrentUserUseCase>()),
    );
    gh.factory<_i942.AuthenticatedScreenCubit>(
      () => _i942.AuthenticatedScreenCubit(gh<_i771.GetCurrentUserUseCase>()),
    );
    return this;
  }
}

class _$HttpClientModule extends _i557.HttpClientModule {}

class _$NetworkModule extends _i851.NetworkModule {}
