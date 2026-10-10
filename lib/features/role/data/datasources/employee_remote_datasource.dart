import 'dart:convert';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_service_repository.dart';
import '../models/employee_model.dart';

abstract class EmployeeRemoteDataSource {
  Future<List<EmployeeModel>> getEmployeeList();
  Future<void> createEmployee(Map<String, dynamic> body);
  Future<EmployeeModel> getEmployeeDetails(String id);
  Future<void> updateEmployee(String id, Map<String, dynamic> body);
}

class EmployeeRemoteDataSourceImpl implements EmployeeRemoteDataSource {
  final ApiServiceRepository apiService;

  EmployeeRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<EmployeeModel>> getEmployeeList() async {
    final response = await apiService.get(ApiEndpoints.employeeList);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = json.decode(response.body);
      if (decoded['success'] == true) {
        final List list = decoded['data']['list'] ?? [];
        return list.map((e) => EmployeeModel.fromJson(e)).toList();
      } else {
        throw Exception(decoded['message'] ?? 'Failed to load employees');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  @override
  Future<void> createEmployee(Map<String, dynamic> body) async {
    final response = await apiService.post(ApiEndpoints.createEmployee, body: body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = json.decode(response.body);
      if (decoded['success'] != true) {
        throw Exception(decoded['message'] ?? 'Failed to create employee');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  @override
  Future<EmployeeModel> getEmployeeDetails(String id) async {
    final response = await apiService.post(ApiEndpoints.employeeDetails(id), body: {});

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      print('getEmployeeDetails Response: ${response.body}');
      if (decoded['success'] == true) {
        final data = decoded['data'];
        if (data is Map<String, dynamic>) {
          if (data.containsKey('_id') || data.containsKey('name')) {
            return EmployeeModel.fromJson(data);
          } else if (data.containsKey('employee')) {
            return EmployeeModel.fromJson(data['employee']);
          } else if (data.containsKey('details')) {
            return EmployeeModel.fromJson(data['details']);
          } else if (data.containsKey('user')) {
            return EmployeeModel.fromJson(data['user']);
          } else if (data.containsKey('data')) {
            return EmployeeModel.fromJson(data['data']);
          }
        }
        return EmployeeModel.fromJson(data);
      } else {
        throw Exception(decoded['message'] ?? 'Failed to load employee details');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  @override
  Future<void> updateEmployee(String id, Map<String, dynamic> body) async {
    final response = await apiService.put(ApiEndpoints.updateEmployee(id), body: body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = json.decode(response.body);
      if (decoded['success'] != true) {
        throw Exception(decoded['message'] ?? 'Failed to update employee');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }
}
