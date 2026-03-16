import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/utils/token_storage.dart';
import '../models/slot_timing_model.dart';

abstract class SlotsRemoteDataSource {
  Future<List<SlotTimingModel>> getSlotTimings();
}

class SlotsRemoteDataSourceImpl implements SlotsRemoteDataSource {
  final http.Client client;

  SlotsRemoteDataSourceImpl({required this.client});

  @override
  Future<List<SlotTimingModel>> getSlotTimings() async {
    final token = await TokenStorage.getToken();
    
    final response = await client.get(
      Uri.parse(ApiEndpoints.slotTimings),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success']) {
        final List timingsList = jsonResponse['data']['vendorTimings'];
        return timingsList.map((e) => SlotTimingModel.fromJson(e)).toList();
      } else {
        throw Exception(jsonResponse['message'] ?? 'Failed to load slot timings');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }
}
