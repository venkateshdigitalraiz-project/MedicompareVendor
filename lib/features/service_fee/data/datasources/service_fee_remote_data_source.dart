import 'dart:convert';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_service_repository.dart';
import '../../../../core/error/exceptions.dart';
import '../models/service_fee_model.dart';
import '../models/service_fee_response_model.dart';

abstract class ServiceFeeRemoteDataSource {
  Future<ServiceFeeModel> getServiceFee();
  Future<bool> updateServiceSettings(Map<String, dynamic> payload);
}

class ServiceFeeRemoteDataSourceImpl implements ServiceFeeRemoteDataSource {
  final ApiServiceRepository apiService;

  ServiceFeeRemoteDataSourceImpl(this.apiService);

  @override
  Future<ServiceFeeModel> getServiceFee() async {
    try {
      final response = await apiService.get(ApiEndpoints.serviceChargeList);
      final body = jsonDecode(response.body);
      final responseModel = ServiceFeeResponseModel.fromJson(body);
      if (responseModel.success) {
        final dataJson = body['data'] as Map<String, dynamic>? ?? {};
        return ServiceFeeModel.fromJson(dataJson, user: responseModel.user);
      }
      throw ServerException(responseModel.message.isNotEmpty
          ? responseModel.message
          : 'Failed to fetch service fee');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> updateServiceSettings(Map<String, dynamic> payload) async {
    try {
      final response = await apiService.post(
        ApiEndpoints.updateServiceSettings,
        body: payload,
      );
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        return true;
      }
      throw ServerException(body['message'] ?? 'Failed to update service settings');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }
}
