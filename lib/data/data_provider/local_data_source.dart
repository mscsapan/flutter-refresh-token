import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../core/exceptions/exceptions.dart';
import '../../presentation/utils/k_string.dart';
import '../models/auth/login_response_model.dart';

// ---------------------------------------------------------------------------
// Abstract contract
// ---------------------------------------------------------------------------

abstract class LocalDataSource {
  /// Whether the on-boarding flow has already been completed.
  bool checkOnBoarding();

  /// Marks the on-boarding flow as completed.
  Future<bool> cachedOnBoarding();

  /// Persists [userResponseModel] to local storage.
  Future<bool> cacheUserResponse(LoginResponseModel? userResponseModel);

  /// Returns the previously cached user info.
  ///
  /// Throws [DatabaseException] if no user has been cached.
  LoginResponseModel getExistingUserInfo();

  /// Removes the cached user response (on logout).
  Future<bool> clearUserResponse();

  /// Updates only token fields for the cached user session.
  ///
  /// Returns `false` when no cached user exists.
  Future<bool> updateCachedUserTokens({
    required String accessToken,
    required String refreshToken,
  });

  /// Stores [email] and [password] securely.
  ///
  /// ⚠️ Credentials are written to [FlutterSecureStorage] (Keychain on iOS,
  /// EncryptedSharedPreferences on Android) — NOT plain SharedPreferences.
  Future<void> saveCredentials({
    required String email,
    required String password,
  });

  /// Removes stored credentials (on logout / "forget me").
  Future<void> removeCredentials();

  /// Returns the stored email, or `null` if none is saved.
  Future<String?> getSavedEmail();

  /// Returns the stored password, or `null` if none is saved.
  Future<String?> getSavedPassword();
}

// ---------------------------------------------------------------------------
// Implementation
// ---------------------------------------------------------------------------

class LocalDataSourceImpl implements LocalDataSource {
  final SharedPreferences sharedPreferences;

  /// Secure storage for sensitive data (tokens, credentials).
  final FlutterSecureStorage secureStorage;

  LocalDataSourceImpl({
    required this.sharedPreferences,
    required this.secureStorage,
  });

  // ── On-boarding ──────────────────────────────────────────────────────────

  @override
  Future<bool> cachedOnBoarding() =>
      sharedPreferences.setBool(KString.cachedOnBoardingKey, true);

  @override
  bool checkOnBoarding() {
    final value = sharedPreferences.getBool(KString.cachedOnBoardingKey);
    if (value != null) return true;
    throw const DatabaseException('On-boarding not completed yet');
  }

  // ── User session ─────────────────────────────────────────────────────────

  @override
  Future<bool> cacheUserResponse(LoginResponseModel? userResponseModel) =>
      sharedPreferences.setString(
        KString.getExistingUserResponseKey,
        userResponseModel?.toJson()??'',
      );

  @override
  LoginResponseModel getExistingUserInfo() {
    final jsonData = sharedPreferences.getString(KString.getExistingUserResponseKey);
    if (jsonData != null) return LoginResponseModel.fromJson(jsonData);
    throw const DatabaseException('No cached user found');
  }

  @override
  Future<bool> clearUserResponse() =>
      sharedPreferences.remove(KString.getExistingUserResponseKey);

  @override
  Future<bool> updateCachedUserTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final jsonData = sharedPreferences.getString(KString.getExistingUserResponseKey);
    if (jsonData == null || jsonData.isEmpty) return false;

    final existing = LoginResponseModel.fromJson(jsonData);
    final updated = existing.copyWith(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    return sharedPreferences.setString(
      KString.getExistingUserResponseKey,
      updated.toJson(),
    );
  }

  // ── Secure credentials ───────────────────────────────────────────────────

  @override
  Future<void> saveCredentials({
    required String email,
    required String password,
  }) async {
    // Write both in parallel for speed.
    await Future.wait([
      secureStorage.write(key: AppConstants.savedEmailKey, value: email),
      secureStorage.write(key: AppConstants.savedPasswordKey, value: password),
    ]);
  }

  @override
  Future<void> removeCredentials() async {
    await Future.wait([
      secureStorage.delete(key: AppConstants.savedEmailKey),
      secureStorage.delete(key: AppConstants.savedPasswordKey),
    ]);
  }

  @override
  Future<String?> getSavedEmail() =>
      secureStorage.read(key: AppConstants.savedEmailKey);

  @override
  Future<String?> getSavedPassword() =>
      secureStorage.read(key: AppConstants.savedPasswordKey);
}
