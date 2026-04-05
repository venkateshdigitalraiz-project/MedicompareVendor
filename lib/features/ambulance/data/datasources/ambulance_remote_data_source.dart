import 'dart:convert';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_service_repository.dart';
import '../models/ambulance_model.dart';

abstract class AmbulanceRemoteDataSource {
  Future<AmbulanceListModel> getAmbulanceList({
    int page = 1,
    int limit = 10,
    String categoryId = '',
    String search = '',
  });
  Future<AmbulanceModel> getAmbulanceDetails(String id);
  Future<List<AmbulanceCategoryModel>> getAmbulanceCategories();
  Future<List<AmbulanceNameOptionModel>> getAmbulanceNames(String query);
  Future<List<AmbulanceFacilityModel>> getFacilitiesList();
  Future<void> createAmbulance(Map<String, dynamic> payload);
  Future<void> updateAmbulance(String id, Map<String, dynamic> payload);
  Future<void> deleteAmbulance(String id);
}

class AmbulanceRemoteDataSourceImpl implements AmbulanceRemoteDataSource {
  final ApiServiceRepository apiService;

  AmbulanceRemoteDataSourceImpl({required this.apiService});

  @override
  Future<AmbulanceListModel> getAmbulanceList({
    int page = 1,
    int limit = 10,
    String categoryId = '',
    String search = '',
  }) async {
    final response = await apiService.get(
      ApiEndpoints.ambulanceList,
      queryParameters: {
        'page': page,
        'limit': limit,
        'categoryId': categoryId,
        'search': search,
      },
    );

    final decoded = json.decode(response.body);
    if (decoded == null || decoded['data'] == null) {
      return AmbulanceListModel(
        items: const [],
        pagination: AmbulancePaginationModel(
          total: 0,
          page: page,
          limit: limit,
          totalPages: 1,
        ),
      );
    }
    return AmbulanceListModel.fromJson(decoded['data']);
  }

  @override
  Future<AmbulanceModel> getAmbulanceDetails(String id) async {
    final response = await apiService.get(ApiEndpoints.ambulanceDetails(id));
    final decoded = json.decode(response.body);

    if (decoded == null ||
        decoded['data'] == null ||
        decoded['data']['product'] == null) {
      throw Exception('Ambulance details not found');
    }

    return AmbulanceModel.fromJson(decoded['data']['product']);
  }

  @override
  Future<List<AmbulanceCategoryModel>> getAmbulanceCategories() async {
    final response = await apiService.get(ApiEndpoints.ambulanceCategories);
    final decoded = json.decode(response.body);

    if (decoded == null ||
        decoded['data'] == null ||
        decoded['data']['allcategory'] == null) {
      return [];
    }

    final list = decoded['data']['allcategory'] as List;
    return list.map((e) => AmbulanceCategoryModel.fromJson(e)).toList();
  }

  @override
  Future<List<AmbulanceNameOptionModel>> getAmbulanceNames(String query) async {
    final response = await apiService.get(
      ApiEndpoints.ambulanceNames,
      queryParameters: {
        'search': query,
        'type': 'ambulanceservice',
      },
    );
    final decoded = json.decode(response.body);

    if (decoded == null ||
        decoded['data'] == null ||
        decoded['data']['tablets'] == null) {
      return [];
    }

    final list = decoded['data']['tablets'] as List;
    return list.map((e) => AmbulanceNameOptionModel.fromJson(e)).toList();
  }

  @override
  Future<List<AmbulanceFacilityModel>> getFacilitiesList() async {
    final response = await apiService.get(
      ApiEndpoints.facilitiesList,
      queryParameters: {'limit': 100, 'page': 1},
    );
    final decoded = json.decode(response.body);

    if (decoded == null ||
        decoded['data'] == null ||
        decoded['data']['facilities'] == null) {
      return [];
    }

    final list = decoded['data']['facilities'] as List;
    return list.map((e) => AmbulanceFacilityModel.fromJson(e)).toList();
  }

  @override
  Future<void> createAmbulance(Map<String, dynamic> payload) async {
    final response = await apiService.post(
      ApiEndpoints.createAmbulance,
      body: payload,
    );

    final decoded = json.decode(response.body);
    if (decoded == null || decoded['success'] != true) {
      throw Exception(
          decoded?['message'] ?? 'Failed to create ambulance service');
    }
  }

  @override
  Future<void> updateAmbulance(String id, Map<String, dynamic> payload) async {
    final response = await apiService.post(
      ApiEndpoints.updateAmbulance(id),
      body: payload,
    );

    final decoded = json.decode(response.body);
    if (decoded == null || decoded['success'] != true) {
      throw Exception(
          decoded?['message'] ?? 'Failed to update ambulance service');
    }
  }

  @override
  Future<void> deleteAmbulance(String id) async {
    final response = await apiService.post(
      ApiEndpoints.deleteAmbulance(id),
      body: {},
    );
    final decoded = json.decode(response.body);
    if (decoded == null || decoded['success'] != true) {
      throw Exception(
          decoded?['message'] ?? 'Failed to delete ambulance service');
    }
  }
}
