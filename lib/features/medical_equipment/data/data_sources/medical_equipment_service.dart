import 'dart:convert';
import 'package:MediCompare/core/api/api_endpoints.dart';
import 'package:MediCompare/core/api/api_service_repository.dart';
import '../models/medical_equipment_model.dart';
import 'package:MediCompare/core/error/exceptions.dart';

class MedicalEquipmentService {
  final ApiServiceRepository apiService;

  MedicalEquipmentService(this.apiService);

  Future<List<MedicalEquipmentCategoryModel>> getCategories() async {
    try {
      final response =
          await apiService.get(ApiEndpoints.medicalEquipmentCategories);
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        final List categoriesJson = body['data']['allcategory'] ?? [];
        return categoriesJson
            .map((json) => MedicalEquipmentCategoryModel.fromJson(json))
            .toList();
      }
      throw ServerException(body['message'] ?? 'Failed to fetch categories');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<MedicalEquipmentResponseModel> getList({
    String? categoryId,
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final Map<String, dynamic> query = {
        'page': page,
        'limit': limit,
        'categoryId': categoryId ?? '',
        'search': search ?? '',
      };
      final response = await apiService.get(ApiEndpoints.medicalEquipmentList,
          queryParameters: query);
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        return MedicalEquipmentResponseModel.fromJson(body['data']);
      }
      throw ServerException(body['message'] ?? 'Failed to fetch products');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<MedicalEquipmentItemModel> getDetails(String id) async {
    try {
      final response =
          await apiService.post(ApiEndpoints.medicalEquipmentDetails(id));
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        return MedicalEquipmentItemModel.fromJson(body['data']['product']);
      }
      throw ServerException(body['message'] ?? 'Failed to fetch details');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<List<MedicalEquipmentDropdownItemModel>> searchTablets(String query) async {
    try {
      final response = await apiService.get(
        ApiEndpoints.commonTablets,
        queryParameters: {'search': query, 'type': 'medicalequipment'},
      );
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        final List list = body['data']['tablets'] ?? [];
        return list
            .map((e) => MedicalEquipmentDropdownItemModel.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> create(Map<String, dynamic> payload) async {
    try {
      final response = await apiService
          .post(ApiEndpoints.createMedicalEquipment, body: payload);
      final body = jsonDecode(response.body);
      if (body['success'] != true) {
        throw ServerException(body['message'] ?? 'Failed to create service');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<void> update(String id, Map<String, dynamic> payload) async {
    try {
      final response = await apiService
          .post(ApiEndpoints.updateMedicalEquipment(id), body: payload);
      final body = jsonDecode(response.body);
      if (body['success'] != true) {
        throw ServerException(body['message'] ?? 'Failed to update service');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<void> delete(String id) async {
    try {
      final response =
          await apiService.post(ApiEndpoints.deleteMedicalEquipment(id));
      final body = jsonDecode(response.body);
      if (body['success'] != true) {
        throw ServerException(body['message'] ?? 'Failed to delete service');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }
}
