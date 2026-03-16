import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/utils/token_storage.dart';
import '../models/dashboard_model.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardModel> getDashboard();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final http.Client client;

  DashboardRemoteDataSourceImpl({required this.client});

  @override
  Future<DashboardModel> getDashboard() async {
    final token = await TokenStorage.getToken();
    final url = ApiEndpoints.dashboard;
    
    print('-----------------------------------------');
    print('REQUEST: GET $url');
    print('TOKEN: ${token?.substring(0, (token.length > 10 ? 10 : token.length))}...');
    
    final response = await client.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    print('RESPONSE CODE: ${response.statusCode}');
    print('RESPONSE BODY: ${response.body}');
    print('-----------------------------------------');

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success']) {
        return DashboardModel.fromJson(jsonResponse);
      } else {
        throw Exception(jsonResponse['message'] ?? 'Failed to load dashboard');
      }
    } else if (response.statusCode == 401) {
      throw Exception('UNAUTHORIZED_ACCESS_401');
    } else {
      throw Exception('HTTP_ERROR_${response.statusCode}');
    }
  }
}
