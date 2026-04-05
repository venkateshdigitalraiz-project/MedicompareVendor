import 'dart:convert';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_service_repository.dart';
import '../../../../core/error/exceptions.dart';
import '../models/surgery_model.dart';

class SurgeryService {
  final ApiServiceRepository _apiService;

  SurgeryService(this._apiService);

  Future<List<SurgeryCategory>> getCategories() async {
    try {
      final response = await _apiService.get(ApiEndpoints.surgeryCategories);
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        final List categoriesJson = body['data']['allcategory'] ?? [];
        return categoriesJson
            .map((json) => SurgeryCategory.fromJson(json))
            .toList();
      }
      throw ServerException(
          body['message'] ?? 'Failed to fetch surgery categories');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<SurgeryResponse> getSurgeryList({
    int page = 1,
    String categoryId = '',
    String search = '',
    int limit = 10,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'categoryId': categoryId,
        'search': search,
      };

      final response = await _apiService.get(ApiEndpoints.surgeryList,
          queryParameters: queryParams);
      final body = jsonDecode(response.body);

      if (body['success'] == true) {
        return SurgeryResponse.fromJson(body['data']);
      }
      throw ServerException(body['message'] ?? 'Failed to fetch surgery list');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<SurgeryItem> getSurgeryDetails(String id) async {
    try {
      final response =
          await _apiService.post(ApiEndpoints.surgeryDetails(id), body: {});
      final body = jsonDecode(response.body);

      if (body['success'] == true) {
        return SurgeryItem.fromJson(body['data']['product']);
      }
      throw ServerException(
          body['message'] ?? 'Failed to fetch surgery details');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<List<SurgeryDropdownItem>> getCommonSurgeries(String search) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.commonSurgeries,
        queryParameters: {
          'type': 'surgeries',
          'search': search,
        },
      );
      final body = jsonDecode(response.body);

      if (body['success'] == true) {
        return (body['data']['tablets'] as List)
            .map((i) => SurgeryDropdownItem.fromJson(i))
            .toList();
      }
      throw ServerException(
          body['message'] ?? 'Failed to fetch common surgeries');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<SurgeryDetails> getCommonSurgeryDetails(String id) async {
    try {
      final response =
          await _apiService.get(ApiEndpoints.commonSurgeryDetails(id));
      final body = jsonDecode(response.body);

      if (body['success'] == true) {
        return SurgeryDetails.fromJson(body['data']['tablets']);
      }
      throw ServerException(
          body['message'] ?? 'Failed to fetch common surgery details');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<void> createSurgery(Map<String, dynamic> data) async {
    try {
      final response =
          await _apiService.post(ApiEndpoints.createSurgery, body: data);
      final body = jsonDecode(response.body);

      if (body['success'] == true) {
        return;
      }
      throw ServerException(body['message'] ?? 'Failed to create surgery');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<void> updateSurgery(String id, Map<String, dynamic> data) async {
    try {
      final response =
          await _apiService.post(ApiEndpoints.updateSurgery(id), body: data);
      final body = jsonDecode(response.body);

      if (body['success'] == true) {
        return;
      }
      throw ServerException(body['message'] ?? 'Failed to update surgery');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<void> deleteSurgery(String id) async {
    try {
      final response =
          await _apiService.post(ApiEndpoints.deleteSurgery(id), body: {});
      final body = jsonDecode(response.body);

      if (body['success'] == true) {
        return;
      }
      throw ServerException(body['message'] ?? 'Failed to delete surgery');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }
}
