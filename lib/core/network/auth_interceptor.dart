import 'dart:developer';

import 'package:dio/dio.dart';

import '../../data/data_provider/remote_url.dart';
import 'token_manager.dart';
import 'token_refresh_service.dart';

/// Dio interceptor that:
///
/// 1. **Injects** the `Authorization: Bearer <token>` header on every request.
/// 2. **Catches 401** responses and delegates token refresh to
///    [TokenRefreshService] (which uses [UserResponseModel] for parsing).
/// 3. **Retries** the original request with the new access token.
/// 4. **Notifies** the [AuthSessionCubit] (via [TokenRefreshService]) when the
///    session is truly expired so the UI can react.
///
/// Uses [QueuedInterceptorsWrapper] so that when a refresh is in progress,
/// all subsequent 401 requests are queued and replayed with the new token —
/// preventing a thundering-herd of refresh calls.
class AuthInterceptor extends QueuedInterceptorsWrapper {
  /// A *separate* [Dio] instance used exclusively for retrying the original
  /// request after a successful token refresh.
  /// Using the main instance would deadlock because queued interceptors block
  /// the request queue.
  final Dio _refreshDio;
  final TokenManager _tokenManager;

  /// The service that handles the actual token-refresh call using
  /// [UserResponseModel.fromMap] and [DioNetworkParser] — keeping the
  /// interceptor free of hard-coded API logic.
  final TokenRefreshService _tokenRefreshService;

  static const _tag = 'AuthInterceptor';

  AuthInterceptor({
    required Dio refreshDio,
    required TokenManager tokenManager,
    required TokenRefreshService tokenRefreshService,
  })  : _refreshDio = refreshDio,
        _tokenManager = tokenManager,
        _tokenRefreshService = tokenRefreshService;

  // ── Attach token to every outgoing request ──────────────────────────────

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip attaching token for the refresh endpoint itself
    if (_isRefreshEndpoint(options.path)) {
      handler.next(options);
      return;
    }

    final token = await _tokenManager.accessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  // ── Handle 401 errors: attempt token refresh ────────────────────────────

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Only intercept 401 Unauthorized
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    // Don't attempt refresh if the failed request IS the refresh call
    if (_isRefreshEndpoint(err.requestOptions.path)) {
      _tokenRefreshService.notifySessionExpired();
      handler.next(err);
      return;
    }

    log('401 received — delegating to TokenRefreshService', name: _tag);

    // Delegate refresh to the service (uses UserResponseModel + DioNetworkParser)
    final refreshed = await _tokenRefreshService.attemptRefresh();

    if (refreshed) {
      // Retry the original request with the new token
      try {
        final newToken = await _tokenManager.accessToken;
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer $newToken';

        final response = await _refreshDio.fetch(opts);
        handler.resolve(response);
      } catch (retryError) {
        handler.next(err);
      }
    } else {
      _tokenRefreshService.notifySessionExpired();
      handler.next(err);
    }
  }

  // ── Private helpers ─────────────────────────────────────────────────────

  bool _isRefreshEndpoint(String path) {
    return path.contains(RemoteUrls.refreshToken);
  }
}
