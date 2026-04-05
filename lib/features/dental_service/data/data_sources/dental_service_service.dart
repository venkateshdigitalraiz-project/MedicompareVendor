import 'dart:convert';
import 'package:MediCompare/core/api/api_endpoints.dart';
import 'package:MediCompare/core/api/api_service_repository.dart';
import '../models/dental_service_model.dart';
import 'package:MediCompare/core/error/exceptions.dart';

class DentalServiceService {
  final ApiServiceRepository apiService;

  DentalServiceService(this.apiService);

  Future<List<DentalServiceCategory>> getCategories() async {
    try {
      final response =
          await apiService.get(ApiEndpoints.dentalServiceCategories);
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        final List categoriesJson = body['data']['allcategory'] ?? [];
        return categoriesJson
            .map((json) => DentalServiceCategory.fromJson(json))
            .toList();
      }
      throw ServerException(body['message'] ?? 'Failed to fetch categories');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<DentalServiceResponse> getDentalServiceList({
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
      final response = await apiService.get(ApiEndpoints.dentalServiceList,
          queryParameters: query);
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        return DentalServiceResponse.fromJson(body['data']);
      }
      throw ServerException(body['message'] ?? 'Failed to fetch products');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<DentalServiceItem> getDentalServiceDetails(String id) async {
    try {
      final response =
          await apiService.get(ApiEndpoints.dentalServiceDetails(id));
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        return DentalServiceItem.fromJson(body['data']['product']);
      }
      throw ServerException(body['message'] ?? 'Failed to fetch details');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<List<DentalServiceDropdownItem>> searchTablets(String query) async {
    try {
      final response = await apiService.get(
        ApiEndpoints.commonTablets,
        queryParameters: {'search': query, 'type': 'dentalservice'},
      );
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        final List list = body['data']['tablets'] ?? [];
        return list.map((e) => DentalServiceDropdownItem.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> createDentalService(Map<String, dynamic> payload) async {
    try {
      final response = await apiService.post(ApiEndpoints.createDentalService,
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

  Future<void> updateDentalService(
      String id, Map<String, dynamic> payload) async {
    try {
      final response = await apiService
          .post(ApiEndpoints.updateDentalService(id), body: payload);
      final body = jsonDecode(response.body);
      if (body['success'] != true) {
        throw ServerException(body['message'] ?? 'Failed to update service');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<void> deleteDentalService(String id) async {
    try {
      final response =
          await apiService.post(ApiEndpoints.deleteDentalService(id));
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
