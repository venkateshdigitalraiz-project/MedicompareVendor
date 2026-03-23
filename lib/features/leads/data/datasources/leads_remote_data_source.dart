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
    final response = await apiService.get(
      ApiEndpoints.leadsList,
      queryParameters: {
        'page': page,
        'limit': limit,
        'status': status,
        'leadStage': leadStage,
        'search': search,
      },
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
}
