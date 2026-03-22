import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../config/env_config.dart';
import 'auth_interceptor.dart';
import 'token_manager.dart';

/// Factory that creates and configures [Dio] instances.
///
/// - Base URL and timeouts are driven by [EnvConfig].
/// - Default headers (`Accept`, `Content-Type`, `X-Requested-With`) are set
///   globally so individual methods don't need to repeat them.
/// - In non-production environments a [PrettyDioLogger] interceptor is added
///   for structured, coloured request/response logging.
/// - [AuthInterceptor] automatically injects bearer tokens and refreshes
///   expired tokens transparently.
class DioClient {
  DioClient._();

  /// The single app-wide [Dio] instance.
  static Dio? _instance;

  /// Returns the singleton [Dio] instance, creating it on first access.
  ///
  /// The [AuthInterceptor] is automatically wired so:
  ///  • every request gets the `Authorization` header
  ///  • 401 responses trigger a silent token refresh + retry
  ///  • if the refresh fails, the user is force-logged-out
  static Dio create() {
    if (_instance != null) return _instance!;

    final dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.baseUrl,
        connectTimeout: EnvConfig.connectionTimeout,
        receiveTimeout: EnvConfig.receiveTimeout,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
        responseType: ResponseType.json,
      ),
    );

    // ── Auth interceptor ──────────────────────────────────────────────────
    // Uses a *separate* Dio instance for the refresh call to avoid deadlocks
    // with QueuedInterceptorsWrapper.
    final refreshDio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.baseUrl,
        connectTimeout: EnvConfig.connectionTimeout,
        receiveTimeout: EnvConfig.receiveTimeout,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
        responseType: ResponseType.json,
      ),
    );

    dio.interceptors.add(
      AuthInterceptor(
        refreshDio: refreshDio,
        tokenManager: TokenManager.instance,
      ),
    );

    // ── Pretty logger — only in non-production ────────────────────────────
    if (EnvConfig.enableDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
        ),
      );
    }

    // ── Generic error interceptor for structured logging ──────────────────
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, ErrorInterceptorHandler handler) {
          log(
            'DioError [${e.type}]: ${e.message}',
            name: 'DioClient',
            error: e,
          );
          handler.next(e);
        },
      ),
    );

    _instance = dio;
    return dio;
  }

  /// Resets the singleton so the next [create] call builds a fresh instance.
  ///
  /// Call this on logout so that when the user logs back in, a new [Dio]
  /// instance is created with clean state.
  static void reset() {
    _instance?.close();
    _instance = null;
  }
}
