import 'dart:async';

import 'package:dio/dio.dart';

import 'api_exception.dart';
import '../storage/token_storage.dart';

/// Base URL of the VALIDIKA API. Override at build/run time with
/// `--dart-define=API_BASE_URL=http://10.0.2.2:8002/api/v1` (Android emulator)
/// or another environment's URL. Defaults to the VALIDIKA VPS API.
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://72.62.1.143/api/v1',
);

/// Thin wrapper around Dio that injects the bearer token on every request,
/// normalizes errors into [ApiException], and broadcasts session-expired
/// events so the UI can react (redirect to login) without every repository
/// having to know about navigation.
class ApiClient {
  ApiClient({required TokenStorage tokenStorage, Dio? dio})
    : _tokenStorage = tokenStorage,
      _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: apiBaseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 20),
              headers: const {'Accept': 'application/json'},
            ),
          ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await _tokenStorage.clear();
            _unauthorizedController.add(null);
          }
          handler.next(error);
        },
      ),
    );
  }

  final Dio _dio;
  final TokenStorage _tokenStorage;
  final StreamController<void> _unauthorizedController = StreamController<void>.broadcast();

  /// Fires whenever a request comes back 401, meaning the session expired
  /// or the token was revoked server-side.
  Stream<void> get onUnauthorized => _unauthorizedController.stream;

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters}) =>
      _guard(() => _dio.get<T>(path, queryParameters: queryParameters));

  Future<Response<T>> post<T>(String path, {Object? data, Map<String, dynamic>? queryParameters}) =>
      _guard(() => _dio.post<T>(path, data: data, queryParameters: queryParameters));

  Future<Response<T>> put<T>(String path, {Object? data}) => _guard(() => _dio.put<T>(path, data: data));

  Future<Response<T>> delete<T>(String path) => _guard(() => _dio.delete<T>(path));

  Future<Response<T>> _guard<T>(Future<Response<T>> Function() request) async {
    try {
      return await request();
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  void dispose() {
    _unauthorizedController.close();
  }
}
