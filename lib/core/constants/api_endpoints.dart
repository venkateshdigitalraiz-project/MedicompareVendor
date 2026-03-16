import 'package:flutter/foundation.dart';

class ApiEndpoints {
  static const String _releaseBaseUrl = 'https://api.medicompares.com/api/v1';
  // static const String _debugBaseUrl = 'http://192.168.0.161:9001/api/v1';

  static String get baseUrl => kReleaseMode ? _releaseBaseUrl : _releaseBaseUrl;

  static String get register => '$baseUrl/vendor/auth/register';
  static String get login => '$baseUrl/vendor/auth/login';
  static String get stepOneUpdate => '$baseUrl/vendor/profile/step_one_update';
  static String get stepTwoUpdate => '$baseUrl/vendor/profile/step_two';
  static String get dashboard => '$baseUrl/vendor/dashboard';
  static String get slotTimings => '$baseUrl/vendor/vendor-timings/list';
  static String get pincodeList => '$baseUrl/vendor/pincode/list';
  static String get orderList => '$baseUrl/vendor/order/list';
  static String get orderDetails => '$baseUrl/vendor/order/details';
  static String get leadsList => '$baseUrl/vendor/leads/list';
}
