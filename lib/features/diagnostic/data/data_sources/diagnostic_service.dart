import 'dart:convert';
import 'dart:io';
import 'package:MediCompare/core/api/api_endpoints.dart';
import 'package:MediCompare/core/api/api_service_repository.dart';
import 'package:MediCompare/core/error/exceptions.dart';
import 'package:MediCompare/features/diagnostic/data/models/diagnostic_model.dart';

class DiagnosticService {
  final ApiServiceRepository _apiService;

  DiagnosticService(this._apiService);

  Future<List<DiagnosticCategory>> getCategories() async {
    try {
      final response = await _apiService.get(ApiEndpoints.diagnosticCategories);
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        final List categoriesJson = body['data']['allcategory'] ?? [];
        return categoriesJson
            .map((json) => DiagnosticCategory.fromJson(json))
            .toList();
      }
      throw ServerException(body['message'] ?? 'Failed to fetch categories');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<DiagnosticResponse> getDiagnosticList({
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
      final response = await _apiService.get(ApiEndpoints.diagnosticList,
          queryParameters: queryParams);
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        return DiagnosticResponse.fromJson(body['data']);
      }
      throw ServerException(body['message'] ?? 'Failed to fetch diagnostics');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<DiagnosticItem> getDiagnosticDetails(String id) async {
    try {
      final response =
          await _apiService.post(ApiEndpoints.diagnosticDetails(id), body: {});
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        return DiagnosticItem.fromJson(body['data']['product']);
      }
      throw ServerException(body['message'] ?? 'Failed to fetch details');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<List<DiagnosticDropdownItem>> searchDiagnostics(String query) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.commonTablets,
        queryParameters: {'search': query, 'type': 'diagnostics'},
      );
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        final List list = body['data']['tablets'] ?? [];
        return list.map((e) => DiagnosticDropdownItem.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<DiagnosticDropdownItem> getTabletDetails(String id) async {
    try {
      final response = await _apiService.get(ApiEndpoints.getTabletDetails(id));
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        return DiagnosticDropdownItem.fromJson(body['data']['tablets']);
      }
      throw ServerException(
          body['message'] ?? 'Failed to fetch tablet details');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<void> createDiagnostic(Map<String, dynamic> data,
      {File? image}) async {
    try {
      if (image != null) {
        final fields =
            data.map((key, value) => MapEntry(key, value.toString()));
        final response = await _apiService.post(
          ApiEndpoints.createDiagnostic,
          fields: fields,
          files: {'image': image},
        );
        final body = jsonDecode(response.body);
        if (body['success'] != true) {
          throw ServerException(
              body['message'] ?? 'Failed to create diagnostic');
        }
      } else {
        final response =
            await _apiService.post(ApiEndpoints.createDiagnostic, body: data);
        final body = jsonDecode(response.body);
        if (body['success'] != true) {
          throw ServerException(
              body['message'] ?? 'Failed to create diagnostic');
        }
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<void> updateDiagnostic(String id, Map<String, dynamic> data,
      {File? image}) async {
    try {
      if (image != null) {
        final fields =
            data.map((key, value) => MapEntry(key, value.toString()));
        final response = await _apiService.post(
          ApiEndpoints.updateDiagnostic(id),
          fields: fields,
          files: {'image': image},
        );
        final body = jsonDecode(response.body);
        if (body['success'] != true) {
          throw ServerException(
              body['message'] ?? 'Failed to update diagnostic');
        }
      } else {
        final response = await _apiService
            .post(ApiEndpoints.updateDiagnostic(id), body: data);
        final body = jsonDecode(response.body);
        if (body['success'] != true) {
          throw ServerException(
              body['message'] ?? 'Failed to update diagnostic');
        }
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<void> deleteDiagnostic(String id) async {
    try {
      final response =
          await _apiService.post(ApiEndpoints.deleteDiagnostic(id));
      final body = jsonDecode(response.body);
      if (body['success'] != true) {
        throw ServerException(body['message'] ?? 'Failed to delete diagnostic');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }
}
