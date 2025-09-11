enum Environment {
  development,
  staging,
  production,
}

class EnvConfig {
  static Environment _environment = Environment.development;
  
  static Environment get environment => _environment;
  
  static void setEnvironment(Environment env) {
    _environment = env;
  }
  
  static String get baseUrl {
    switch (_environment) {
      case Environment.development:
        return 'https://dev-api.yourapp.com/api/v1';
      case Environment.staging:
        return 'https://staging-api.yourapp.com/api/v1';
      case Environment.production:
        return 'https://api.yourapp.com/api/v1';
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
}
