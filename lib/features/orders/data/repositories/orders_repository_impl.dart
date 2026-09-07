import '../../../appointment/domain/entities/delivery_partner_entity.dart';
import '../datasources/orders_remote_data_source.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/orders_repository.dart';

import '../../domain/entities/order_details_response_entity.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource remoteDataSource;

  OrdersRepositoryImpl({required this.remoteDataSource});

  @override
  Future<OrdersListEntity> getOrders({
    int page = 1,
    int limit = 10,
    String status = '',
    String search = '',
    String orderType = 'normal',
  }) async {
    return await remoteDataSource.getOrders(
      page: page,
      limit: limit,
      status: status,
      search: search,
      orderType: orderType,
    );
  }

  @override
  Future<OrderDetailsResponseEntity> getOrderDetails(String orderId,
      {String orderType = 'normal'}) async {
    return await remoteDataSource.getOrderDetails(orderId, orderType: orderType);
  }

  @override
  Future<bool> updateOrderStatus(
      String orderItemId, Map<String, dynamic> payload) async {
    return await remoteDataSource.updateOrderStatus(orderItemId, payload);
  }

  @override
  Future<DeliveryPartnersResultEntity> getDeliveryPartners({
    String deliveryManType = 'admin',
    int page = 1,
    int limit = 10,
    String status = 'active',
    String search = '',
  }) async {
    return await remoteDataSource.getDeliveryPartners(
      deliveryManType: deliveryManType,
      page: page,
      limit: limit,
      status: status,
      search: search,
    );
  }

  @override
  Future<bool> assignDeliveryPartner({
    required String orderId,
    required String deliveryPartnerId,
    String deliveryManType = 'admin',
    String deliveryPartner = 'medicompares',
    String? readyTime,
  }) async {
    return await remoteDataSource.assignDeliveryPartner(
      orderId: orderId,
      deliveryPartnerId: deliveryPartnerId,
      deliveryManType: deliveryManType,
      deliveryPartner: deliveryPartner,
      readyTime: readyTime,
    );
  }
}

