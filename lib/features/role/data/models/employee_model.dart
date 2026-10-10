import '../../domain/entities/employee_entity.dart';

class EmployeeModel extends EmployeeEntity {
  EmployeeModel({
    required super.id,
    required super.name,
    required super.designation,
    required super.role,
    required super.department,
    required super.email,
    required super.phone,
    required super.status,
    super.address,
    super.languages,
    super.hireDate,
    super.experience,
    super.shift,
    super.roleId,
    super.departmentId,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      designation: json['position'] ?? 'N/A',
      role: json['role'] != null ? json['role']['name'] ?? 'Other' : 'Other',
      department: json['category'] != null ? json['category']['name'] ?? 'N/A' : 'N/A',
      email: json['email'] ?? '',
      phone: json['mobile']?.toString() ?? '',
      status: json['status'] ?? 'Active',
      address: json['address']?.toString(),
      languages: json['languages'] != null ? List<String>.from(json['languages']) : [],
      hireDate: json['hireDate']?.toString(),
      experience: json['experience']?.toString(),
      shift: json['shift']?.toString(),
      roleId: json['role'] != null ? json['role']['_id'] : null,
      departmentId: json['category'] != null ? json['category']['_id'] : null,
    );
  }
}
