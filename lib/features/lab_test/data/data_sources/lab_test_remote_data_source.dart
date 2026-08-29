import 'dart:convert';
import 'package:MediCompare/core/api/api_endpoints.dart';
import 'package:MediCompare/core/api/api_service_repository.dart';
import 'package:MediCompare/core/error/exceptions.dart';
import '../models/lab_test_model.dart';

abstract class LabTestRemoteDataSource {
  Future<LabTestItem> getLabTestDetails(String productId);
  Future<void> updateLabTest(String id, Map<String, dynamic> data);
  Future<List<LabTestDetails>> searchLabTests(String query);
}

class LabTestRemoteDataSourceImpl implements LabTestRemoteDataSource {
  final ApiServiceRepository _apiService;

  LabTestRemoteDataSourceImpl(this._apiService);

  @override
  Future<List<LabTestDetails>> searchLabTests(String query) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.labTestsSearchTablets,
        queryParameters: {
          'type': 'labtests',
          'search': query,
          'limit': '100', // To avoid excessive payload but provide enough results
        },
      );
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        final List lists = body['data']['tablets'] ?? [];
        return lists.map((e) => LabTestDetails.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<LabTestItem> getLabTestDetails(String productId) async {
    try {
      final response = await _apiService.post(ApiEndpoints.labTestDetails(productId), body: {});
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

  @override
  Future<void> updateLabTest(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post(ApiEndpoints.updateLabTest(id), body: data);
      final body = jsonDecode(response.body);
      if (body['success'] != true) {
        throw ServerException(body['message'] ?? 'Failed to update lab test');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }
}
