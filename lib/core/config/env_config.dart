import '../../data/data_provider/remote_url.dart';

enum Environment { development, staging, production }

class EnvConfig {
  static Environment _environment = Environment.development;

  static Environment get environment => _environment;

  static void setEnvironment(Environment env) => _environment = env;


  static String get baseUrl {
    switch (_environment) {
      case Environment.development:
        return RemoteUrls.getDevUrl;
      case Environment.staging:
        return RemoteUrls.getStagingUrl;
      case Environment.production:
        return RemoteUrls.getProductionUrl;
    }
  }

  static String get appName {
    switch (_environment) {
      case Environment.development:
        return 'Flutter Template Dev';
      case Environment.staging:
        return 'Flutter Template Staging';
      case Environment.production:
        return 'Flutter Template';
    }
  }

  static bool get enableDebugMode {
    return _environment != Environment.production;
  }

  static Duration get connectionTimeout => const Duration(seconds: 30);
  static Duration get receiveTimeout => const Duration(seconds: 30);

  // ── Refresh Token ──────────────────────────────────────────────────────

  /// Set to `true` once your backend supports the `POST /refresh-token`
  /// endpoint. When `false`, the [AuthInterceptor] will NOT attempt to refresh
  /// expired tokens — it will simply attach the access token to requests and
  /// let 401 errors propagate so the UI can handle them (redirect to login).
  ///
  /// Toggle this flag per environment:
  ///  - `false` → backend doesn't have refresh-token endpoint yet
  ///  - `true`  → backend supports refresh-token, enable silent refresh
  static bool get enableRefreshToken {
    switch (_environment) {
      case Environment.development:
        return true; // ← Change to true once backend supports it
      case Environment.staging:
        return false; // ← Change to true once backend supports it
      case Environment.production:
        return true; // ← Change to true once backend supports it
    }
  }

  // ── Retry ──────────────────────────────────────────────────────────────

  /// Number of times a failed network request will be automatically retried
  /// when connectivity is restored.
  static int get maxRetryAttempts => 3;
}
