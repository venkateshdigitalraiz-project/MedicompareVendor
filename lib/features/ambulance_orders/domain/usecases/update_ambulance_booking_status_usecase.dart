import '../repositories/ambulance_orders_repository.dart';

class UpdateAmbulanceBookingStatusUseCase {
  final AmbulanceOrdersRepository repository;

  UpdateAmbulanceBookingStatusUseCase(this.repository);

  Future<void> call({
    required String orderId,
    required String bookingStatus,
    String? reason,
  }) {
    return repository.updateBookingStatus(
      orderId: orderId,
      bookingStatus: bookingStatus,
      reason: reason,
    );
  }
}
