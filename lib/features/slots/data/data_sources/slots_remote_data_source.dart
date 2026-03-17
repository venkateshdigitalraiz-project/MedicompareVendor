import 'dart:convert';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_service_repository.dart';
import '../models/slot_timing_model.dart';

abstract class SlotsRemoteDataSource {
  Future<List<SlotTimingModel>> getSlotTimings();
  Future<SlotTimingModel> updateSlotTimings(String id, SlotTimingModel model);
}

class SlotsRemoteDataSourceImpl implements SlotsRemoteDataSource {
  final ApiServiceRepository apiService;

  SlotsRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<SlotTimingModel>> getSlotTimings() async {
    final response = await apiService.get(ApiEndpoints.slotTimings);
    final jsonResponse = json.decode(response.body);
    final List timingsList = jsonResponse['data']['vendorTimings'];
    return timingsList.map((e) => SlotTimingModel.fromJson(e)).toList();
  }

  @override
  Future<SlotTimingModel> updateSlotTimings(String id, SlotTimingModel model) async {
    final response = await apiService.post(
      ApiEndpoints.updateSlotTimings(id),
      body: model.toJson(),
    );
    final jsonResponse = json.decode(response.body);
    return SlotTimingModel.fromJson(jsonResponse['data']);
  }
}
