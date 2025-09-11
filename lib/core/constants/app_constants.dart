class AppConstants {
  // App Info
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';
  
  // API Related
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const int maxRetryAttempts = 3;
  
  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String isFirstTimeKey = 'is_first_time';
  static const String rememberMeKey = 'remember_me';
  static const String savedEmailKey = 'saved_email';
  static const String savedPasswordKey = 'saved_password';
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 8.0;
  static const double iconSize = 24.0;
  static const double avatarSize = 40.0;
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 400);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
  static const int maxEmailLength = 100;
  
  // Regex Patterns
  static const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phonePattern = r'^[+]?[0-9]{10,15}$';
  
  // Error Messages
  static const String networkErrorMessage = 'Please check your internet connection';
  static const String serverErrorMessage = 'Server error occurred. Please try again';
  static const String unauthorizedMessage = 'Session expired. Please login again';
  static const String validationErrorMessage = 'Please fix the form errors';
}
