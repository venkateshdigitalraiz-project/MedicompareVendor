import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/utils/token_storage.dart';
import '../models/order_model.dart';

abstract class OrdersRemoteDataSource {
  Future<OrdersListModel> getOrders({
    int page = 1,
    int limit = 10,
    String status = '',
    String search = '',
  });
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  final http.Client client;

  OrdersRemoteDataSourceImpl({required this.client});

  @override
  Future<OrdersListModel> getOrders({
    int page = 1,
    int limit = 10,
    String status = '',
    String search = '',
  }) async {
    final token = await TokenStorage.getToken();
    final url = Uri.parse(
        '${ApiEndpoints.orderList}?page=$page&limit=$limit&status=$status&search=$search');

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
         return const OrdersListModel(orderItems: [], pagination: PaginationModel(total: 0, page: 1, limit: 10, totalPages: 1));
      }
      return OrdersListModel.fromJson(decoded['data']);
    } else if (response.statusCode == 401) {
      throw Exception('UNAUTHORIZED');
    } else {
      throw Exception('Failed to fetch orders: ${response.statusCode}');
    }
  }
}
