import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/utils/token_storage.dart';
import '../models/lead_model.dart';

abstract class LeadsRemoteDataSource {
  Future<LeadsListModel> getLeads({
    int page = 1,
    int limit = 10,
    String status = '',
    String leadStage = '',
    String search = '',
  });
}

class LeadsRemoteDataSourceImpl implements LeadsRemoteDataSource {
  final http.Client client;

  LeadsRemoteDataSourceImpl({required this.client});

  @override
  Future<LeadsListModel> getLeads({
    int page = 1,
    int limit = 10,
    String status = '',
    String leadStage = '',
    String search = '',
  }) async {
    final token = await TokenStorage.getToken();
    final url = Uri.parse(
        '${ApiEndpoints.leadsList}?page=$page&limit=$limit&status=$status&leadStage=$leadStage&search=$search');

    final response = await client.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 304) {
      final decoded = json.decode(response.body);
      if (decoded == null || decoded['data'] == null) {
        return LeadsListModel(
          leads: const [],
          pagination: LeadsPaginationModel(total: 0, page: page, limit: limit, totalPages: 1),
        );
      }
      return LeadsListModel.fromJson(decoded['data']);
    } else if (response.statusCode == 401) {
      throw Exception('UNAUTHORIZED');
    } else {
      throw Exception('Failed to fetch leads: ${response.statusCode}');
    }
  }
}
