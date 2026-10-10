import 'dart:convert';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_service_repository.dart';
import '../models/role_model.dart';
import '../models/medical_category_model.dart';

abstract class RoleRemoteDataSource {
  Future<List<RoleModel>> getRolesList({String? status});
  Future<List<MedicalCategoryModel>> getMedicalCategories();
  Future<void> createRole(Map<String, dynamic> body);
  Future<void> updateRole(String id, Map<String, dynamic> body);
  Future<void> deleteRole(String id);
}

class RoleRemoteDataSourceImpl implements RoleRemoteDataSource {
  final ApiServiceRepository apiService;

  RoleRemoteDataSourceImpl({required this.apiService});

  Future<List<RoleModel>> getRolesList({String? status}) async {
    String endpoint = ApiEndpoints.rolesList;
    if (status != null && status.isNotEmpty) {
      endpoint += '?status=$status';
    }
    final response = await apiService.get(endpoint);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = json.decode(response.body);
      if (decoded['success'] == true) {
        final List list = decoded['data']['list'] ?? [];
        return list.map((e) => RoleModel.fromJson(e)).toList();
      } else {
        throw Exception(decoded['message'] ?? 'Failed to load roles');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  @override
  Future<void> createRole(Map<String, dynamic> body) async {
    final response = await apiService.post(ApiEndpoints.createRole, body: body);
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = json.decode(response.body);
      if (decoded['success'] != true) {
        throw Exception(decoded['message'] ?? 'Failed to create role');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  @override
  Future<void> updateRole(String id, Map<String, dynamic> body) async {
    final response = await apiService.post(ApiEndpoints.updateRole(id), body: body); // User explicitly said POST method
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = json.decode(response.body);
      if (decoded['success'] != true) {
        throw Exception(decoded['message'] ?? 'Failed to update role');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  @override
  Future<List<MedicalCategoryModel>> getMedicalCategories() async {
    final response = await apiService.get(ApiEndpoints.medicalCategories);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = json.decode(response.body);
      if (decoded['success'] == true) {
        final List list = decoded['data']['categories'] ?? [];
        return list.map((e) => MedicalCategoryModel.fromJson(e)).toList();
      } else {
        throw Exception(decoded['message'] ?? 'Failed to load medical categories');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  @override
  Future<void> deleteRole(String id) async {
    final response = await apiService.post(ApiEndpoints.deleteRole(id), body: {}); // User explicitly said POST method
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = json.decode(response.body);
      if (decoded['success'] != true) {
        throw Exception(decoded['message'] ?? 'Failed to delete role');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }
}
