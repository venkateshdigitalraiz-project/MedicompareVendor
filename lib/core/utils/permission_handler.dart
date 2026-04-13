import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/permission_model.dart';

class PermissionHandler {
  static final PermissionHandler _instance = PermissionHandler._internal();
  factory PermissionHandler() => _instance;
  PermissionHandler._internal();

  List<PermissionModel> _permissions = [];

  static const String _permissionsKey = 'vendor_permissions';

  Future<void> setPermissions(List<PermissionModel> permissions) async {
    _permissions = permissions;
    // Optionally persist permissions
    // final prefs = await SharedPreferences.getInstance();
    // final List<String> encoded = permissions.map((p) => jsonEncode(p.toJson())).toList();
    // await prefs.setStringList(_permissionsKey, encoded);
  }

  bool hasPermission(String module, String action) {
    try {
      final permission = _permissions.firstWhere(
        (p) => p.module == module,
      );
      return permission.hasAction(action);
    } catch (_) {
      // If module not found, default to false or handle as needed
      return false;
    }
  }

  List<PermissionModel> get permissions => _permissions;
}
