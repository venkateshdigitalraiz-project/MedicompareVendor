import 'dart:convert';
import 'dart:io';
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

  Future<void> uploadReport({
    required String orderId,
    required String reportType,
    required String patientId,
    required String selectType,
    String? description,
    required File file,
  });

  Future<void> updateOrderStatus({
    required String orderId,
    required String orderStatus,
  });
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
  Future<void> uploadReport({
    required String orderId,
    required String reportType,
    required String patientId,
    required String selectType,
    String? description,
    required File file,
  }) async {
    final fields = <String, String>{
      'reportType': reportType.isNotEmpty ? reportType : 'labtests',
      'patientId': patientId,
      'selectType': selectType.isNotEmpty ? selectType : 'family',
      'description': description ?? '',
    };

    final response = await apiService.post(
      ApiEndpoints.uploadReport(orderId),
      fields: fields,
      files: {'file': file},
    );

    final decoded = json.decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is Map &&
          (decoded['status'] == false || decoded['success'] == false)) {
        throw Exception(decoded['message'] ?? 'Failed to upload report');
      }
      return;
    } else {
      final message = decoded != null && decoded is Map && decoded['message'] != null
          ? decoded['message'].toString()
          : 'Failed to upload report';
      throw Exception(message);
    }
  }

  @override
  Future<void> updateOrderStatus({
    required String orderId,
    required String orderStatus,
  }) async {
    final response = await apiService.post(
      ApiEndpoints.updateAppointmentOrderStatus(orderId),
      body: {'orderStatus': orderStatus},
    );

    final decoded = json.decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is Map &&
          (decoded['status'] == false || decoded['success'] == false)) {
        throw Exception(decoded['message'] ?? 'Failed to update order status');
      }
      return;
    } else {
      final message = decoded != null && decoded is Map && decoded['message'] != null
          ? decoded['message'].toString()
          : 'Failed to update order status';
      throw Exception(message);
    }
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
