import 'dart:convert';
import '../models/appointment_details_model.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_service_repository.dart';
import '../models/appointment_model.dart';

abstract class AppointmentRemoteDataSource {
  Future<AppointmentsListModel> getAppointments({
    int page = 1,
    int limit = 10,
    String status = '',
    String search = '',
    String branch = '',
  });

  Future<AppointmentDetailsModel> getAppointmentDetails(String id);
}

class AppointmentRemoteDataSourceImpl implements AppointmentRemoteDataSource {
  final ApiServiceRepository apiService;

  AppointmentRemoteDataSourceImpl({required this.apiService});

  @override
  Future<AppointmentDetailsModel> getAppointmentDetails(String id) async {
    final response = await apiService.get('${ApiEndpoints.appointmentOrderDetails}/$id');
    final decoded = json.decode(response.body);

    if (decoded == null || decoded['data'] == null || decoded['data']['orders'] == null) {
      throw Exception('Failed to load appointment details');
    }
    
    final List<dynamic> orders = decoded['data']['orders'];
    if (orders.isEmpty) {
      throw Exception('Appointment not found');
    }

    return AppointmentDetailsModel.fromJson(orders.first as Map<String, dynamic>);
  }


  @override
  Future<AppointmentsListModel> getAppointments({
    int page = 1,
    int limit = 10,
    String status = '',
    String search = '',
    String branch = '',
  }) async {
    final response = await apiService.get(
      ApiEndpoints.appointmentOrderList,
      queryParameters: {
        'page': page,
        'limit': limit,
        'status': status,
        'search': search,
        'branch': branch,
      },
    );

    final decoded = json.decode(response.body);
    if (decoded == null || decoded['data'] == null) {
      return const AppointmentsListModel(
        appointmentItems: [],
        pagination: AppointmentPaginationModel(total: 0, page: 1, limit: 10, totalPages: 1),
      );
    }
    return AppointmentsListModel.fromJson(decoded['data']);
  }
}
