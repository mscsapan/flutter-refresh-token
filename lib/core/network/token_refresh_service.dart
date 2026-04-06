import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';

import '../../data/data_provider/network_parser.dart';
import '../../data/data_provider/remote_url.dart';
import '../../data/models/auth/login_response_model.dart';
import 'token_manager.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Session events emitted by TokenRefreshService
// ─────────────────────────────────────────────────────────────────────────────

/// Events broadcast by [TokenRefreshService] to notify listeners of session
/// state changes (e.g. token refreshed, session expired).
enum SessionEvent { refreshed, expired }

// ─────────────────────────────────────────────────────────────────────────────
// TokenRefreshService
// ─────────────────────────────────────────────────────────────────────────────

/// Network-layer service that handles token refresh using proper model parsing.
///
/// Replaces the hard-coded Dio call that was previously inside
/// [AuthInterceptor._attemptRefresh]. The service:
///
///  1. Uses [UserResponseModel.fromMap] for response parsing — consistent with
///     the rest of the data layer.
///  2. Delegates token persistence to [TokenManager].
///  3. Broadcasts [SessionEvent]s so that the presentation layer
///     ([AuthSessionCubit]) can react to session changes.
///
/// Uses a **separate** [Dio] instance (`_refreshDio`) that has no interceptors,
/// preventing deadlocks with [QueuedInterceptorsWrapper].
class TokenRefreshService {
  final Dio _refreshDio;
  final TokenManager _tokenManager;

  static const _tag = 'TokenRefreshService';

  /// Whether a refresh is currently in progress. Prevents duplicate refresh
  /// calls when multiple 401s arrive simultaneously.
  bool _isRefreshing = false;

  // ── Session event stream ─────────────────────────────────────────────────

  final _sessionController = StreamController<SessionEvent>.broadcast();

  /// Stream that emits [SessionEvent.refreshed] on successful token refresh
  /// and [SessionEvent.expired] when the session cannot be recovered.
  Stream<SessionEvent> get sessionStream => _sessionController.stream;

  TokenRefreshService({
    required Dio refreshDio,
    required TokenManager tokenManager,
  }) : _refreshDio = refreshDio,
       _tokenManager = tokenManager;

  // ── Refresh logic ────────────────────────────────────────────────────────

  /// Attempts to refresh the access token using the stored refresh token.
  ///
  /// Returns `true` if the refresh succeeded and new tokens were saved.
  /// Returns `false` on any failure (missing token, network error, invalid
  /// response).
  ///
  /// On success, broadcasts [SessionEvent.refreshed].
  Future<bool> attemptRefresh() async {
    if (_isRefreshing) return false;
    _isRefreshing = true;

    try {
      final refreshToken = await _tokenManager.refreshToken;

      if (refreshToken == null || refreshToken.isEmpty) {
        log('No refresh token available', name: _tag);
        return false;
      }

      log('Refreshing token…', name: _tag);

      // ── Use DioNetworkParser for consistent error handling ──────────────
      final result = await DioNetworkParser.call(
        () => _refreshDio.post(
          RemoteUrls.refreshToken,
          data: {'refresh_token': refreshToken},
        ),
      );

      // ── Parse with UserResponseModel — same as login / other auth calls ─
      final userResponse = LoginResponseModel.fromMap(
        result is Map<String, dynamic> ? result : {},
      );

      if (userResponse.accessToken.isNotEmpty) {
        await _tokenManager.saveTokens(
          accessToken: userResponse.accessToken,
          refreshToken: userResponse.refreshToken.isNotEmpty
              ? userResponse.refreshToken
              : refreshToken,
        );

        log('Token refreshed successfully', name: _tag);
        _sessionController.add(SessionEvent.refreshed);
        return true;
      }

      log('Refresh response invalid — empty access token', name: _tag);
      return false;
    } catch (e) {
      log('Refresh error: $e', name: _tag);
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  // ── Session expiry notification ──────────────────────────────────────────

  /// Call when the session is truly unrecoverable (refresh failed or refresh
  /// token is missing). Broadcasts [SessionEvent.expired] so that the
  /// [AuthSessionCubit] can emit the appropriate UI state.
  void notifySessionExpired() {
    log('Session expired — notifying listeners', name: _tag);
    _tokenManager.clearTokens();
    _sessionController.add(SessionEvent.expired);
  }

  /// Releases the internal [StreamController]. Call when the app is disposed.
  void dispose() {
    _sessionController.close();
  }
}
