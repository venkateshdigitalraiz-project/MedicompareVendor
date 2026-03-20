import 'dart:convert';
import 'dart:io';
import 'package:MediCompare/core/api/api_endpoints.dart';
import 'package:MediCompare/core/api/api_service_repository.dart';
import 'package:MediCompare/core/error/exceptions.dart';
import 'package:MediCompare/features/home_care/data/models/home_care_model.dart';

class HomeCareService {
  final ApiServiceRepository _apiService;

  HomeCareService(this._apiService);

  Future<List<HomeCareCategory>> getCategories() async {
    try {
      final response = await _apiService.get(ApiEndpoints.homeCareCategories);
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        final List categoriesJson = body['data']['allcategory'] ?? [];
        return categoriesJson.map((json) => HomeCareCategory.fromJson(json)).toList();
      }
      throw ServerException(body['message'] ?? 'Failed to fetch categories');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<HomeCareResponse> getHomeCareList({
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
      final response = await _apiService.get(ApiEndpoints.homeCareList, queryParameters: queryParams);
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        return HomeCareResponse.fromJson(body['data']);
      }
      throw ServerException(body['message'] ?? 'Failed to fetch home care services');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<HomeCareItem> getHomeCareDetails(String id) async {
    try {
      final response = await _apiService.post(ApiEndpoints.homeCareDetails(id), body: {});
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        return HomeCareItem.fromJson(body['data']['product']);
      }
      throw ServerException(body['message'] ?? 'Failed to fetch details');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<List<HomeCareDropdownItem>> searchHomeCareDropdown(String query) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.commonTablets,
        queryParameters: {'search': query, 'type': 'homecare'},
      );
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        final List list = body['data']['tablets'] ?? [];
        return list.map((e) => HomeCareDropdownItem.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<HomeCareDropdownItem> getTabletDetails(String id) async {
    try {
      final response = await _apiService.get(ApiEndpoints.getTabletDetails(id));
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        return HomeCareDropdownItem.fromJson(body['data']['tablets']);
      }
      throw ServerException(body['message'] ?? 'Failed to fetch tablet details');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<void> createHomeCare(Map<String, dynamic> data, {File? image}) async {
    try {
      if (image != null) {
        final fields = data.map((key, value) => MapEntry(key, value.toString()));
        final response = await _apiService.post(
          ApiEndpoints.createHomeCare,
          fields: fields,
          files: {'image': image},
        );
        final body = jsonDecode(response.body);
        if (body['success'] != true) {
          throw ServerException(body['message'] ?? 'Failed to create service');
        }
      } else {
        final response = await _apiService.post(ApiEndpoints.createHomeCare, body: data);
        final body = jsonDecode(response.body);
        if (body['success'] != true) {
          throw ServerException(body['message'] ?? 'Failed to create service');
        }
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<void> updateHomeCare(String id, Map<String, dynamic> data, {File? image}) async {
    try {
      if (image != null) {
        final fields = data.map((key, value) => MapEntry(key, value.toString()));
        final response = await _apiService.post(
          ApiEndpoints.updateHomeCare(id),
          fields: fields,
          files: {'image': image},
        );
        final body = jsonDecode(response.body);
        if (body['success'] != true) {
          throw ServerException(body['message'] ?? 'Failed to update service');
        }
      } else {
        final response = await _apiService.post(ApiEndpoints.updateHomeCare(id), body: data);
        final body = jsonDecode(response.body);
        if (body['success'] != true) {
          throw ServerException(body['message'] ?? 'Failed to update service');
        }
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<void> deleteHomeCare(String id) async {
    try {
      final response = await _apiService.post(ApiEndpoints.deleteHomeCare(id));
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
