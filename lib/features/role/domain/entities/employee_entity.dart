class EmployeeEntity {
  final String id;
  final String name;
  final String designation;
  final String role;
  final String department;
  final String email;
  final String phone;
  final String status;
  final String? address;
  final List<String>? languages;
  final String? hireDate;
  final String? experience;
  final String? shift;
  final String? roleId;
  final String? departmentId;

  EmployeeEntity({
    required this.id,
    required this.name,
    required this.designation,
    required this.role,
    required this.department,
    required this.email,
    required this.phone,
    required this.status,
    this.address,
    this.languages,
    this.hireDate,
    this.experience,
    this.shift,
    this.roleId,
    this.departmentId,
  });
}
