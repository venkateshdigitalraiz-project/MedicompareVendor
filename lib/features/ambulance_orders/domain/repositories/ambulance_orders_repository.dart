import '../../../appointment/domain/entities/delivery_partner_entity.dart';
import '../entities/ambulance_order_entity.dart';

abstract class AmbulanceOrdersRepository {
  Future<AmbulanceOrdersListEntity> getOrders({
    int page = 1,
    int limit = 10,
    String status = '',
    String search = '',
  });

  Future<AmbulanceOrderEntity> getOrderDetails(String id);

  Future<void> updateBookingStatus({
    required String orderId,
    required String bookingStatus,
    String? reason,
  });

  Future<DeliveryPartnersResultEntity> getDeliveryPartners({
    String deliveryManType = 'admin',
    int page = 1,
    int limit = 10,
    String status = 'active',
    String search = '',
  });

  Future<void> assignDeliveryPartner({
    required String orderId,
    required String deliveryPartnerId,
    String deliveryManType = 'admin',
    String deliveryPartner = 'medicompares',
    String? readyTime,
  });
}
