import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('🚀 REQUEST[${options.method}] => PATH: ${options.path}');
      debugPrint('📝 DATA: ${options.data}');
      debugPrint('📋 HEADERS: ${options.headers}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
      debugPrint('📄 DATA: ${response.data}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('❌ ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
      debugPrint('💀 ERROR: ${err.message}');
      debugPrint('💀 ERROR: ${err.response?.data}');
    }
    handler.next(err);
  }
}
