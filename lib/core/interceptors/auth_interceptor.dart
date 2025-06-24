import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../constants/network_constants.dart';
import '../../data/models/auth_models.dart';

class AuthInterceptor extends Interceptor {
  static const String _tokenKey = 'auth_token';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Add ngrok header to bypass warning page
    options.headers[NetworkConstants.ngrokSkipBrowserWarning] = 'true';

    // Add other headers as needed
    options.headers[NetworkConstants.contentTypeHeader] = NetworkConstants.applicationJson;
    options.headers[NetworkConstants.acceptHeader] = NetworkConstants.applicationJson;

    // Skip auth for login/register endpoints (both old and new Supabase auth)
    final skipAuth =
        options.path.contains('/auth/login') ||
        options.path.contains('/auth/register') ||
        options.path.contains('/supabase-auth/login') ||
        options.path.contains('/supabase-auth/register') ||
        options.path.contains('/supabase-auth/refresh') ||
        options.path.contains('/health');

    if (!skipAuth) {
      // Add auth token if available
      final token = await _getStoredToken();
      if (token != null && !token.isExpired) {
        options.headers['Authorization'] = 'Bearer ${token.accessToken}';
      }
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 errors by clearing stored token
    if (err.response?.statusCode == 401) {
      await _clearStoredToken();
    }

    handler.next(err);
  }

  Future<AuthTokenModel?> _getStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tokenJson = prefs.getString(_tokenKey);

      if (tokenJson != null) {
        final tokenMap = jsonDecode(tokenJson) as Map<String, dynamic>;
        return AuthTokenModel.fromJson(tokenMap);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _clearStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
