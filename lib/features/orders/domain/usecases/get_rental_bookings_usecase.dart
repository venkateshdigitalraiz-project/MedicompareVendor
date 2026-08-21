import '../entities/rental_booking_entity.dart';
import '../repositories/rental_booking_repository.dart';

class GetRentalBookingsUseCase {
  final RentalBookingRepository repository;

  GetRentalBookingsUseCase(this.repository);

  Future<RentalBookingResponseEntity> call({
    required int page,
    String? status,
    String? search,
  }) async {
    return await repository.getRentalBookings(
      page: page,
      status: status,
      search: search,
    );
  }
}
