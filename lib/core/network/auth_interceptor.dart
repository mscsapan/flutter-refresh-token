import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/services/navigation_service.dart';
import '../../presentation/routes/route_names.dart';
import '../../data/data_provider/remote_url.dart';
import 'token_manager.dart';

/// Dio interceptor that:
///
/// 1. **Injects** the `Authorization: Bearer <token>` header on every request.
/// 2. **Catches 401** responses and attempts a **transparent token refresh**.
/// 3. **Retries** the original request with the new access token.
/// 4. **Force-logs-out** the user if the refresh also fails.
///
/// Uses [QueuedInterceptorsWrapper] so that when a refresh is in progress,
/// all subsequent 401 requests are queued and replayed with the new token —
/// preventing a thundering-herd of refresh calls.
class AuthInterceptor extends QueuedInterceptorsWrapper {
  /// A *separate* [Dio] instance used exclusively for the token-refresh call.
  /// Using the main instance would deadlock because queued interceptors block
  /// the request queue.
  final Dio _refreshDio;
  final TokenManager _tokenManager;

  /// Optional callback invoked when the session is truly expired (refresh
  /// failed). If not provided, the interceptor navigates to the login screen.
  final VoidCallback? onSessionExpired;

  static const _tag = 'AuthInterceptor';

  /// Whether a refresh is currently in progress. Prevents duplicate refresh
  /// calls when multiple 401s arrive simultaneously.
  bool _isRefreshing = false;

  AuthInterceptor({
    required Dio refreshDio,
    required TokenManager tokenManager,
    this.onSessionExpired,
  })  : _refreshDio = refreshDio,
        _tokenManager = tokenManager;

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
      _forceLogout();
      handler.next(err);
      return;
    }

    log('401 received — attempting token refresh', name: _tag);

    // Attempt refresh (only one refresh at a time thanks to QueuedInterceptors)
    final refreshed = await _attemptRefresh();

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
      _forceLogout();
      handler.next(err);
    }
  }

  // ── Private helpers ─────────────────────────────────────────────────────

  Future<bool> _attemptRefresh() async {
    if (_isRefreshing) return false;
    _isRefreshing = true;

    try {
      final refreshToken = await _tokenManager.refreshToken;

      if (refreshToken == null || refreshToken.isEmpty) {
        log('No refresh token available', name: _tag);
        return false;
      }

      log('Refreshing token…', name: _tag);

      final response = await _refreshDio.post(
        RemoteUrls.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final newAccessToken = data['access_token'] as String?;
        final newRefreshToken = data['refresh_token'] as String?;

        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          await _tokenManager.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken ?? refreshToken,
          );
          log('Token refreshed successfully', name: _tag);
          return true;
        }
      }

      log('Refresh response invalid', name: _tag);
      return false;
    } on DioException catch (e) {
      log('Refresh request failed: ${e.message}', name: _tag);
      return false;
    } catch (e) {
      log('Refresh error: $e', name: _tag);
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  /// Clears tokens and navigates to the login/auth screen.
  void _forceLogout() {
    log('Session expired — forcing logout', name: _tag);
    _tokenManager.clearTokens();

    if (onSessionExpired != null) {
      onSessionExpired!();
    } else {
      // Default: navigate to auth screen and clear the stack
      NavigationService.navigateToAndClearStack(RouteNames.authScreen);
    }
  }

  bool _isRefreshEndpoint(String path) {
    return path.contains(RemoteUrls.refreshToken);
  }
}
