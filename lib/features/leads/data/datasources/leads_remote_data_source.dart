import 'dart:convert';

import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_service_repository.dart';
import '../models/lead_model.dart';

abstract class LeadsRemoteDataSource {
  Future<LeadsListModel> getLeads({
    int page = 1,
    int limit = 10,
    String status = '',
    String leadStage = '',
    String search = '',
  });
  Future<LeadDetailsModel> getLeadDetails(String id);
  Future<void> updateLeadStatus(String id, String status);
}

class LeadsRemoteDataSourceImpl implements LeadsRemoteDataSource {
  final ApiServiceRepository apiService;

  LeadsRemoteDataSourceImpl({required this.apiService});

  @override
  Future<LeadsListModel> getLeads({
    int page = 1,
    int limit = 10,
    String status = '',
    String leadStage = '',
    String search = '',
  }) async {
    final Map<String, dynamic> queryParams = {
      'page': page,
      'limit': limit,
    };
    
    if (status.isNotEmpty) queryParams['status'] = status;
    if (leadStage.isNotEmpty) queryParams['leadStage'] = leadStage;
    if (search.isNotEmpty) queryParams['search'] = search;

    final response = await apiService.get(
      ApiEndpoints.leadsList,
      queryParameters: queryParams,
    );

    final decoded = json.decode(response.body);
    if (decoded == null || decoded['data'] == null) {
      return LeadsListModel(
        leads: const [],
        pagination: LeadsPaginationModel(
          total: 0,
          page: page,
          limit: limit,
          totalPages: 1,
        ),
      );
    }
    return LeadsListModel.fromJson(decoded['data']);
  }

  @override
  Future<LeadDetailsModel> getLeadDetails(String id) async {
    final response = await apiService.get(ApiEndpoints.leadDetails(id));
    final decoded = json.decode(response.body);

    if (decoded == null ||
        decoded['data'] == null ||
        decoded['data']['lead'] == null) {
      throw Exception('Lead details not found');
    }

    return LeadDetailsModel.fromJson(decoded['data']['lead']);
  }

  @override
  Future<void> updateLeadStatus(String id, String status) async {
    await apiService.post(
      ApiEndpoints.updateLeadApprovalStatus(id),
      body: {'status': status},
    );
  }
}
