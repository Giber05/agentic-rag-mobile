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
import 'package:mobile_app/core/network/api_client.dart' as _i1072;
import 'package:mobile_app/core/network/network_info.dart' as _i397;
import 'package:mobile_app/data/datasources/abstract/assistant_datasource.dart'
    as _i569;
import 'package:mobile_app/data/datasources/impl/assistant_datasource_impl.dart'
    as _i726;
import 'package:mobile_app/data/repositories/assistant_repository_impl.dart'
    as _i51;
import 'package:mobile_app/domain/repositories/assistant_repository.dart'
    as _i579;
import 'package:mobile_app/domain/usecases/ask_question_usecase.dart' as _i1019;
import 'package:mobile_app/presentation/bloc/chat/chat_cubit.dart' as _i651;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final httpClientModule = _$HttpClientModule();
    gh.factory<_i519.Client>(() => httpClientModule.httpClient());
    gh.singleton<_i397.NetworkInfo>(
      () => _i397.NetworkInfoImpl(gh<_i895.Connectivity>()),
    );
    gh.factory<_i651.ChatCubit>(
      () =>
          _i651.ChatCubit(gh<_i1019.AskQuestionUsecase>(), gh<_i974.Logger>()),
    );
    gh.lazySingleton<_i1072.APIClient>(() => _i1072.DioApiClient());
    gh.lazySingleton<_i569.AssistantDatasource>(
      () => _i726.AssistantDatasourceImpl(gh<_i1072.APIClient>()),
    );
    gh.lazySingleton<_i579.AssistantRepository>(
      () => _i51.AssistantRepositoryImpl(gh<_i569.AssistantDatasource>()),
    );
    return this;
  }
}

class _$HttpClientModule extends _i1072.HttpClientModule {}
