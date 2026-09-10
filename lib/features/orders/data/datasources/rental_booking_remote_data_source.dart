import 'dart:convert';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_service_repository.dart';
import '../../../../core/error/exceptions.dart';
import '../models/rental_booking_model.dart';

abstract class RentalBookingRemoteDataSource {
  Future<RentalBookingResponseModel> getRentalBookings({
    required int page,
    String? status,
    String? search,
  });
}

class RentalBookingRemoteDataSourceImpl implements RentalBookingRemoteDataSource {
  final ApiServiceRepository apiService;

  RentalBookingRemoteDataSourceImpl({required this.apiService});

  @override
  Future<RentalBookingResponseModel> getRentalBookings({
    required int page,
    String? status,
    String? search,
  }) async {
    try {
      final Map<String, dynamic> queryParameters = {
        'page': page,
        'limit': 10,
      };

      if (status != null && status.trim().isNotEmpty) {
        queryParameters['status'] = status.trim();
      }
      
      if (search != null && search.trim().isNotEmpty) {
        queryParameters['search'] = search.trim();
      }

      final response = await apiService.get(
        ApiEndpoints.rentalOrderList, 
        queryParameters: queryParameters,
      );

      final decoded = json.decode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decoded == null) {
          return const RentalBookingResponseModel(
            orderItems: [],
            pagination: RentalBookingPaginationModel(
              total: 0,
              page: 1,
              limit: 10,
              totalPages: 1,
              hasNextPage: false,
              hasPrevPage: false,
            ),
          );
        }
        final data = decoded['data'] ?? decoded;
        return RentalBookingResponseModel.fromJson(data);
      } else {
        throw ServerException(
            decoded?['message'] ?? 'Failed to fetch rental bookings');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }
}
