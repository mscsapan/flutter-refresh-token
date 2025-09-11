import 'dart:developer' as developer;
import '../config/env_config.dart';

class Logger {
  static const String _name = 'FlutterTemplate';
  
  static void debug(String message, {String? tag}) {
    if (EnvConfig.enableDebugMode) {
      final logTag = tag ?? 'DEBUG';
      developer.log('[$logTag] $message', name: _name, level: 500);
    }
  }
  
  static void info(String message, {String? tag}) {
    if (EnvConfig.enableDebugMode) {
      final logTag = tag ?? 'INFO';
      developer.log('[$logTag] $message', name: _name, level: 800);
    }
  }
  
  static void warning(String message, {String? tag}) {
    if (EnvConfig.enableDebugMode) {
      final logTag = tag ?? 'WARNING';
      developer.log('[$logTag] $message', name: _name, level: 900);
    }
  }
  
  static void error(String message, {String? tag, Object? error}) {
    if (EnvConfig.enableDebugMode) {
      final logTag = tag ?? 'ERROR';
      developer.log('[$logTag] $message', name: _name, level: 1000, error: error);
    }
  }
  
  // Specialized logging methods
  static void network(String message) => debug(message, tag: 'NETWORK');
  static void bloc(String message) => debug(message, tag: 'BLOC');
  static void navigation(String message) => debug(message, tag: 'NAVIGATION');
}
