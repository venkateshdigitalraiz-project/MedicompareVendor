import 'dart:convert';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_service_repository.dart';
import '../../../../core/utils/token_storage.dart';
import '../models/slot_timing_model.dart';
import '../models/vendor_vacation_model.dart';

abstract class SlotsRemoteDataSource {
  Future<List<SlotTimingModel>> getSlotTimings();
  Future<SlotTimingModel> updateSlotTimings(String id, SlotTimingModel model);
  Future<List<VendorVacationModel>> getVacationCalendar({
    required int month,
    required int year,
  });
  Future<bool> saveVacation(VendorVacationModel model);
  Future<bool> deleteVacation(String id);
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
  Future<SlotTimingModel> updateSlotTimings(
      String id, SlotTimingModel model) async {
    final response = await apiService.post(
      ApiEndpoints.updateSlotTimings(id),
      body: model.toJson(),
    );
    final jsonResponse = json.decode(response.body);
    return SlotTimingModel.fromJson(jsonResponse['data']);
  }

  @override
  Future<List<VendorVacationModel>> getVacationCalendar({
    required int month,
    required int year,
  }) async {
    final response = await apiService.get(
      ApiEndpoints.vendorVacationsCalendar,
      queryParameters: {
        'month': month,
        'year': year,
      },
    );

    final jsonResponse = json.decode(response.body);
    List rawList = [];
    if (jsonResponse is Map<String, dynamic>) {
      final data = jsonResponse['data'];
      if (data is List) {
        rawList = data;
      } else if (data is Map<String, dynamic>) {
        if (data['vendorVacations'] is List) {
          rawList = data['vendorVacations'];
        } else if (data['vacations'] is List) {
          rawList = data['vacations'];
        } else if (data['vacationCalendar'] is List) {
          rawList = data['vacationCalendar'];
        } else if (data['calendar'] is List) {
          rawList = data['calendar'];
        } else if (data['items'] is List) {
          rawList = data['items'];
        } else if (data['days'] is List) {
          rawList = data['days'];
        } else if (data['list'] is List) {
          rawList = data['list'];
        }
      } else if (jsonResponse['vendorVacations'] is List) {
        rawList = jsonResponse['vendorVacations'];
      } else if (jsonResponse['vacations'] is List) {
        rawList = jsonResponse['vacations'];
      }
    } else if (jsonResponse is List) {
      rawList = jsonResponse;
    }

    final allModels = rawList
        .map((e) => VendorVacationModel.fromJson(
            Map<String, dynamic>.from(e as Map)))
        .toList();

    // When the API returns full monthly calendar "days", filter to actual holidays/vacations
    return allModels.where((m) => m.isVacation).toList();
  }

  @override
  Future<bool> saveVacation(VendorVacationModel model) async {
    try {
      final resolvedVendorId = model.vendorId.isNotEmpty
          ? model.vendorId
          : (await TokenStorage.getVendorId() ?? '');
      final body = model.toJson(overrideVendorId: resolvedVendorId);

      final response = await apiService.post(
        ApiEndpoints.vendorVacationsCreate,
        body: body,
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final data = json.decode(response.body);
          if (data is Map && data.containsKey('success')) {
            return data['success'] == true;
          }
        } catch (_) {}
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> deleteVacation(String id) async {
    try {
      if (id.isEmpty) return true;
      final response = await apiService.delete(
        ApiEndpoints.vendorVacationsDelete(id),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
