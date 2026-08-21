import '../entities/rental_booking_entity.dart';

abstract class RentalBookingRepository {
  Future<RentalBookingResponseEntity> getRentalBookings({
    required int page,
    String? status,
    String? search,
  });
}
