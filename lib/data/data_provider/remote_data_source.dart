import 'package:dio/dio.dart';

import '../models/auth/login_model.dart';
import 'network_parser.dart';
import 'remote_url.dart';

// ---------------------------------------------------------------------------
// Abstract contract
// ---------------------------------------------------------------------------

abstract class RemoteDataSource {
  /// Authenticates the user with [body] credentials.
  Future<dynamic> login(LoginModel body);

  /// Logs the user out on the server side.
  Future<dynamic> logout();

  /// Requests new access + refresh tokens using a valid refresh token.
  Future<dynamic> refreshToken(String refreshToken);

  /// Fetches global application/website settings.
  Future<dynamic> getSetting();
}

// ---------------------------------------------------------------------------
// Implementation
// ---------------------------------------------------------------------------

class RemoteDataSourceImpl implements RemoteDataSource {
  /// [Dio] instance — injected via [DInjector] so it can be mocked in tests.
  final Dio dio;

  RemoteDataSourceImpl({required this.dio});

  // ── Auth ──────────────────────────────────────────────────────────────────

  @override
  Future<dynamic> login(LoginModel body) {
    return DioNetworkParser.call(
      () => dio.post(RemoteUrls.login, data: body.toMap()),
    );
  }

  @override
  Future<dynamic> logout() {
    // Token is now automatically attached by AuthInterceptor
    return DioNetworkParser.call(
      () => dio.post(RemoteUrls.logout),
    );
  }

  @override
  Future<dynamic> refreshToken(String refreshToken) {
    return DioNetworkParser.call(
      () => dio.post(
        RemoteUrls.refreshToken,
        data: {'refresh_token': refreshToken},
      ),
    );
  }

  // ── Settings ──────────────────────────────────────────────────────────────

  @override
  Future<dynamic> getSetting() {
    return DioNetworkParser.call(
      () => dio.get(RemoteUrls.websiteSetup),
    );
  }

  // ── Multipart helpers (for when you need file uploads) ───────────────────

  /// Sends a multipart/form-data [POST] request to [url] with optional
  /// [fields] and [files].
  ///
  /// Example:
  /// ```dart
  /// await remoteDataSource.postMultipart(
  ///   RemoteUrls.updateProfile,
  ///   fields: {'name': 'Alice'},
  ///   files: [MapEntry('avatar', await MultipartFile.fromFile('/path/img.png'))],
  /// );
  /// ```
  Future<dynamic> postMultipart(
    String url, {
    Map<String, dynamic>? fields,
    List<MapEntry<String, MultipartFile>>? files,
  }) {
    final formData = FormData.fromMap({
      if (fields != null) ...fields,
      if (files != null)
        for (final f in files) f.key: f.value,
    });

    return DioNetworkParser.call(
      () => dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      ),
    );
  }
}
