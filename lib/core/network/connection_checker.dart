import 'dart:io' show InternetAddress, SocketException;
import 'package:flutter/foundation.dart' show kIsWeb;

abstract class ConnectionChecker {
  Future<bool> get isConnected;
}

class ConnectionCheckerImpl implements ConnectionChecker {
  @override
  Future<bool> get isConnected async {
    if (kIsWeb) {
      return true; // Web always assumes online for this simple check
    }
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }
}
