import 'dart:convert';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_service_repository.dart';
import '../../../../core/error/exceptions.dart';
import '../models/lab_test_model.dart';

class LabTestService {
  final ApiServiceRepository _apiService;

  LabTestService(this._apiService);

  Future<List<LabTestCategory>> getCategories() async {
    try {
      final response = await _apiService.get(ApiEndpoints.labTestsCategories);
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        final List categoriesJson = body['data']['allcategory'] ?? [];
        return categoriesJson.map((json) => LabTestCategory.fromJson(json)).toList();
      }
      throw ServerException(body['message'] ?? 'Failed to fetch categories');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<LabTestResponse> getLabTestList({
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

      final response = await _apiService.get(ApiEndpoints.labTestsList, queryParameters: queryParams);
      final body = jsonDecode(response.body);
      
      if (body['success'] == true) {
        return LabTestResponse.fromJson(body['data']);
      }
      throw ServerException(body['message'] ?? 'Failed to fetch lab tests');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<LabTestItem> getLabTestDetails(String id) async {
    try {
      final response = await _apiService.post(ApiEndpoints.labTestDetails(id), body: {});
      final body = jsonDecode(response.body);
      
      if (body['success'] == true) {
        return LabTestItem.fromJson(body['data']['product']);
      }
      throw ServerException(body['message'] ?? 'Failed to fetch details');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<List<LabTestDetails>> searchLabTests(String query) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.labTestsSearchTablets,
        queryParameters: {'search': query, 'type': 'labtests'},
      );
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        final List lists = body['data']['tablets'] ?? [];
        return lists.map((e) => LabTestDetails.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<LabTestDetails> getLabTestTabletDetails(String id) async {
    try {
      final response = await _apiService.get(ApiEndpoints.getTabletDetails(id));
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        return LabTestDetails.fromJson(body['data']['tablets']);
      }
      throw ServerException(body['message'] ?? 'Failed to fetch details');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> createLabTest(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post(ApiEndpoints.createLabTest, body: data);
      final body = jsonDecode(response.body);
      if (body['success'] != true) {
        throw ServerException(body['message'] ?? 'Failed to create lab test');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> updateLabTest(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post(ApiEndpoints.updateLabTest(id), body: data);
      final body = jsonDecode(response.body);
      if (body['success'] != true) {
        throw ServerException(body['message'] ?? 'Failed to update lab test');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> deleteLabTest(String id) async {
    try {
      final response = await _apiService.post(ApiEndpoints.deleteLabTest(id));
      final body = jsonDecode(response.body);
      if (body['success'] != true) {
        throw ServerException(body['message'] ?? 'Failed to delete lab test');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
