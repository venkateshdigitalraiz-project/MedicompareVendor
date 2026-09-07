import '../../../appointment/domain/entities/delivery_partner_entity.dart';
import '../../domain/entities/ambulance_order_entity.dart';
import '../../domain/repositories/ambulance_orders_repository.dart';
import '../datasources/ambulance_orders_remote_data_source.dart';

class AmbulanceOrdersRepositoryImpl implements AmbulanceOrdersRepository {
  final AmbulanceOrdersRemoteDataSource remoteDataSource;

  AmbulanceOrdersRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AmbulanceOrdersListEntity> getOrders({
    int page = 1,
    int limit = 10,
    String status = '',
    String search = '',
  }) {
    return remoteDataSource.getBookingList(
      page: page,
      limit: limit,
      status: status,
      search: search,
    );
  }

  @override
  Future<AmbulanceOrderEntity> getOrderDetails(String id) {
    return remoteDataSource.getBookingDetails(id);
  }

  @override
  Future<void> updateBookingStatus({
    required String orderId,
    required String bookingStatus,
    String? reason,
  }) {
    return remoteDataSource.updateBookingStatus(
      orderId: orderId,
      bookingStatus: bookingStatus,
      reason: reason,
    );
  }

  @override
  Future<DeliveryPartnersResultEntity> getDeliveryPartners({
    String deliveryManType = 'admin',
    int page = 1,
    int limit = 10,
    String status = 'active',
    String search = '',
  }) {
    return remoteDataSource.getDeliveryPartners(
      deliveryManType: deliveryManType,
      page: page,
      limit: limit,
      status: status,
      search: search,
    );
  }

  @override
  Future<void> assignDeliveryPartner({
    required String orderId,
    required String deliveryPartnerId,
    String deliveryManType = 'admin',
    String deliveryPartner = 'medicompares',
    String? readyTime,
  }) {
    return remoteDataSource.assignDeliveryPartner(
      orderId: orderId,
      deliveryPartnerId: deliveryPartnerId,
      deliveryManType: deliveryManType,
      deliveryPartner: deliveryPartner,
      readyTime: readyTime,
    );
  }
}
