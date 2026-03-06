import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../config/env_config.dart';

/// Factory that creates and configures a [Dio] instance.
///
/// Usage:
/// ```dart
/// final dio = DioClient.create();
/// ```
///
/// - Base URL and timeouts are driven by [EnvConfig].
/// - Default headers (`Accept`, `Content-Type`, `X-Requested-With`) are set
///   globally so individual methods don't need to repeat them.
/// - In non-production environments a [PrettyDioLogger] interceptor is added
///   for structured, coloured request/response logging.
/// - An [AuthInterceptor] can be extended to automatically inject bearer
///   tokens; see [DioClient.withToken].
class DioClient {
  DioClient._();

  /// Creates a bare [Dio] instance with default options.
  static Dio create({String? token}) {
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

    // Add token if provided
    if (token != null && token.isNotEmpty) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }

    // Pretty logger — only in non-production environments
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

    // Generic error interceptor for structured logging
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

    return dio;
  }

  /// Convenience factory that injects the bearer [token] into every request.
  static Dio withToken(String token) => create(token: token);
}
