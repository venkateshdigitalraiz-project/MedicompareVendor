import 'dart:convert';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_service_repository.dart';
import '../models/order_model.dart';
import '../../../appointment/data/models/delivery_partner_model.dart';
import '../models/order_details_response_model.dart';

abstract class OrdersRemoteDataSource {
  Future<OrdersListModel> getOrders({
    int page = 1,
    int limit = 10,
    String status = '',
    String search = '',
    String orderType = 'normal',
  });
  Future<OrderDetailsResponseModel> getOrderDetails(String orderId,
      {String orderType = 'normal'});
  Future<bool> updateOrderStatus(
      String orderItemId, Map<String, dynamic> payload);
  Future<DeliveryPartnersResultModel> getDeliveryPartners({
    String deliveryManType = 'admin',
    int page = 1,
    int limit = 10,
    String status = 'active',
    String search = '',
  });
  Future<bool> assignDeliveryPartner({
    required String orderId,
    required String deliveryPartnerId,
    String deliveryManType = 'admin',
    String deliveryPartner = 'medicompares',
    String? readyTime,
  });
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  final ApiServiceRepository apiService;

  OrdersRemoteDataSourceImpl({required this.apiService});

  @override
  Future<OrdersListModel> getOrders({
    int page = 1,
    int limit = 10,
    String status = '',
    String search = '',
    String orderType = 'normal',
  }) async {
    final endpoint = orderType == 'rental'
        ? ApiEndpoints.rentalOrderList
        : (orderType == 'appointment'
            ? ApiEndpoints.appointmentOrderList
            : ApiEndpoints.orderList);

    final response = await apiService.get(
      endpoint,
      queryParameters: {
        'page': page,
        'limit': limit,
        'status': status,
        'search': search,
      },
    );

    final decoded = json.decode(response.body);
    if (decoded == null || decoded['data'] == null) {
      return const OrdersListModel(
        orderItems: [],
        pagination:
            PaginationModel(total: 0, page: 1, limit: 10, totalPages: 1),
      );
    }
    return OrdersListModel.fromJson(decoded['data']);
  }

  @override
  Future<OrderDetailsResponseModel> getOrderDetails(String orderId,
      {String orderType = 'normal'}) async {
    final endpoint = orderType == 'rental'
        ? ApiEndpoints.rentalOrderDetails
        : ApiEndpoints.orderDetails;
    final response = await apiService.get('$endpoint/$orderId');

    final decoded = json.decode(response.body);
    if (decoded == null ||
        decoded['data'] == null ||
        decoded['data']['Order'] == null) {
      throw Exception('Order details not found');
    }

    final data = decoded['data'];
    final orderMap = Map<String, dynamic>.from(data['Order'] as Map);

    final keysToMerge = [
      'installmentlist',
      'installmentList',
      'installment_list',
      'installments',
      'deliveries',
      'delivery',
      'deliveryPartner',
      'deliveryPartnerDetails',
      'assignedPartner',
      'assignedPartnerDetails',
      'driverDetails',
      'assignedDriver',
      'deliveryman',
      'deliveryMan',
      'deliverymanDetails',
      'partnerDetails',
    ];

    for (var key in keysToMerge) {
      if (data[key] != null && orderMap[key] == null) {
        orderMap[key] = data[key];
      }
    }

    return OrderDetailsResponseModel.fromJson(orderMap);
  }

  @override
  Future<bool> updateOrderStatus(
      String orderItemId, Map<String, dynamic> payload) async {
    final response = await apiService.post(
      ApiEndpoints.updateOrderStatus(orderItemId),
      body: payload,
    );
    final decoded = json.decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is Map &&
          (decoded['status'] == false || decoded['success'] == false)) {
        throw Exception(decoded['message'] ?? 'Failed to update order status');
      }
      return true;
    } else {
      final message = decoded != null && decoded is Map && decoded['message'] != null
          ? decoded['message'].toString()
          : 'Failed to update order status';
      throw Exception(message);
    }
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
      'search': search.trim(),
    };

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
  Future<bool> assignDeliveryPartner({
    required String orderId,
    required String deliveryPartnerId,
    String deliveryManType = 'admin',
    String deliveryPartner = 'medicompares',
    String? readyTime,
  }) async {
    final body = <String, dynamic>{
      'orderStatus': 'assigned',
      'deliveryManType': deliveryManType,
      'deliveryPartner': deliveryPartner,
      'deliveryPartnerId': deliveryPartnerId,
      'orderId': orderId,
      'readyTime': (readyTime != null && readyTime.isNotEmpty) ? readyTime : '30',
      'status': 'assigned',
      'packageIds': [],
      'productIds': [],
      'rejectionReason': null,
    };

    final response = await apiService.post(
      ApiEndpoints.updateOrderStatus(orderId),
      body: body,
    );

    final decoded = json.decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is Map &&
          (decoded['status'] == false || decoded['success'] == false)) {
        throw Exception(decoded['message'] ?? 'Failed to assign delivery partner');
      }
      return true;
    } else {
      final message = decoded != null && decoded is Map && decoded['message'] != null
          ? decoded['message'].toString()
          : 'Failed to assign delivery partner';
      throw Exception(message);
    }
  }
}
