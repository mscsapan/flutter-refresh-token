/// All API endpoint paths.
///
/// Since [DioClient] sets `BaseOptions.baseUrl` from [EnvConfig.baseUrl],
/// every constant here is a **relative** path (no leading slash needed
/// when Dio appends them via [Dio.get] / [Dio.post]).
///
/// Absolute helpers (e.g. [imageUrl]) keep the root URL for constructing
/// fully-qualified asset URLs that are NOT sent through the Dio client.
class RemoteUrls {
  RemoteUrls._();

  // ── Root & base used only for asset URLs ──────────────────────────────────
  // Note: the API base URL itself is now controlled by EnvConfig.baseUrl.
  // static const String _rootUrl = 'https://server.discountbazar.ae/';
  static const String _rootUrl = 'http://192.168.0.103:3000/';

  static const String baseUrl = '${_rootUrl}api/';

  static String get getDevUrl => baseUrl;
  static String get getStagingUrl => baseUrl;
  static String get getProductionUrl => baseUrl;

  // ── Auth endpoints ────────────────────────────────────────────────────────
  static const String register = 'register';
  static const String login    = 'login';

  static const String logout  = 'user/logout';
  static const String refreshToken   = 'refresh-token';

  static const String sendForgetPassword = 'send-forget-password';
  static const String resendRegisterCode = 'resend-register-code';
  static const String storeResetPassword = 'store-reset-password';
  static const String userVerification   = 'user-verification';
  static const String resendVerification = 'resend-register';

  static String changePassword(String token) => 'user/update-password?token=$token';

  // ── Settings ──────────────────────────────────────────────────────────────
  static const String websiteSetup = 'get-setting';
  static const String getHome = 'get-todos';

  // ── Asset helpers (absolute, not sent through Dio) ────────────────────────
  /// Converts a server-relative image path to a fully-qualified URL.
  static String imageUrl(String relativePath) => _rootUrl + relativePath;
}
