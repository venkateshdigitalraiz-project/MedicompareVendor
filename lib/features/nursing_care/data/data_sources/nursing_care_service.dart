import 'dart:convert';
import 'package:MediCompare/core/api/api_endpoints.dart';
import 'package:MediCompare/core/api/api_service_repository.dart';
import '../models/nursing_care_model.dart';

class NursingCareService {
  final ApiServiceRepository apiService;

  NursingCareService(this.apiService);

  Future<List<NursingCareCategory>> getCategories() async {
    final response = await apiService.get(ApiEndpoints.nursingCareCategories);
    final data = jsonDecode(response.body);
    // Based on response structure for categories in other services
    final categoriesList = (data['data'] is Map && data['data']['allcategory'] != null)
        ? data['data']['allcategory']
        : (data['data'] is List ? data['data'] : (data['data']['categories'] ?? data['data']['list'] ?? []));
    
    return (categoriesList as List)
        .map((c) => NursingCareCategory.fromJson(c))
        .toList();
  }

  Future<NursingCareResponse> getNursingCareList({
    String? categoryId,
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    final Map<String, dynamic> query = {
      'page': page,
      'limit': limit,
      'categoryId': categoryId ?? '',
      'search': search ?? '',
    };
    final response = await apiService.get(ApiEndpoints.nursingCareList, queryParameters: query);
    final data = jsonDecode(response.body);
    return NursingCareResponse.fromJson(data['data']);
  }

  Future<NursingCareItem> getNursingCareDetails(String id) async {
    final response = await apiService.get(ApiEndpoints.nursingCareDetails(id));
    final data = jsonDecode(response.body);
    return NursingCareItem.fromJson(data['data']['product']);
  }

  Future<List<NursingCareDropdownItem>> searchTablets(String query) async {
    final response = await apiService.get(
      ApiEndpoints.commonTablets,
      queryParameters: {'search': query, 'type': 'nursingcare'},
    );
    final data = jsonDecode(response.body);
    return (data['data']['tablets'] as List)
        .map((t) => NursingCareDropdownItem.fromJson(t))
        .toList();
  }

  Future<void> createNursingCare(Map<String, dynamic> payload) async {
    await apiService.post(ApiEndpoints.createNursingCare, body: payload);
  }

  Future<void> updateNursingCare(String id, Map<String, dynamic> payload) async {
    await apiService.post(ApiEndpoints.updateNursingCare(id), body: payload);
  }

  Future<void> deleteNursingCare(String id) async {
    // pattern in this app uses POST for delete routes usually
    await apiService.post(ApiEndpoints.deleteNursingCare(id));
  }
}
