import 'package:dio/dio.dart';
import 'package:mobile_app/core/constants/network_constants.dart';
import 'package:mobile_app/domain/models/user_session_model.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final UserSessionModel? session = options.extra['session'] as UserSessionModel?;
    options.extra['hasSession'] = session != null;
    if (session != null) {
      options.headers[NetworkConstants.authorizationHeader] = 'Bearer ${session.accessToken}';
    }

    if (!options.headers.containsKey(NetworkConstants.contentTypeHeader)) {
      options.headers[NetworkConstants.contentTypeHeader] = NetworkConstants.applicationJson;
    }

    handler.next(options);
  }
}
