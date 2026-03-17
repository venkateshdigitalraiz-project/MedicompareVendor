import 'dart:convert';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_service_repository.dart';
import '../models/pincode_model.dart';

abstract class PincodesRemoteDataSource {
  Future<List<PincodeDataModel>> getPincodes();
  Future<void> createPincode({
    required String pincode,
    required String estimatedDelivery,
    required String status,
  });
  Future<void> updatePincode({
    required String id,
    required String pincode,
    required String estimatedDelivery,
    required String status,
  });
  Future<void> deletePincode(String id);
}

class PincodesRemoteDataSourceImpl implements PincodesRemoteDataSource {
  final ApiServiceRepository apiService;

  PincodesRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<PincodeDataModel>> getPincodes() async {
    final response = await apiService.get(ApiEndpoints.pincodeList);
    final jsonResponse = json.decode(response.body);
    final List list = jsonResponse['data']['list'];
    return list.map((e) => PincodeDataModel.fromJson(e)).toList();
  }

  @override
  Future<void> createPincode({
    required String pincode,
    required String estimatedDelivery,
    required String status,
  }) async {
    await apiService.post(
      ApiEndpoints.pincodeCreate,
      body: {
        'name': pincode,
        'estimateddelivery': estimatedDelivery,
        'status': status,
      },
    );
  }

  @override
  Future<void> updatePincode({
    required String id,
    required String pincode,
    required String estimatedDelivery,
    required String status,
  }) async {
    await apiService.post(
      ApiEndpoints.pincodeUpdate(id),
      body: {
        'name': pincode,
        'estimateddelivery': estimatedDelivery,
        'status': status,
      },
    );
  }

  @override
  Future<void> deletePincode(String id) async {
    await apiService.post(ApiEndpoints.pincodeDelete(id));
  }
}
