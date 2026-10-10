import '../../domain/entities/role_entity.dart';

class RoleModel extends RoleEntity {
  RoleModel({
    required super.id,
    required super.name,
    required super.permissionsCount,
    required super.staffCount,
    required super.status,
    super.isSpecial = false,
    super.colorTheme = '',
    super.permissionsData = const [],
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    // Count permissions
    int permsCount = 0;
    if (json['permission'] != null && json['permission'] is List) {
      permsCount = (json['permission'] as List).length;
    } else if (json['permissions'] != null && json['permissions'] is List) {
      permsCount = (json['permissions'] as List).length;
    }

    // Count staff
    int stfCount = 0;
    if (json['users'] != null && json['users'] is List) {
      stfCount = (json['users'] as List).length;
    }

    return RoleModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown Role',
      permissionsCount: permsCount,
      staffCount: stfCount,
      status: json['status'] ?? 'active',
      isSpecial: json['color'] != null,
      colorTheme: json['color'] ?? '',
      permissionsData: (json['permission'] as List?) ?? [],
    );
  }
}
