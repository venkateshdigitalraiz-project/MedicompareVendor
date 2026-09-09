import 'package:flutter/foundation.dart';
import '../api/api_endpoints.dart';
import 'app_environment.dart';

/// Clean Architecture Configuration Manager
/// Handles switching between Local (Debug/Dev) and Live (Release/Prod) environments cleanly.
class AppConfig {
  AppConfig._();

  static late AppEnvironment _environment;
  static late String _baseUrl;
  static late String _mediaBaseUrl;
  static bool _isInitialized = false;

  // Live / Release URLs
  static const String _liveBaseUrl = ApiEndpoints.releaseBaseUrl;
  static const String _liveMediaBaseUrl = ApiEndpoints.releaseMediaBaseUrl;

  // Local / Development Base URLs
  // Note: 
  // - Android Emulator to host: 'http://10.0.2.2:5000/api/v1'
  // - iOS Simulator / Web / Desktop: 'http://localhost:5000/api/v1'
  // - Physical Device: 'http://<YOUR_LOCAL_IP>:5000/api/v1' (e.g. 192.168.1.X)
  static const String _localBaseUrl = ApiEndpoints.localBaseUrl;
  static const String _localMediaBaseUrl = ApiEndpoints.localMediaBaseUrl;

  /// Initialize the environment configuration.
  ///
  /// Priority:
  /// 1. Explicit [env] passed directly (e.g. from main_dev.dart / main_prod.dart)
  /// 2. Compile-time `--dart-define=ENV=dev` or `--dart-define=ENV=prod`
  /// 3. Automatic detection: [kReleaseMode] -> Prod, Debug/Profile -> Dev
  static void init({
    AppEnvironment? env,
    String? customBaseUrl,
    String? customMediaUrl,
  }) {
    // Check compile-time defines if provided
    const definedEnv = String.fromEnvironment('ENV', defaultValue: '');
    const definedBaseUrl = String.fromEnvironment('BASE_URL', defaultValue: '');
    const definedMediaUrl = String.fromEnvironment('MEDIA_URL', defaultValue: '');

    if (env != null) {
      _environment = env;
    } else if (definedEnv.isNotEmpty) {
      final cleanEnv = definedEnv.trim().toLowerCase();
      _environment = (cleanEnv == 'prod' || cleanEnv == 'production' || cleanEnv == 'live')
          ? AppEnvironment.prod
          : AppEnvironment.dev;
    } else if (kReleaseMode) {
      _environment = AppEnvironment.prod;
    } else {
      _environment = AppEnvironment.dev;
    }

    // Set Base URL
    if (customBaseUrl != null && customBaseUrl.isNotEmpty) {
      _baseUrl = customBaseUrl;
    } else if (definedBaseUrl.isNotEmpty) {
      _baseUrl = definedBaseUrl;
    } else {
      _baseUrl = _environment == AppEnvironment.prod ? _liveBaseUrl : _localBaseUrl;
    }

    // Set Media Base URL
    if (customMediaUrl != null && customMediaUrl.isNotEmpty) {
      _mediaBaseUrl = customMediaUrl;
    } else if (definedMediaUrl.isNotEmpty) {
      _mediaBaseUrl = definedMediaUrl;
    } else {
      _mediaBaseUrl = _environment == AppEnvironment.prod ? _liveMediaBaseUrl : _localMediaBaseUrl;
    }

    _isInitialized = true;

    if (kDebugMode) {
      debugPrint('=============================================');
      debugPrint('🚀 [AppConfig] Active Environment: ${_environment.name}');
      debugPrint('🌐 [AppConfig] Base URL: $_baseUrl');
      debugPrint('🖼️ [AppConfig] Media Base URL: $_mediaBaseUrl');
      debugPrint('=============================================');
    }
  }

  static AppEnvironment get environment {
    if (!_isInitialized) init();
    return _environment;
  }

  static String get baseUrl {
    if (!_isInitialized) init();
    return _baseUrl;
  }

  static String get mediaBaseUrl {
    if (!_isInitialized) init();
    return _mediaBaseUrl;
  }

  static bool get isProduction => environment == AppEnvironment.prod;
  static bool get isDevelopment => environment == AppEnvironment.dev;
}
