import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/utils/token_storage.dart';
import '../models/pincode_model.dart';

abstract class PincodesRemoteDataSource {
  Future<List<PincodeDataModel>> getPincodes();
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

    if (response.statusCode == 200) {
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
}
