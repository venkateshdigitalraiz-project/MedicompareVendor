class PermissionModel {
  final String id;
  final String serviceId;
  final String module;
  final String status;
  final List<PermissionAction> actions;

  PermissionModel({
    required this.id,
    required this.serviceId,
    required this.module,
    required this.status,
    required this.actions,
  });

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      id: json['_id'] ?? '',
      serviceId: json['serviceId'] ?? '',
      module: json['module'] ?? '',
      status: json['status'] ?? '',
      actions: (json['actions'] as List<dynamic>?)
              ?.map((a) => PermissionAction.fromJson(a))
              .toList() ??
          [],
    );
  }

  bool hasAction(String key) {
    if (status != 'active') return false;
    return actions.any((a) => a.key == key && a.enabled);
  }
}

class PermissionAction {
  final String key;
  final bool enabled;

  PermissionAction({
    required this.key,
    required this.enabled,
  });

  factory PermissionAction.fromJson(Map<String, dynamic> json) {
    return PermissionAction(
      key: json['key'] ?? '',
      enabled: json['enabled'] ?? false,
    );
  }
}
