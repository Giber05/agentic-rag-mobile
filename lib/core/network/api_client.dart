import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

import '../utils/api_result.dart';
import '../error/exceptions.dart';
import '../config/environment.dart';
import '../constants/network_constants.dart';
import '../interceptors/auth_interceptor.dart';
import '../interceptors/logging_interceptor.dart';
import '../interceptors/requests_inspector_interceptor.dart';
import '../../domain/models/user_session_model.dart';

/// Direct implementation of the APIClient interface using Dio
@LazySingleton(as: APIClient)
class DioApiClient implements APIClient {
  late final Dio _dio;

  DioApiClient() {
    _dio = _createDio();
    _setupInterceptors();
  }

  Dio _createDio() {
    final baseOptions = BaseOptions(
      baseUrl: baseURL,
      connectTimeout: Duration(milliseconds: NetworkConstants.connectTimeout),
      receiveTimeout: Duration(milliseconds: NetworkConstants.receiveTimeout),
      validateStatus: (status) => status != null,
    );

    // Only set sendTimeout for non-web platforms
    // On web, sendTimeout cannot be used without a request body
    if (!kIsWeb) {
      baseOptions.sendTimeout = Duration(milliseconds: NetworkConstants.sendTimeout);
    }

    return Dio(baseOptions);
  }

  void _setupInterceptors() {
    // Set up the auth interceptor
    _dio.interceptors.add(AuthInterceptor());

    // Setup RequestsInspector for network debugging

    // Add pretty logger in debug mode
    // if (kDebugMode) {
    _dio.interceptors.add(RequestsInspectorInterceptor());
    _dio.interceptors.add(LoggingInterceptor());
    // _dio.interceptors.add(PrettyDioLogger(
    //   requestHeader: true,
    //   requestBody: true,
    //   responseHeader: true,
    //   responseBody: true,
    //   compact: false,
    // ));
    // }
  }

  @override
  Future<APIResult<T>> post<T>({
    required String path,
    required MapFromNetwork<T> mapper,
    Map<String, String>? headers,
    dynamic body,
    UserSessionModel? session,
    Map<String, dynamic>? query,
    bool shouldPrint = false,
    MockedResult? mockResult,
  }) async {
    try {
      if (mockResult != null) {
        return _mockResponse(mockResult, mapper);
      }

      final response = await _dio.post(
        path,
        data: body,
        queryParameters: query,
        options: Options(headers: headers, extra: {'session': session, 'shouldPrint': shouldPrint}),
      );

      return _processResponse(response, mapper);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<APIResult<T>> get<T>({
    required String path,
    Map<String, String>? headers,
    required MapFromNetwork<T> mapper,
    MockedResult? mockResult,
    Map<String, dynamic>? query,
    UserSessionModel? session,
    bool shouldPrint = false,
    dynamic body,
  }) async {
    try {
      if (mockResult != null) {
        return _mockResponse(mockResult, mapper);
      }

      final response = await _dio.get(
        path,
        queryParameters: query,
        data: body,
        options: Options(headers: headers, extra: {'session': session, 'shouldPrint': shouldPrint}),
      );

      return _processResponse(response, mapper);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<APIResult<T>> delete<T>({
    required String path,
    required MapFromNetwork<T> mapper,
    Map<String, String>? headers,
    dynamic body,
    UserSessionModel? session,
    dynamic query,
    bool shouldPrint = false,
    MockedResult? mockResult,
  }) async {
    try {
      if (mockResult != null) {
        return _mockResponse(mockResult, mapper);
      }

      final response = await _dio.delete(
        path,
        data: body,
        queryParameters: query is Map<String, dynamic> ? query : null,
        options: Options(headers: headers, extra: {'session': session, 'shouldPrint': shouldPrint}),
      );

      return _processResponse(response, mapper);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<APIResult<T>> put<T>({
    required String path,
    required MapFromNetwork<T> mapper,
    Map<String, String>? headers,
    dynamic body,
    UserSessionModel? session,
    dynamic query,
    bool shouldPrint = false,
    MockedResult? mockResult,
  }) async {
    try {
      if (mockResult != null) {
        return _mockResponse(mockResult, mapper);
      }

      final response = await _dio.put(
        path,
        data: body,
        queryParameters: query is Map<String, dynamic> ? query : null,
        options: Options(headers: headers, extra: {'session': session, 'shouldPrint': shouldPrint}),
      );

      return _processResponse(response, mapper);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<APIResult<T>> multipartRequest<T>({
    required String path,
    required HttpRequestType requestType,
    required MapFromNetwork<T> mapper,
    Map<String, String>? headers,
    Future<APIResult<T>?> Function(http.Response response)? plainHandler,
    List<MultipartRequestBody> files = const [],
    Map<String, dynamic> fields = const {},
    String? bearerToken,
    dynamic query,
    bool shouldPrint = false,
    MockedResult? mockResult,
  }) async {
    try {
      if (mockResult != null) {
        return _mockResponse(mockResult, mapper);
      }

      // Create FormData
      final formData = FormData();

      // Add files
      for (final file in files) {
        final filePath = file.filePath;
        final fileName = basename(filePath);

        final fileBytes = await File(filePath).readAsBytes();

        formData.files.add(MapEntry(file.key, MultipartFile.fromBytes(fileBytes, filename: fileName)));
      }

      // Add fields
      fields.forEach((key, value) {
        if (value != null) {
          if (value is Map || value is List) {
            formData.fields.add(MapEntry(key, jsonEncode(value)));
          } else {
            formData.fields.add(MapEntry(key, value.toString()));
          }
        }
      });

      // Prepare headers
      final finalHeaders = <String, dynamic>{
        if (headers != null) ...headers,
        if (bearerToken != null) NetworkConstants.authorizationHeader: 'Bearer $bearerToken',
      };

      // Make the request
      final response = await _dio.request(
        path,
        data: formData,
        queryParameters: query is Map<String, dynamic> ? query : null,
        options: Options(method: requestType.value, headers: finalHeaders, extra: {'shouldPrint': shouldPrint}),
      );

      // Convert Dio response to HTTP response if needed
      if (plainHandler != null) {
        final httpResponse = http.Response(
          jsonEncode(response.data),
          response.statusCode ?? 200,
          headers: _convertHeaders(response.headers.map),
        );
        final plainResult = await plainHandler(httpResponse);
        if (plainResult != null) {
          return plainResult;
        }
      }

      return _processResponse(response, mapper);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Map<String, String> _convertHeaders(Map<String, List<String>> headers) {
    final result = <String, String>{};
    headers.forEach((key, values) {
      if (values.isNotEmpty) {
        result[key] = values.join(', ');
      }
    });
    return result;
  }

  // Process regular responses
  APIResult<T> _processResponse<T>(Response response, MapFromNetwork<T> mapper) {
    // Convert response headers to the format expected by the mapper
    final Map<String, String> headerMap = {};
    response.headers.forEach((name, values) {
      if (values.isNotEmpty) {
        headerMap[name] = values.join(', ');
      }
    });

    final responseData =
        response.data is String && response.data.isNotEmpty
            ? jsonDecode(response.data) as Map<String, dynamic>
            : response.data as Map<String, dynamic>;

    // Check for error in successful response body
    // if (response.statusCode == 200 && responseData["result"] != null && responseData["result"]["success"] == false) {
    //   if (responseData["result"].containsKey('message') && responseData["result"]['message'] != null) {
    //     throw NetworkException(message: responseData["result"]['message']);
    //   }
    //   throw NetworkException(message: "Unknown Error");
    // }

    // Handle successful responses
    if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! <= 299) {
      final error = responseData['error'];

      if (error != null) {
        final code = error["code"];
        if (code == 100) {
          throw SessionException(message: error["message"]);
        }
        final errorMessage = error["data"]?["message"];
        throw errorMessage != null ? BaseException(message: errorMessage) : BaseException.unknownError();
      }

      final mappedData = mapper(responseData, headerMap);

      return APIResult<T>(
        status: responseData['status'] ?? 'success',
        data: mappedData,
        message: responseData['message'] ?? '',
      );
    }

    // Handle 401 errors
    if (response.statusCode == 401) {
      throw SessionException(message: responseData['message'] ?? 'SESSION EXCEPTION');
    }

    // Handle other errors
    if (responseData.containsKey('message') && responseData['message'] != null) {
      throw NetworkException(message: responseData['message']);
    }

    throw NetworkException(message: "Unknown Error");
  }

  // Handle mock results
  APIResult<T> _mockResponse<T>(MockedResult mockedResult, MapFromNetwork<T> mapper) {
    final responseData = {
      'result': mockedResult.result,
      'status': mockedResult.statusCode == 200 ? 'success' : 'error',
      'message': '',
    };

    final mappedData = mapper(responseData, mockedResult.headers);

    return APIResult<T>(status: responseData['status'], data: mappedData, message: responseData['message'] ?? '');
  }

  // Handle Dio errors
  Exception _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const ConnectionException();
    }

    if (e.response != null) {
      final statusCode = e.response!.statusCode ?? 0;

      if (statusCode == 401) {
        final responseData =
            e.response!.data is String && e.response!.data.isNotEmpty
                ? jsonDecode(e.response!.data) as Map<String, dynamic>
                : e.response!.data as Map<String, dynamic>?;

        return SessionException(message: responseData?['message'] ?? 'SESSION EXCEPTION');
      }

      if (e.response!.data != null) {
        dynamic responseData;

        if (e.response!.data is String && e.response!.data.isNotEmpty) {
          try {
            responseData = jsonDecode(e.response!.data) as Map<String, dynamic>;
          } catch (_) {
            responseData = {'message': e.response!.data};
          }
        } else {
          responseData = e.response!.data;
        }

        final message = responseData is Map ? responseData['message'] ?? e.message : e.message;

        return NetworkException(message: message);
      }
    }

    return NetworkException(message: e.message ?? "Unknown Error");
  }

  @override
  String get baseURL => ENV.instance.baseURL;

  @override
  String buildFullUrl(String extraPath) => "$baseURL$extraPath";
}

typedef JSON = dynamic;

typedef MapFromNetwork<T> = T Function(dynamic json, Map<String, String> headers);

class RPCRequestBody {
  const RPCRequestBody._();

  static Map<String, dynamic> toJson<T>(dynamic data) => {"jsonrpc": "2.0", "params": data};
}

class MockedResult {
  final dynamic result;
  final int statusCode;
  final Map<String, String> headers;

  const MockedResult({this.result, this.statusCode = 200, this.headers = const {}});
}

class MultiPartFileField {
  final String filepath;

  MultiPartFileField({required this.filepath});
}

enum HttpRequestType {
  get('GET'),
  post('POST'),
  put('PUT'),
  delete('DELETE');

  final String value;
  const HttpRequestType(this.value);

  static HttpRequestType fromEnumText(String enumText) {
    return values.firstWhere(
      (value) => value.value == enumText.toUpperCase(),
      orElse: () => throw ArgumentError('Invalid enumText of HttpRequestType: $enumText'),
    );
  }
}

abstract class APIClient {
  final String baseURL;

  const APIClient(this.baseURL);

  String buildFullUrl(String extraPath);

  Future<APIResult<T>> post<T>({
    required String path,
    required MapFromNetwork<T> mapper,
    Map<String, String>? headers,
    JSON? body,
    UserSessionModel? session,
    Map<String, dynamic>? query,
    bool shouldPrint = false,
    MockedResult? mockResult,
  });

  Future<APIResult<T>> get<T>({
    required String path,
    Map<String, String>? headers,
    required MapFromNetwork<T> mapper,
    Map<String, dynamic>? query,
    bool shouldPrint = false,
    UserSessionModel? session,
    JSON? body,
    MockedResult? mockResult,
  });

  Future<APIResult<T>> delete<T>({
    required String path,
    required MapFromNetwork<T> mapper,
    Map<String, String>? headers,
    JSON? body,
    UserSessionModel? session,
    Map<String, dynamic>? query,
    bool shouldPrint = false,
    MockedResult? mockResult,
  });

  Future<APIResult<T>> put<T>({
    required String path,
    required MapFromNetwork<T> mapper,
    Map<String, String>? headers,
    JSON? body,
    UserSessionModel? session,
    Map<String, dynamic>? query,
    bool shouldPrint = false,
    MockedResult? mockResult,
  });

  Future<APIResult<T>> multipartRequest<T>({
    required String path,
    required HttpRequestType requestType,
    required MapFromNetwork<T> mapper,
    Map<String, String>? headers,
    Future<APIResult<T>?> Function(http.Response response) plainHandler,
    Map<String, dynamic> fields = const {},
    String? bearerToken,
    query,
    bool shouldPrint = false,
    MockedResult? mockResult,
  });
}

class MultipartRequestBody {
  final String filePath;
  final String key;
  MultipartRequestBody({required this.filePath, required this.key});

  Map<String, dynamic> toJson() => {"key": key, "filePath": filePath};

  @override
  String toString() {
    return '''
    {
      key:$key,
      filePath:$filePath
    }
    ''';
  }
}

@module
abstract class HttpClientModule {
  http.Client httpClient() => http.Client();
}
