import '../../../../core/error/exceptions.dart';
import '../../domain/entities/rental_booking_entity.dart';
import '../../domain/repositories/rental_booking_repository.dart';
import '../datasources/rental_booking_remote_data_source.dart';

class RentalBookingRepositoryImpl implements RentalBookingRepository {
  final RentalBookingRemoteDataSource remoteDataSource;

  RentalBookingRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<RentalBookingResponseEntity> getRentalBookings({
    required int page,
    String? status,
    String? search,
  }) async {
    return await remoteDataSource.getRentalBookings(
      page: page,
      status: status,
      search: search,
    );
  }
}
