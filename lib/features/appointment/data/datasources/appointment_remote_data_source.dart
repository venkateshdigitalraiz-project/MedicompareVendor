import 'dart:convert';
import 'dart:io';
import '../models/appointment_details_model.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_service_repository.dart';
import '../models/appointment_model.dart';

import '../models/delivery_partner_model.dart';

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
    String? rejectionReason,
  });

  Future<DeliveryPartnersResultModel> getDeliveryPartners({
    String deliveryManType = 'admin',
    int page = 1,
    int limit = 10,
    String status = 'active',
    String search = '',
  });

  Future<void> assignDeliveryPartner({
    required String orderId,
    required String deliveryPartnerId,
    String deliveryManType = 'vendor',
    String deliveryPartner = 'self',
    String? readyTime,
  });
}

class AppointmentRemoteDataSourceImpl implements AppointmentRemoteDataSource {
  final ApiServiceRepository apiService;

  AppointmentRemoteDataSourceImpl({required this.apiService});

  @override
  Future<AppointmentDetailsModel> getAppointmentDetails(String id) async {
    final response = await apiService.get('${ApiEndpoints.appointmentOrderDetails}/$id');

    final decoded = json.decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded == null || decoded['data'] == null) {
        throw Exception('Failed to load appointment details');
      }

      Map<String, dynamic> orderJson;
      if (decoded['data']['orders'] is List &&
          (decoded['data']['orders'] as List).isNotEmpty) {
        orderJson = Map<String, dynamic>.from(
            (decoded['data']['orders'] as List).first as Map);
      } else if (decoded['data'] is Map) {
        orderJson = Map<String, dynamic>.from(decoded['data'] as Map);
      } else {
        throw Exception('Appointment not found');
      }

      return AppointmentDetailsModel.fromJson(orderJson);
    } else {
      final message = decoded != null && decoded is Map && decoded['message'] != null
          ? decoded['message'].toString()
          : 'Failed to load appointment details';
      throw Exception(message);
    }
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
      'reportType': reportType,
      'patientId': patientId,
      'selectType': selectType,
    };
    if (description != null && description.isNotEmpty) {
      fields['description'] = description;
    }

    final response = await apiService.post(
      ApiEndpoints.uploadReport(orderId),
      fields: fields,
      files: {'reportFiles': file},
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
    String? rejectionReason,
  }) async {
    final body = <String, dynamic>{
      'orderStatus': orderStatus,
      'status': orderStatus,
    };
    if (rejectionReason != null && rejectionReason.isNotEmpty) {
      body['rejectionReason'] = rejectionReason;
    }

    final response = await apiService.post(
      ApiEndpoints.updateAppointmentOrderStatus(orderId),
      body: body,
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

  @override
  Future<DeliveryPartnersResultModel> getDeliveryPartners({
    String deliveryManType = 'admin',
    int page = 1,
    int limit = 10,
    String status = 'active',
    String search = '',
  }) async {
    final queryParams = <String, dynamic>{
      'deliveryManType': deliveryManType,
      'page': page,
      'limit': limit,
      'status': status,
    };
    if (search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    final response = await apiService.get(
      ApiEndpoints.deliverymanAdminList,
      queryParameters: queryParams,
    );

    final decoded = json.decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded == null) return const DeliveryPartnersResultModel();

      List<dynamic> items = [];
      DeliveryPartnerModel? ownUser;

      if (decoded is List) {
        items = decoded;
      } else if (decoded is Map) {
        if (decoded['users'] is Map) {
          ownUser = DeliveryPartnerModel.fromUserJson(
              Map<String, dynamic>.from(decoded['users'] as Map));
        } else if (decoded['user'] is Map) {
          ownUser = DeliveryPartnerModel.fromUserJson(
              Map<String, dynamic>.from(decoded['user'] as Map));
        }

        if (decoded['data'] is Map) {
          final dataMap = decoded['data'] as Map;
          for (final key in [
            'deliveryMans',
            'deliverymen',
            'deliveryMen',
            'deliveryMan',
            'adminList',
            'adminlist',
            'list',
            'partners',
            'deliveryPartners',
            'items',
            'docs',
          ]) {
            if (dataMap[key] is List) {
              items = dataMap[key] as List;
              break;
            }
          }
        } else if (decoded['data'] is List) {
          items = decoded['data'] as List;
        }

        if (items.isEmpty) {
          for (final key in [
            'deliveryMans',
            'deliverymen',
            'deliveryMen',
            'deliveryMan',
            'adminList',
            'adminlist',
            'list',
            'partners',
            'deliveryPartners',
            'items',
            'docs',
          ]) {
            if (decoded[key] is List) {
              items = decoded[key] as List;
              break;
            }
          }
        }
      }

      final deliveryMans = items
          .where((e) => e != null && e is Map)
          .map((e) => DeliveryPartnerModel.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList();

      return DeliveryPartnersResultModel(
        deliveryMans: deliveryMans,
        ownDeliveryUser: ownUser,
      );
    } else {
      final message = decoded != null && decoded is Map && decoded['message'] != null
          ? decoded['message'].toString()
          : 'Failed to load delivery partners';
      throw Exception(message);
    }
  }

  @override
  Future<void> assignDeliveryPartner({
    required String orderId,
    required String deliveryPartnerId,
    String deliveryManType = 'vendor',
    String deliveryPartner = 'self',
    String? readyTime,
  }) async {
    final body = <String, dynamic>{
      'deliveryManType': deliveryManType,
      'deliveryPartner': deliveryPartner,
      'deliveryPartnerId': deliveryPartnerId,
      'orderId': orderId,
      'orderStatus': 'assigned',
      'readyTime': readyTime,
      'status': 'assigned',
    };

    final response = await apiService.post(
      ApiEndpoints.updateAppointmentOrderStatus(orderId),
      body: body,
    );

    final decoded = json.decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is Map &&
          (decoded['status'] == false || decoded['success'] == false)) {
        throw Exception(decoded['message'] ?? 'Failed to assign delivery partner');
      }
      return;
    } else {
      final message = decoded != null && decoded is Map && decoded['message'] != null
          ? decoded['message'].toString()
          : 'Failed to assign delivery partner';
      throw Exception(message);
    }
  }
}
