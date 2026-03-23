import 'dart:convert';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_service_repository.dart';
import '../models/order_model.dart';

abstract class OrdersRemoteDataSource {
  Future<OrdersListModel> getOrders({
    int page = 1,
    int limit = 10,
    String status = '',
    String search = '',
  });
  Future<OrderItemModel> getOrderDetails(String orderId);
  Future<bool> updateOrderStatus(String orderItemId, Map<String, dynamic> payload);
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
  }) async {
    final response = await apiService.get(
      ApiEndpoints.orderList,
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
        pagination: PaginationModel(total: 0, page: 1, limit: 10, totalPages: 1),
      );
    }
    return OrdersListModel.fromJson(decoded['data']);
  }

  @override
  Future<OrderItemModel> getOrderDetails(String orderId) async {
    final response = await apiService.get('${ApiEndpoints.orderDetails}/$orderId');

    final decoded = json.decode(response.body);
    if (decoded == null ||
        decoded['data'] == null ||
        decoded['data']['Order'] == null) {
      throw Exception('Order details not found');
    }
    return OrderItemModel.fromJson(decoded['data']['Order']);
  }

  @override
  Future<bool> updateOrderStatus(String orderItemId, Map<String, dynamic> payload) async {
    final response = await apiService.post(
      ApiEndpoints.updateOrderStatus(orderItemId),
      body: payload,
    );
    final decoded = json.decode(response.body);
    if (decoded['success'] == true) {
      return true;
    } else {
      throw Exception(decoded['message'] ?? 'Failed to update order status');
    }
  }
}
