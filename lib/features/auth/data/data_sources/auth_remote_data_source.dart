import 'dart:convert';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_service_repository.dart';
import '../models/vendor_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<VendorResponseModel> register({
    required String firstName,
    required String lastName,
    required String email,
    required String mobile,
    required String password,
  });

  Future<VendorResponseModel> login({
    required String email,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiServiceRepository apiService;

  AuthRemoteDataSourceImpl({required this.apiService});

  @override
  Future<VendorResponseModel> register({
    required String firstName,
    required String lastName,
    required String email,
    required String mobile,
    required String password,
  }) async {
    final response = await apiService.post(
      ApiEndpoints.register,
      body: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'mobile': mobile,
        'password': password,
      },
    );

    return VendorResponseModel.fromJson(jsonDecode(response.body));
  }

  @override
  Future<VendorResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await apiService.post(
      ApiEndpoints.login,
      body: {
        'email': email,
        'password': password,
      },
    );

    return VendorResponseModel.fromJson(jsonDecode(response.body));
  }
}
