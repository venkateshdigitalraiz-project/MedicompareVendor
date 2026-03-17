import 'dart:convert';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_service_repository.dart';
import '../models/dashboard_model.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardModel> getDashboard();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final ApiServiceRepository apiService;

  DashboardRemoteDataSourceImpl({required this.apiService});

  @override
  Future<DashboardModel> getDashboard() async {
    final response = await apiService.get(ApiEndpoints.dashboard);
    final jsonResponse = json.decode(response.body);
    return DashboardModel.fromJson(jsonResponse);
  }
}
