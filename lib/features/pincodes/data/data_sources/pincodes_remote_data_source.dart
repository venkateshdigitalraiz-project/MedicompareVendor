import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/utils/token_storage.dart';
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
  final http.Client client;

  PincodesRemoteDataSourceImpl({required this.client});

  @override
  Future<List<PincodeDataModel>> getPincodes() async {
    final token = await TokenStorage.getToken();
    
    final response = await client.get(
      Uri.parse(ApiEndpoints.pincodeList),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 304) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success']) {
        final List list = jsonResponse['data']['list'];
        return list.map((e) => PincodeDataModel.fromJson(e)).toList();
      } else {
        throw Exception(jsonResponse['message'] ?? 'Failed to load pincodes');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  @override
  Future<void> createPincode({
    required String pincode,
    required String estimatedDelivery,
    required String status,
  }) async {
    final token = await TokenStorage.getToken();
    
    final response = await client.post(
      Uri.parse(ApiEndpoints.pincodeCreate),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'name': pincode,
        'estimateddelivery': estimatedDelivery,
        'status': status,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == false) {
        throw Exception(jsonResponse['message'] ?? 'Failed to create pincode');
      }
    } else {
      Map<String, dynamic> jsonResponse = {};
      try {
        jsonResponse = json.decode(response.body);
      } catch (_) {}
      throw Exception(jsonResponse['message'] ?? 'Server error: ${response.statusCode}');
    }
  }

  @override
  Future<void> updatePincode({
    required String id,
    required String pincode,
    required String estimatedDelivery,
    required String status,
  }) async {
    final token = await TokenStorage.getToken();
    
    final response = await client.post(
      Uri.parse(ApiEndpoints.pincodeUpdate(id)),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'name': pincode,
        'estimateddelivery': estimatedDelivery,
        'status': status,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == false) {
        throw Exception(jsonResponse['message'] ?? 'Failed to update pincode');
      }
    } else {
      Map<String, dynamic> jsonResponse = {};
      try {
        jsonResponse = json.decode(response.body);
      } catch (_) {}
      throw Exception(jsonResponse['message'] ?? 'Server error: ${response.statusCode}');
    }
  }

  @override
  Future<void> deletePincode(String id) async {
    final token = await TokenStorage.getToken();
    
    final response = await client.post(
      Uri.parse(ApiEndpoints.pincodeDelete(id)),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == false) {
        throw Exception(jsonResponse['message'] ?? 'Failed to delete pincode');
      }
    } else {
      Map<String, dynamic> jsonResponse = {};
      try {
        jsonResponse = json.decode(response.body);
      } catch (_) {}
      throw Exception(jsonResponse['message'] ?? 'Server error: ${response.statusCode}');
    }
  }
}
