import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../config/env_config.dart';
import 'auth_interceptor.dart';
import 'retry_interceptor.dart';
import 'token_manager.dart';
import 'token_refresh_service.dart';

/// Factory that creates and configures [Dio] instances.
///
/// - Base URL and timeouts are driven by [EnvConfig].
/// - Default headers (`Accept`, `Content-Type`, `X-Requested-With`) are set
///   globally so individual methods don't need to repeat them.
/// - In non-production environments a [PrettyDioLogger] interceptor is added
///   for structured, coloured request/response logging.
/// - [AuthInterceptor] automatically injects bearer tokens and delegates token
///   refresh to [TokenRefreshService] (when enabled via [EnvConfig.enableRefreshToken]).
/// - [RetryInterceptor] automatically retries failed requests when the device
///   regains connectivity.
class DioClient {
  DioClient._();

  /// The single app-wide [Dio] instance.
  static Dio? _instance;

  /// The single [TokenRefreshService] instance shared with [AuthInterceptor]
  /// and [AuthSessionCubit].
  static TokenRefreshService? _tokenRefreshService;

  /// Returns the singleton [TokenRefreshService].
  ///
  /// Created alongside the [Dio] instance so that [AuthSessionCubit] can be
  /// wired to the same service instance via DI.
  static TokenRefreshService get tokenRefreshService {
    if (_tokenRefreshService == null) {
      // Trigger creation of both singletons together
      create();
    }
    return _tokenRefreshService!;
  }

  /// Returns the singleton [Dio] instance, creating it on first access.
  ///
  /// Interceptor order matters:
  ///  1. **AuthInterceptor** — attaches token + delegates 401 refresh to
  ///     [TokenRefreshService]
  ///  2. **RetryInterceptor** — retries on network errors (waits for connectivity)
  ///  3. **PrettyDioLogger** — logs requests/responses (debug only)
  ///  4. **Error logger** — structured error logging
  static Dio create() {
    if (_instance != null) return _instance ?? Dio();

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

    // ── Shared refresh Dio (used by both TokenRefreshService and for retrying) ─
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

    // ── Create the TokenRefreshService singleton ───────────────────────────
    // Always create it so AuthSessionCubit can be wired in DI regardless of
    // whether EnvConfig.enableRefreshToken is true.
    _tokenRefreshService = TokenRefreshService(
      refreshDio: refreshDio,
      tokenManager: TokenManager.instance,
    );

    // ── 1. Auth interceptor ───────────────────────────────────────────────
    if (EnvConfig.enableRefreshToken) {
      // Full auth interceptor: injects token + delegates refresh to
      // TokenRefreshService (which uses UserResponseModel + DioNetworkParser)
      dio.interceptors.add(
        AuthInterceptor(
          refreshDio: refreshDio,
          tokenManager: TokenManager.instance,
          tokenRefreshService: _tokenRefreshService!,
        ),
      );
    } else {
      // Backend doesn't support refresh tokens yet.
      // Still inject the access token on every request but DON'T attempt
      // refresh on 401 — just notify the session as expired so the
      // AuthSessionCubit can handle the UI transition.
      dio.interceptors.add(
        _TokenOnlyInterceptor(
          tokenManager: TokenManager.instance,
          tokenRefreshService: _tokenRefreshService!,
        ),
      );
    }

    // ── 2. Retry interceptor — auto-retry on network errors ───────────────
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        connectivity: Connectivity(),
        maxRetries: EnvConfig.maxRetryAttempts,
      ),
    );

    // ── 3. Pretty logger — only in non-production ─────────────────────────
    if (EnvConfig.enableDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          //enabled: kDebugMode,
        ),
      );
    }

    // ── 4. Generic error interceptor for structured logging ────────────────
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
    _tokenRefreshService?.dispose();
    _tokenRefreshService = null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lightweight interceptor — inject token only, no refresh logic
// ─────────────────────────────────────────────────────────────────────────────

/// Used when the backend does NOT support refresh tokens.
///
/// Simply attaches `Authorization: Bearer <token>` to every request.
/// On 401, notifies [TokenRefreshService] so [AuthSessionCubit] emits
/// [AuthSessionExpired] and the UI navigates to the login screen.
class _TokenOnlyInterceptor extends Interceptor {
  final TokenManager _tokenManager;
  final TokenRefreshService _tokenRefreshService;

  _TokenOnlyInterceptor({
    required TokenManager tokenManager,
    required TokenRefreshService tokenRefreshService,
  })  : _tokenManager = tokenManager,
        _tokenRefreshService = tokenRefreshService;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenManager.accessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Notify the AuthSessionCubit via the shared service stream
      _tokenRefreshService.notifySessionExpired();
    }
    handler.next(err);
  }
}
