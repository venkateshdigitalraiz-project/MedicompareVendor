class RoleEntity {
  final String id;
  final String name;
  final int permissionsCount;
  final int staffCount;
  final String status;
  final bool isSpecial; // for custom styling like the 'Manager' pill
  final String colorTheme;
  final List<dynamic> permissionsData;

  RoleEntity({
    required this.id,
    required this.name,
    required this.permissionsCount,
    required this.staffCount,
    required this.status,
    this.isSpecial = false,
    this.colorTheme = '',
    this.permissionsData = const [],
  });
}
