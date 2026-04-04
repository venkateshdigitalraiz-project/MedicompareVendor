import 'dart:convert';
import 'package:MediCompare/core/api/api_endpoints.dart';
import 'package:MediCompare/core/api/api_service_repository.dart';
import 'package:MediCompare/core/error/exceptions.dart';
import '../models/branch_model.dart';

class BranchService {
  final ApiServiceRepository _apiService;

  BranchService(this._apiService);

  Future<BranchListResponse> getBranchList({
    int page = 1,
    int limit = 100,
    String search = '',
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'search': search,
      };

      final response = await _apiService.get(ApiEndpoints.branchList, queryParameters: queryParams);
      final body = jsonDecode(response.body);
      
      if (body['success'] == true) {
        return BranchListResponse.fromJson(body);
      }
      throw ServerException(body['message'] ?? 'Failed to fetch branch list');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }
  Future<BranchDetailsResponse> getBranchDetails(String id) async {
    try {
      final response = await _apiService.get(ApiEndpoints.branchDetails(id));
      final body = jsonDecode(response.body);
      
      if (body['success'] == true) {
        return BranchDetailsResponse.fromJson(body);
      }
      throw ServerException(body['message'] ?? 'Failed to fetch branch details');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }
}
