import '../entities/delivery_partner_entity.dart';
import '../repositories/appointment_repository.dart';

class GetDeliveryPartnersUseCase {
  final AppointmentRepository repository;

  GetDeliveryPartnersUseCase(this.repository);

  Future<DeliveryPartnersResultEntity> call({
    String deliveryManType = 'admin',
    int page = 1,
    int limit = 10,
    String status = 'active',
    String search = '',
  }) async {
    return await repository.getDeliveryPartners(
      deliveryManType: deliveryManType,
      page: page,
      limit: limit,
      status: status,
      search: search,
    );
  }
}
