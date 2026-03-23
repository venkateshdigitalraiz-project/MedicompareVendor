import 'dart:convert';
import 'package:MediCompare/core/api/api_endpoints.dart';
import 'package:MediCompare/core/api/api_service_repository.dart';
import '../models/medical_treatment_model.dart';
import 'package:MediCompare/core/error/exceptions.dart';

class MedicalTreatmentService {
  final ApiServiceRepository apiService;

  MedicalTreatmentService(this.apiService);

  Future<List<MedicalTreatmentCategory>> getCategories() async {
    try {
      final response = await apiService.get(ApiEndpoints.medicalTreatmentCategories);
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        final List categoriesJson = body['data']['allcategory'] ?? [];
        return categoriesJson
            .map((json) => MedicalTreatmentCategory.fromJson(json))
            .toList();
      }
      throw ServerException(body['message'] ?? 'Failed to fetch categories');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<MedicalTreatmentResponse> getList({
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
      final response = await apiService.get(ApiEndpoints.medicalTreatmentList,
          queryParameters: query);
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        return MedicalTreatmentResponse.fromJson(body['data']);
      }
      throw ServerException(body['message'] ?? 'Failed to fetch products');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<MedicalTreatmentItem> getDetails(String id) async {
    try {
      final response = await apiService.get(ApiEndpoints.medicalTreatmentDetails(id));
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        return MedicalTreatmentItem.fromJson(body['data']['product']);
      }
      throw ServerException(body['message'] ?? 'Failed to fetch details');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<List<MedicalTreatmentDropdownItem>> searchTablets(String query) async {
    try {
      final response = await apiService.get(
        ApiEndpoints.commonTablets,
        queryParameters: {'search': query, 'type': 'medicaltreatment'},
      );
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        final List list = body['data']['tablets'] ?? [];
        return list.map((e) => MedicalTreatmentDropdownItem.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> create(Map<String, dynamic> payload) async {
    try {
      final response = await apiService.post(ApiEndpoints.createMedicalTreatment,
          body: payload);
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
      final response = await apiService.post(ApiEndpoints.updateMedicalTreatment(id),
          body: payload);
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
      final response = await apiService.post(ApiEndpoints.deleteMedicalTreatment(id));
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
