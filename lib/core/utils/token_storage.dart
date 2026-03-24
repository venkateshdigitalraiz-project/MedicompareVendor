import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _tokenKey = 'auth_token';
  static const String _vendorIdKey = 'vendor_id';

  static const String _rememberMeKey = 'remember_me';
  static const String _savedEmailKey = 'saved_email';
  static const String _savedPasswordKey = 'saved_password';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveVendorId(String vendorId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_vendorIdKey, vendorId);
  }

  static Future<String?> getVendorId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_vendorIdKey);
  }

  static Future<void> saveCredentials(String email, String password, bool remember) async {
    final prefs = await SharedPreferences.getInstance();
    if (remember) {
      await prefs.setBool(_rememberMeKey, true);
      await prefs.setString(_savedEmailKey, email);
      await prefs.setString(_savedPasswordKey, password);
    } else {
      await prefs.setBool(_rememberMeKey, false);
      await prefs.remove(_savedEmailKey);
      await prefs.remove(_savedPasswordKey);
    }
  }

  static Future<Map<String, dynamic>> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'rememberMe': prefs.getBool(_rememberMeKey) ?? false,
      'email': prefs.getString(_savedEmailKey),
      'password': prefs.getString(_savedPasswordKey),
    };
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_vendorIdKey);
  }
}
