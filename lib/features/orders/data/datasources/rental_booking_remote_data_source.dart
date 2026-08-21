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
        'orderType': 'rental', 
      };

      if (status != null && status.isNotEmpty) {
        queryParameters['status'] = status;
      }
      
      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }

      final response = await apiService.get(
        ApiEndpoints.rentalOrderList, 
        queryParameters: queryParameters,
      );

      final decoded = json.decode(response.body);
      
      if (decoded['success'] == true) {
        return RentalBookingResponseModel.fromJson(decoded['data']);
      } else {
        throw ServerException(decoded['message'] ?? 'Failed to fetch rental bookings');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }
}
