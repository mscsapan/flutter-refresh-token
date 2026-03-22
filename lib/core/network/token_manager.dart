import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Centralized, singleton-style token manager backed by [FlutterSecureStorage].
///
/// Keeps an in-memory cache so Dio interceptors can read the token
/// synchronously while still persisting to secure storage for restarts.
///
/// Usage from the Dio [AuthInterceptor]:
/// ```dart
/// final token = await TokenManager.instance.accessToken;
/// ```
class TokenManager {
  TokenManager._();

  static final TokenManager instance = TokenManager._();

  static const _tag = 'TokenManager';
  static const _accessTokenKey = 'secure_access_token';
  static const _refreshTokenKey = 'secure_refresh_token';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // ── In-memory cache ──────────────────────────────────────────────────────
  String? _cachedAccessToken;
  String? _cachedRefreshToken;

  // ── Access Token ─────────────────────────────────────────────────────────

  /// Returns the current access token (reads from cache first, falls back to
  /// secure storage).
  Future<String?> get accessToken async {
    if (_cachedAccessToken != null) return _cachedAccessToken;
    _cachedAccessToken = await _secureStorage.read(key: _accessTokenKey);
    return _cachedAccessToken;
  }

  /// Persists a new access token.
  Future<void> saveAccessToken(String token) async {
    _cachedAccessToken = token;
    await _secureStorage.write(key: _accessTokenKey, value: token);
    log('Access token saved', name: _tag);
  }

  // ── Refresh Token ────────────────────────────────────────────────────────

  /// Returns the current refresh token.
  Future<String?> get refreshToken async {
    if (_cachedRefreshToken != null) return _cachedRefreshToken;
    _cachedRefreshToken = await _secureStorage.read(key: _refreshTokenKey);
    return _cachedRefreshToken;
  }

  /// Persists a new refresh token.
  Future<void> saveRefreshToken(String token) async {
    _cachedRefreshToken = token;
    await _secureStorage.write(key: _refreshTokenKey, value: token);
    log('Refresh token saved', name: _tag);
  }

  // ── Save both at once ────────────────────────────────────────────────────

  /// Convenience method to persist both tokens after login / token refresh.
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      saveAccessToken(accessToken),
      saveRefreshToken(refreshToken),
    ]);
  }

  // ── Clear (logout) ──────────────────────────────────────────────────────

  /// Removes both tokens from memory and secure storage.
  Future<void> clearTokens() async {
    _cachedAccessToken = null;
    _cachedRefreshToken = null;
    await Future.wait([
      _secureStorage.delete(key: _accessTokenKey),
      _secureStorage.delete(key: _refreshTokenKey),
    ]);
    log('Tokens cleared', name: _tag);
  }

  /// Whether we have a cached access token (synchronous check).
  bool get hasToken => _cachedAccessToken != null && _cachedAccessToken!.isNotEmpty;

  /// Loads tokens from secure storage into memory. Call once at app start.
  Future<void> init() async {
    _cachedAccessToken = await _secureStorage.read(key: _accessTokenKey);
    _cachedRefreshToken = await _secureStorage.read(key: _refreshTokenKey);
    log('TokenManager initialized (has token: $hasToken)', name: _tag);
  }
}
